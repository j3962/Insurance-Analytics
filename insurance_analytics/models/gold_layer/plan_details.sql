WITH prod_dets AS (
    SELECT
        market_type,
        hios_issuer_id,
        hios_product_id
    FROM 
        {{ ref('product_detail') }} as prod_dets
),
issr_det AS (
    SELECT
        issr_det.hios_issuer_id,
        issr_det.marketing_name,
        issr_det.state
    FROM 
        {{ ref('issuer_detail') }} as issr_det    
),
insr_plns AS (
    SELECT
        hios_product_id,
        plan_marketing_name,
        plan_type,
        level_of_coverage
    FROM
        {{ source('bronze_layer', 'health_insurance_plans') }}
),
st_avg AS (
    SELECT
        age_buckets,
        average_age_bucket_rate,
        state_average,
        no_of_plans,
        state
    FROM    
        {{ ref('state_rate_avg') }}
),
final as (
    SELECT
        issr_det.hios_issuer_id,
        issr_det.marketing_name,
        insr_plns.plan_marketing_name,
        insr_plns.plan_type,
        prod_dets.market_type,
        insr_plns.level_of_coverage,
        issr_det.state,
        st_avg.age_buckets,
        st_avg.average_age_bucket_rate,
        st_avg.state_average,
        no_of_plans
    FROM 
        prod_dets 
    INNER JOIN 
        issr_det 
        ON 
            issr_det.hios_issuer_id = prod_dets.hios_issuer_id
    INNER JOIN 
        insr_plns 
        ON 
            prod_dets.hios_product_id = insr_plns.hios_product_id
    INNER JOIN 
        st_avg 
        ON 
            issr_det.state = st_avg.state
)
SELECT
    *
FROM    
    final