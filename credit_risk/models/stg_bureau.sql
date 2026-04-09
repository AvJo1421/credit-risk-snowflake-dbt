with source as (
    select * from {{ source('raw', 'bureau') }}
),
staged as (
    select
        sk_id_curr,
        sk_id_bureau,
        credit_active,
        credit_currency,
        days_credit,
        credit_day_overdue,
        days_credit_enddate,
        amt_credit_sum,
        amt_credit_sum_debt,
        amt_credit_sum_overdue,
        cnt_credit_prolong
    from source
)
select * from staged