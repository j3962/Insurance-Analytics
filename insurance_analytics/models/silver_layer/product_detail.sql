WITH product_detail AS (
    SELECT
        *
    FROM
        {{ source('bronze_layer', 'product_details')}}
    WHERE 
        active = 'YES' 
    AND 
        open_for_enrollment = 'YES'
),

CleanedData AS (
    SELECT 
        HIOS_PRODUCT_ID,
        HIOS_ISSUER_ID,
        REPLACE(product_name, '"', '') AS product_name,
        product_type,
        market_type,
        open_for_enrollment,
        association_product,
        grandfathered_product
    FROM 
        product_detail
)

SELECT
    *
FROM
    CleanedData
    


