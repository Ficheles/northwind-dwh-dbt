{{
    config(
        materialized='table',
        schema='dwh_mart_products'
    )
}}

/*
    DATA MART: PRODUTOS
    
    Objetivo: Análise de performance de produtos por categoria e fornecedor.
    
    Dimensões:
    - dim_products (produto/categoria/fornecedor)
    - dim_date (tempo)
    
    Métricas:
    - Vendas por produto, margem, rotatividade
*/

with sales as (
    select * from {{ ref('fct_sales') }}
),

products as (
    select * from {{ ref('dim_products') }}
)

select
    -- Dimensões
    s.order_year,
    s.order_quarter,
    p.product_name,
    p.category_name,
    p.supplier_name,
    p.supplier_country,
    p.price_tier,
    p.is_discontinued,
    
    -- Métricas de estoque (valores fixos do produto)
    max(p.units_in_stock) as current_stock,
    max(p.inventory_value) as inventory_value,
    max(p.needs_reorder) as needs_reorder,
    
    -- Métricas de vendas
    count(distinct s.order_id) as orders_with_product,
    sum(s.quantity) as total_quantity_sold,
    sum(s.net_amount) as total_revenue,
    
    -- Métricas calculadas
    avg(s.unit_price) as avg_selling_price,
    sum(s.quantity) / nullif(count(distinct s.order_id), 0) as avg_qty_per_order,
    
    -- Ranking
    row_number() over (
        partition by s.order_year, p.category_name 
        order by sum(s.net_amount) desc
    ) as rank_in_category

from sales s
join products p on s.product_sk = p.product_sk
group by 
    s.order_year,
    s.order_quarter,
    p.product_name,
    p.category_name,
    p.supplier_name,
    p.supplier_country,
    p.price_tier,
    p.is_discontinued