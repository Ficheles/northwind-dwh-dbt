{{
    config(
        materialized='table',
        schema='dwh'
    )
}}

with customers as (
    select * from {{ ref('stg_customers') }}
),

-- Agregações para enriquecer a dimensão
customer_orders as (
    select
        customer_id,
        count(*) as total_orders,
        min(order_date) as first_order_date,
        max(order_date) as last_order_date
    from {{ ref('stg_orders') }}
    group by customer_id
),

customer_revenue as (
    select
        o.customer_id,
        sum(od.net_amount) as total_revenue
    from {{ ref('stg_orders') }} o
    join {{ ref('stg_order_details') }} od on o.order_id = od.order_id
    group by o.customer_id
)

select
    -- Surrogate Key
    row_number() over (order by c.customer_id) as customer_sk,
    
    -- Natural Key
    c.customer_id as customer_nk,
    
    -- Atributos
    c.company_name,
    c.contact_name,
    c.contact_title,
    c.address,
    c.city,
    c.region_clean as region,
    c.postal_code,
    c.country_name,
    c.country_code,
    c.continent,
    c.phone,
    c.fax,
    c.has_fax,
    
    -- Métricas desnormalizadas (SCD Type 1)
    coalesce(co.total_orders, 0) as total_orders,
    coalesce(cr.total_revenue, 0) as total_revenue,
    co.first_order_date,
    co.last_order_date,
    
    -- Segmentação calculada
    case 
        when cr.total_revenue >= 10000 then 'Gold'
        when cr.total_revenue >= 5000 then 'Silver'
        else 'Bronze'
    end as customer_tier,
    
    -- Metadados
    current_timestamp() as dw_created_at

from customers c
left join customer_orders co on c.customer_id = co.customer_id
left join customer_revenue cr on c.customer_id = cr.customer_id