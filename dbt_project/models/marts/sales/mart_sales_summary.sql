{{
    config(
        materialized='table',
        schema='dwh_mart_sales'
    )
}}

/*
    DATA MART: VENDAS
    
    Objetivo: Análise de performance de vendas por período, região e vendedor.
    
    Dimensões:
    - dim_date (tempo)
    - dim_customers (cliente/região)
    - dim_employees (vendedor)
    
    Métricas:
    - Receita total, desconto total, ticket médio
*/

with sales as (
    select * from {{ ref('fct_sales') }}
),

customers as (
    select * from {{ ref('dim_customers') }}
),

employees as (
    select * from {{ ref('dim_employees') }}
)

select
    -- Dimensões
    s.order_year,
    s.order_month,
    s.order_quarter,
    c.country_name as customer_country,
    c.continent as customer_continent,
    c.customer_tier,
    e.full_name as sales_rep,
    e.manager_name,
    
    -- Métricas agregadas
    count(distinct s.order_id) as total_orders,
    sum(s.quantity) as total_quantity,
    sum(s.gross_amount) as gross_revenue,
    sum(s.discount_amount) as total_discounts,
    sum(s.net_amount) as net_revenue,
    sum(s.freight_amount) as total_freight,
    
    -- Métricas calculadas
    avg(s.net_amount) as avg_order_value,
    sum(s.net_amount) / nullif(count(distinct s.order_id), 0) as avg_ticket,
    sum(s.discount_amount) / nullif(sum(s.gross_amount), 0) * 100 as discount_percentage,
    
    -- Performance
    sum(s.is_late_shipment) as late_shipments,
    sum(s.is_late_shipment) / nullif(count(distinct s.order_id), 0) * 100 as late_shipment_rate

from sales s
left join customers c on s.customer_sk = c.customer_sk
left join employees e on s.employee_sk = e.employee_sk
group by 1, 2, 3, 4, 5, 6, 7, 8