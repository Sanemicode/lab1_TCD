{{ config(materialized='table') }}

with stg_listeners as (
    select * from {{ ref('stg_listeners') }}
)

select
    listener_id,
    full_name,
    email,
    country,
    registration_date
from stg_listeners
