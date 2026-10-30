with source as (
    select * from {{ source('raw_music', 'listeners') }}
),

-- у raw є дублікати слухачів: лишаємо по одному запису на listener_id
deduplicated as (
    select
        *,
        row_number() over (
            partition by listener_id
            order by registration_date
        ) as rn
    from source
),

cleaned as (
    select
        listener_id,
        full_name,
        -- обробка пропущених email
        coalesce(email, 'unknown@example.com') as email,
        country,
        cast(registration_date as date) as registration_date
    from deduplicated
    where rn = 1
)

select * from cleaned
