with source as (
    select * from {{ source('raw_music', 'subscriptions') }}
)

select
    subscription_id,
    listener_id,
    plan,
    -- сума оплати не може бути від'ємною
    greatest(amount, 0) as amount,
    cast(payment_date as timestamp) as paid_at,
    payment_status,
    coalesce(promo_code, 'NONE') as promo_code
from source
