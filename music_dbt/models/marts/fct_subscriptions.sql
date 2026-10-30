{{ config(materialized='table') }}

with stg_subscriptions as (
    select * from {{ ref('stg_subscriptions') }}
),

stg_listeners as (
    select * from {{ ref('stg_listeners') }}
)

select
    sub.subscription_id,
    sub.listener_id,
    sub.plan,
    sub.amount,
    sub.paid_at,
    sub.payment_status,
    sub.promo_code
from stg_subscriptions sub
join stg_listeners l on sub.listener_id = l.listener_id
