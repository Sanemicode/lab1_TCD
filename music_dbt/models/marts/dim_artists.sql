{{ config(materialized='table') }}

with stg_artists as (
    select * from {{ ref('stg_artists') }}
)

select
    artist_id,
    artist_name,
    country,
    debut_year
from stg_artists
