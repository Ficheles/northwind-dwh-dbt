{{
    config(
        materialized='table',
        schema='dwh_mart_customers'
    )
}}

/*
    DATA MART: CLIENTES
    
    Objetivo: Análise de comportamento e valor do cliente (Customer Analytics).
    
    Dimensões:
    - dim_customers (cliente/região)
    - dim_date (tempo)
    
    Métricas:
    - RFM (Recency, Frequency, Monetary), LTV, churn risk
*/

with sales as (
    select * from {{ ref('fct_sales') }}
),

customers as (
    select * from {{ ref('dim_customers') }}
),

customer_metrics as (
    select
        s.customer_sk,
        count(distinct s.order_id) as total_orders,
        sum(s.net_amount) as total_revenue,
        avg(s.net_amount) as avg_order_value,
        min(s.order_date_sk) as first_order_date_sk,
        max(s.order_date_sk) as last_order_date_sk,
        count(distinct s.order_year || '-' || s.order_month) as active_months
    from sales s
    group by s.customer_sk
)

select
    -- Dimensões do Cliente
    c.customer_nk as customer_id,
    c.company_name,
    c.contact_name,
    c.city,
    c.country_name,
    c.continent,
    c.customer_tier,
    
    -- Métricas RFM
    cm.total_orders as frequency,
    cm.total_revenue as monetary,
    cm.last_order_date_sk as recency_date,
    
    -- Métricas de valor
    cm.avg_order_value,
    cm.total_revenue / nullif(cm.active_months, 0) as monthly_avg_revenue,
    
    -- Segmentação RFM
    case 
        when cm.total_orders >= 10 and cm.total_revenue >= 10000 then 'Champions'
        when cm.total_orders >= 5 and cm.total_revenue >= 5000 then 'Loyal Customers'
        when cm.total_orders >= 3 then 'Potential Loyalists'
        when cm.total_orders = 1 then 'New Customers'
        else 'At Risk'
    end as rfm_segment,
    
    -- Métricas de engajamento
    cm.active_months,
    cm.first_order_date_sk,
    cm.last_order_date_sk,
    
    -- Metadados
    current_timestamp() as dw_created_at

from customers c
join customer_metrics cm on c.customer_sk = cm.customer_sk