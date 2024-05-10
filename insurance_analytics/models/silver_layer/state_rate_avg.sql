WITH CleanedData AS (
    SELECT 
        plan_id,
        issur_dt.state,
        INDIVIDUAL_RATE,
        CASE 
            WHEN age = '0-14' THEN 14
            WHEN age = '64 and over' THEN 64
            ELSE CAST(age AS INTEGER)
        END AS age_int
    FROM 
        {{ ref('insurance_rates') }} insur_rt 
    INNER JOIN 
        {{ ref('issuer_detail') }} issur_dt
    ON 
        (insur_rt.hios_issuer_id = issur_dt.hios_issuer_id)
    WHERE 
        age != 'Family-Tier Rates'
),
age_buckets AS (
    SELECT 
        state, 
        INDIVIDUAL_RATE, 
        age_int,
        CASE 
            WHEN age_int <= 15 THEN '0-15'
            WHEN age_int BETWEEN 16 AND 31 THEN '16-31'
            WHEN age_int BETWEEN 32 AND 47 THEN '32-47'
            WHEN age_int BETWEEN 48 AND 63 THEN '48-64'
            WHEN age_int = 64 THEN '64 and above'
            ELSE 'Unknown'
        END AS age_buckets
    FROM 
        CleanedData
),
plans_per_state AS (
    SELECT 
        COUNT(DISTINCT plan_id) AS no_of_plans, 
        state 
    FROM 
        CleanedData 
    GROUP BY 
        state
),
state_average AS (
    SELECT 
        state, 
        ROUND(AVG(INDIVIDUAL_RATE)) AS state_average 
    FROM 
        age_buckets 
    GROUP BY 
        state
)
SELECT 
    ag_bkts.state,
    age_buckets,
    ROUND(AVG(INDIVIDUAL_RATE)) AS average_age_bucket_rate,
    MAX(state_average) AS state_average,
    MAX(no_of_plans) AS no_of_plans
FROM 
    age_buckets ag_bkts 
INNER JOIN 
    state_average st_avg ON (ag_bkts.state = st_avg.state)
INNER JOIN 
    plans_per_state pln_pr_st ON (ag_bkts.state = pln_pr_st.state)
GROUP BY 
    ag_bkts.state, 
    age_buckets
ORDER BY 
    ag_bkts.state, 
    age_buckets
