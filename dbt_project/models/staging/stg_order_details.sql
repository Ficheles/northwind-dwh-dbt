{{
    config(
        materialized='view',
        schema='dwh_staging'
    )
}}

with source as (
    select 
        OrderID,
        ProductID,
        UnitPrice,
        Quantity,
        Discount
    from northwind.`Order Details`
),

renamed as (
    select
        -- Chaves
        OrderID as order_id,
        ProductID as product_id,
        
        -- Valores originais
        UnitPrice as unit_price,
        Quantity as quantity,
        Discount as discount_percent,
        
        -- Campos calculados: Valores financeiros
        (UnitPrice * Quantity) as gross_amount,
        (UnitPrice * Quantity * Discount) as discount_amount,
        (UnitPrice * Quantity) * (1 - Discount) as net_amount,
        
        -- Campo calculado: Faixas de desconto
        case 
            when Discount = 0 then 'No Discount'
            when Discount <= 0.10 then 'Low (1-10%)'
            when Discount <= 0.20 then 'Medium (11-20%)'
            else 'High (>20%)'
        end as discount_tier

    from source
)

select * from renamed