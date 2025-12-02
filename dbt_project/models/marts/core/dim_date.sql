{{
    config(
        materialized='table',
        schema='dwh',
        pre_hook="SET SESSION cte_max_recursion_depth = 2000;"
    )
}}

-- Gera uma dimensão de data para o período do Northwind (1996-1998)
with recursive date_spine as (
    select cast('1996-01-01' as date) as date_day
    union all
    select date_add(date_day, interval 1 day)
    from date_spine
    where date_day < '1998-12-31'
)

select
    -- Surrogate Key (YYYYMMDD)
    cast(date_format(date_day, '%Y%m%d') as unsigned) as date_sk,
    
    -- Data completa
    date_day as full_date,
    
    -- Componentes
    year(date_day) as `year`,
    quarter(date_day) as `quarter`,
    month(date_day) as `month`,
    weekofyear(date_day) as week_of_year,
    day(date_day) as day_of_month,
    dayofweek(date_day) as day_of_week,
    dayofyear(date_day) as day_of_year,
    
    -- Nomes
    monthname(date_day) as month_name,
    dayname(date_day) as day_name,
    
    -- Flags
    case when dayofweek(date_day) in (1, 7) then 1 else 0 end as is_weekend,
    
    -- Hierarquias de tempo
    concat(year(date_day), '-Q', quarter(date_day)) as year_qtr,
    date_format(date_day, '%Y-%m') as year_mo

from date_spine