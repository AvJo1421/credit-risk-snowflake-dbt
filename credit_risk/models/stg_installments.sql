with source as (
    select * from {{ source('raw', 'installments_payments') }}
),
staged as (
    select
        sk_id_prev,
        sk_id_curr,
        num_instalment_version,
        num_instalment_number,
        days_instalment,
        days_entry_payment,
        amt_instalment,
        amt_payment
    from source
)
select * from staged