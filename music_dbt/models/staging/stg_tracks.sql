with source as (
    select * from {{ source('raw_music', 'tracks') }}
)

select
    track_id,
    artist_id,
    title,
    genre,
    -- тривалість не може бути від'ємною
    greatest(duration_sec, 0) as duration_sec,
    cast(release_date as date) as release_date
from source
