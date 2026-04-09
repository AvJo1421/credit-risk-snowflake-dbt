with source as (
    select * from {{ source('raw', 'app_train') }}
),

staged as (
    select
        sk_id_curr,
        target,
        name_contract_type,
        code_gender,
        flag_own_car,
        flag_own_realty,
        cnt_children,
        amt_income_total,
        amt_credit,
        amt_annuity,
        amt_goods_price,
        name_income_type,
        name_education_type,
        name_family_status,
        name_housing_type,
        days_birth,
        days_employed,
        region_rating_client,
        reg_city_not_live_city,
        reg_city_not_work_city
    from source
)

select * from staged