{{
    config(
        materialized='table',
        schema='dwh'
    )
}}

with employees as (
    select * from {{ ref('stg_employees') }}
),

managers as (
    select 
        employee_id,
        full_name as manager_name
    from {{ ref('stg_employees') }}
)

select
    -- Surrogate Key
    row_number() over (order by e.employee_id) as employee_sk,
    
    -- Natural Key
    e.employee_id as employee_nk,
    
    -- Atributos
    e.full_name,
    e.first_name,
    e.last_name,
    e.job_title,
    e.title_of_courtesy,
    e.birth_date,
    e.hire_date,
    e.age,
    e.years_of_service,
    
    -- Hierarquia (auto-relacionamento desnormalizado)
    e.reports_to_id,
    m.manager_name,
    
    -- Localização
    e.city,
    e.region,
    e.country,
    
    -- Metadados
    current_timestamp() as dw_created_at

from employees e
left join managers m on e.reports_to_id = m.employee_id