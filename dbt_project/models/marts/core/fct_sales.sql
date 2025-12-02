{{
    config(
        materialized='table',
        schema='dwh'
    )
}}

with orders as (
    select * from {{ ref('stg_orders') }}
),

order_details as (
    select * from {{ ref('stg_order_details') }}
),

dim_customers as (
    select customer_sk, customer_nk from {{ ref('dim_customers') }}
),

dim_products as (
    select product_sk, product_nk from {{ ref('dim_products') }}
),

dim_employees as (
    select employee_sk, employee_nk from {{ ref('dim_employees') }}
)

select
    -- Surrogate Keys (para joins com dimensões)
    dc.customer_sk,
    dp.product_sk,
    de.employee_sk,
    cast(date_format(o.order_date, '%Y%m%d') as unsigned) as order_date_sk,
    cast(date_format(o.shipped_date, '%Y%m%d') as unsigned) as shipped_date_sk,
    
    -- Natural Keys (degenerate dimensions)
    o.order_id,
    od.product_id,
    o.shipper_id,
    
    -- Métricas
    od.quantity,
    od.unit_price,
    od.discount_percent,
    od.gross_amount,
    od.discount_amount,
    od.net_amount,
    o.freight_amount,
    
    -- Atributos do pedido (degenerate)
    o.order_status,
    o.days_to_ship,
    o.is_late_shipment,
    od.discount_tier,
    
    -- Granularidade temporal
    o.order_year,
    o.order_month,
    o.order_quarter,
    
    -- Metadados
    current_timestamp() as dw_created_at

from orders o
join order_details od on o.order_id = od.order_id
left join dim_customers dc on o.customer_id = dc.customer_nk
left join dim_products dp on od.product_id = dp.product_nk
left join dim_employees de on o.employee_id = de.employee_nk