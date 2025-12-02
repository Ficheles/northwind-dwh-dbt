{{
    config(
        materialized='view',
        schema='dwh_staging'
    )
}}

with source as (
    select * from {{ source('northwind', 'Products') }}
),

categories as (
    select * from {{ source('northwind', 'Categories') }}
),

suppliers as (
    select * from {{ source('northwind', 'Suppliers') }}
),

renamed as (
    select
        -- Chaves
        p.ProductID as product_id,
        p.CategoryID as category_id,
        p.SupplierID as supplier_id,
        
        -- Atributos do Produto
        p.ProductName as product_name,
        p.QuantityPerUnit as quantity_per_unit,
        p.UnitPrice as unit_price,
        p.UnitsInStock as units_in_stock,
        p.UnitsOnOrder as units_on_order,
        p.ReorderLevel as reorder_level,
        p.Discontinued as is_discontinued,
        
        -- Desnormalização: Categoria
        c.CategoryName as category_name,
        c.Description as category_description,
        
        -- Desnormalização: Fornecedor
        s.CompanyName as supplier_name,
        s.Country as supplier_country,
        
        -- Campos calculados
        case 
            when p.UnitsInStock <= p.ReorderLevel then 1 
            else 0 
        end as needs_reorder,
        
        case 
            when p.UnitPrice < 20 then 'Budget'
            when p.UnitPrice < 50 then 'Standard'
            else 'Premium'
        end as price_tier,
        
        (p.UnitsInStock * p.UnitPrice) as inventory_value

    from source p
    left join categories c on p.CategoryID = c.CategoryID
    left join suppliers s on p.SupplierID = s.SupplierID
)

select * from renamed