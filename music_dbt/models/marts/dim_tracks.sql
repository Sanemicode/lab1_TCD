{{ config(materialized='table') }}

with stg_tracks as (
    select * from {{ ref('stg_tracks') }}
)

select
    track_id,
    artist_id,
    title,
    genre,
    duration_sec,
    release_date
from stg_tracks
