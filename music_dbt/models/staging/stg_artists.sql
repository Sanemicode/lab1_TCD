with source as (
    select * from {{ source('raw_music', 'artists') }}
)

select
    artist_id,
    artist_name,
    country,
    debut_year
from source
