{{
    config(
        materialized='view',
        schema='dwh_staging'
    )
}}

with source as (
    select * from {{ source('northwind', 'Employees') }}
),

renamed as (
    select
        -- Chave
        EmployeeID as employee_id,
        ReportsTo as reports_to_id,
        
        -- Atributos do Funcionário
        LastName as last_name,
        FirstName as first_name,
        concat(FirstName, ' ', LastName) as full_name,
        Title as job_title,
        TitleOfCourtesy as title_of_courtesy,
        
        -- Datas
        BirthDate as birth_date,
        HireDate as hire_date,
        
        -- Campos calculados
        timestampdiff(YEAR, BirthDate, CURDATE()) as age,
        timestampdiff(YEAR, HireDate, CURDATE()) as years_of_service,
        
        -- Endereço
        Address as address,
        City as city,
        Region as region,
        PostalCode as postal_code,
        Country as country,
        
        -- Contato
        HomePhone as home_phone,
        Extension as extension

    from source
)

select * from renamed