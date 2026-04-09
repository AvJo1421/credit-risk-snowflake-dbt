with source as (
    select * from {{ source('raw', 'pos_cash_balance') }}
),
staged as (
    select
        sk_id_prev,
        sk_id_curr,
        months_balance,
        cnt_instalment,
        cnt_instalment_future,
        name_contract_status,
        sk_dpd,
        sk_dpd_def
    from source
)
select * from staged