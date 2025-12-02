{{
    config(
        materialized='view',
        schema='dwh_staging'
    )
}}

with source as (
    select * from {{ source('northwind', 'Orders') }}
),

renamed as (
    select
        -- Chaves
        OrderID as order_id,
        CustomerID as customer_id,
        EmployeeID as employee_id,
        ShipVia as shipper_id,
        
        -- Datas
        OrderDate as order_date,
        RequiredDate as required_date,
        ShippedDate as shipped_date,
        
        -- Campos calculados: Métricas de tempo
        datediff(ShippedDate, OrderDate) as days_to_ship,
        datediff(RequiredDate, OrderDate) as days_required,
        case 
            when ShippedDate > RequiredDate then 1 
            else 0 
        end as is_late_shipment,
        
        -- Valores
        Freight as freight_amount,
        
        -- Endereço de entrega (desnormalizado)
        ShipName as ship_name,
        ShipAddress as ship_address,
        ShipCity as ship_city,
        ShipRegion as ship_region,
        ShipPostalCode as ship_postal_code,
        ShipCountry as ship_country,
        
        -- Campo calculado: Status do pedido
        case 
            when ShippedDate is null then 'Pending'
            when ShippedDate <= RequiredDate then 'On Time'
            else 'Late'
        end as order_status,
        
        -- Campo calculado: Ano/Mês para análise temporal
        year(OrderDate) as order_year,
        month(OrderDate) as order_month,
        quarter(OrderDate) as order_quarter

    from source
)

select * from renamed