{{ config(materialized='table') }}

with stg_streams as (
    select * from {{ ref('stg_streams') }}
),

stg_listeners as (
    select * from {{ ref('stg_listeners') }}
),

stg_tracks as (
    select * from {{ ref('stg_tracks') }}
)

select
    s.stream_id,
    s.listener_id,
    s.track_id,
    t.artist_id,
    s.streamed_at,
    s.seconds_played,
    t.duration_sec as track_duration_sec,
    -- частка прослуханого треку, %
    round(
        100.0 * least(s.seconds_played, t.duration_sec) / nullif(t.duration_sec, 0),
        1
    ) as completion_pct,
    s.device
from stg_streams s
-- беремо лише існуючих слухачів і треки (Data Integrity)
join stg_listeners l on s.listener_id = l.listener_id
join stg_tracks t on s.track_id = t.track_id
