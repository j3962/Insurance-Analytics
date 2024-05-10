WITH issuer_details as (
    SELECT 
        *
    FROM 
        {{ source('bronze_layer', 'issuer_details') }}
    WHERE 
        Active = 'YES'
),

CleanedData as (
    SELECT 
    hios_issuer_id,
    REPLACE(COALESCE(marketing_name, issr_lgl_name), '"','') AS marketing_name,
    state,
    individual_market,
    small_group_market,
    large_market,
    federal_ein,
    org_adr1,
    org_adr2,
    org_state,
    CASE 
        WHEN LENGTH(org_zip) = 3 THEN '00' || org_zip
        WHEN LENGTH(org_zip) = 4 THEN '0' || org_zip
        ELSE org_zip
    END AS org_zip
FROM 
   issuer_details
QUALIFY 
    ROW_NUMBER() OVER(PARTITION BY HIOS_ISSUER_ID ORDER BY LAST_MODIFIED_DATE DESC) = 1

)

SELECT
    *
FROM
    CleanedData