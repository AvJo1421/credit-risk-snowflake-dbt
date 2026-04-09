with source as (
    select * from {{ source('raw', 'previous_application') }}
),
staged as (
    select
        sk_id_prev,
        sk_id_curr,
        name_contract_type,
        amt_annuity,
        amt_application,
        amt_credit,
        amt_goods_price,
        name_contract_status,
        days_decision,
        name_payment_type,
        code_reject_reason
    from source
)
select * from staged