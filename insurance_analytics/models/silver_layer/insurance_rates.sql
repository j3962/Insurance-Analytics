WITH source AS (
    SELECT
        *
    FROM
        {{ source('bronze_layer', 'insurance_rates') }}
)

SELECT
    *
FROM
    source