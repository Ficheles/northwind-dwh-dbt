-- models/staging/stg_customers.sql

{{
    config(
        materialized='view',
        schema='dwh_staging'
    )
}}

with source as (
    select * from {{ source('northwind', 'Customers') }}
),

countries as (
    select * from {{ source('external_data', 'ext_iso_countries') }}
),

renamed as (
    select
        -- Chave Primária
        c.CustomerID as customer_id,
        
        -- Atributos do Cliente
        c.CompanyName as company_name,
        c.ContactName as contact_name,
        c.ContactTitle as contact_title,
        
        -- Endereço (desnormalizado)
        c.Address as address,
        c.City as city,
        c.Region as region,
        c.PostalCode as postal_code,
        c.Country as country_name,
        
        -- Enriquecimento com dados externos
        co.iso_alpha2 as country_code,
        co.iso_alpha3 as country_code_iso3,
        co.continent_name as continent,
        
        -- Contato
        c.Phone as phone,
        c.Fax as fax,
        
        -- Campo calculado: Cliente tem fax?
        case when c.Fax is not null then 1 else 0 end as has_fax,
        
        -- Campo calculado: Região preenchida?
        coalesce(c.Region, 'N/A') as region_clean

    from source c
    left join countries co 
        on upper(trim(c.Country)) = upper(trim(co.country_name_en))
)

select * from renamed