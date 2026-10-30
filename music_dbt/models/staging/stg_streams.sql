with source as (
    select * from {{ source('raw_music', 'streams') }}
)

select
    stream_id,
    listener_id,
    track_id,
    cast(stream_ts as timestamp) as streamed_at,
    seconds_played,
    -- пропущений пристрій позначаємо явно
    coalesce(device, 'unknown') as device
from source
