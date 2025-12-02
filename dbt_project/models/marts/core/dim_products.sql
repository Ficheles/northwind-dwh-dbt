{{
    config(
        materialized='table',
        schema='dwh'
    )
}}

with products as (
    select * from {{ ref('stg_products') }}
)

select
    -- Surrogate Key
    row_number() over (order by product_id) as product_sk,
    
    -- Natural Key
    product_id as product_nk,
    
    -- Atributos do Produto
    product_name,
    quantity_per_unit,
    unit_price,
    units_in_stock,
    units_on_order,
    reorder_level,
    is_discontinued,
    needs_reorder,
    price_tier,
    inventory_value,
    
    -- Hierarquia de Categoria (desnormalizada)
    category_id,
    category_name,
    category_description,
    
    -- Hierarquia de Fornecedor (desnormalizada)
    supplier_id,
    supplier_name,
    supplier_country,
    
    -- Metadados
    current_timestamp() as dw_created_at

from products