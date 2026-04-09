with app as (
    select * from {{ ref('stg_app_train') }}
),

bureau_agg as (
    select
        sk_id_curr,
        count(*) as bureau_loan_count,
        avg(days_credit) as avg_days_credit,
        sum(amt_credit_sum) as total_credit_sum,
        sum(amt_credit_sum_debt) as total_credit_debt,
        sum(amt_credit_sum_overdue) as total_credit_overdue,
        sum(cnt_credit_prolong) as total_credit_prolonged
    from {{ ref('stg_bureau') }}
    group by sk_id_curr
),

prev_app_agg as (
    select
        sk_id_curr,
        count(*) as prev_application_count,
        avg(amt_credit) as avg_prev_credit,
        avg(amt_annuity) as avg_prev_annuity,
        sum(case when name_contract_status = 'Refused' then 1 else 0 end) as prev_refused_count,
        sum(case when name_contract_status = 'Approved' then 1 else 0 end) as prev_approved_count
    from {{ ref('stg_previous_application') }}
    group by sk_id_curr
),

installments_agg as (
    select
        sk_id_curr,
        count(*) as installment_count,
        avg(amt_payment) as avg_payment,
        sum(case when days_entry_payment > days_instalment then 1 else 0 end) as late_payment_count
    from {{ ref('stg_installments') }}
    group by sk_id_curr
),

final as (
    select
        app.sk_id_curr,
        app.target,
        app.name_contract_type,
        app.code_gender,
        app.flag_own_car,
        app.flag_own_realty,
        app.cnt_children,
        app.amt_income_total,
        app.amt_credit,
        app.amt_annuity,
        app.days_birth,
        app.days_employed,
        app.region_rating_client,
        coalesce(bureau_agg.bureau_loan_count, 0) as bureau_loan_count,
        coalesce(bureau_agg.total_credit_sum, 0) as total_credit_sum,
        coalesce(bureau_agg.total_credit_debt, 0) as total_credit_debt,
        coalesce(bureau_agg.total_credit_overdue, 0) as total_credit_overdue,
        coalesce(prev_app_agg.prev_application_count, 0) as prev_application_count,
        coalesce(prev_app_agg.prev_refused_count, 0) as prev_refused_count,
        coalesce(prev_app_agg.prev_approved_count, 0) as prev_approved_count,
        coalesce(installments_agg.installment_count, 0) as installment_count,
        coalesce(installments_agg.avg_payment, 0) as avg_payment,
        coalesce(installments_agg.late_payment_count, 0) as late_payment_count
    from app
    left join bureau_agg on app.sk_id_curr = bureau_agg.sk_id_curr
    left join prev_app_agg on app.sk_id_curr = prev_app_agg.sk_id_curr
    left join installments_agg on app.sk_id_curr = installments_agg.sk_id_curr
)

select * from final