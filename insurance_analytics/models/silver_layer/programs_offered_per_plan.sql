WITH health_insurance_plans AS (
    SELECT 
        hios_plan_id,
        disease_management_programs_offered
    FROM 
     {{ source('bronze_layer', 'health_insurance_plans') }}
),

CleanedData AS (
    SELECT 
        hios_plan_id,
        value as disease_management_programs_offered
    FROM 
        health_insurance_plans,
        LATERAL SPLIT_TO_TABLE(disease_management_programs_offered, ',')
)

SELECT
    *
FROM
    CleanedData
