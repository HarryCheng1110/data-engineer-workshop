SELECT
    CAST(vendorid AS INTEGER) AS vendor_id,
    CAST(ratecodeid AS INTEGER) AS rate_code_id,
    CAST(pulocationid AS INTEGER) AS pickup_location_id,
    CAST(dolocationid AS INTEGER) AS dropoff_location_id,
    CAST(lpep_pickup_datetime AS TIMESTAMP) AS pickup_datetime,
    CAST(lpep_dropoff_datetime AS TIMESTAMP) AS dropoff_datetime,
    store_and_fwd_flag,
    CAST(passenger_count AS INTEGER) AS passenger_count,
    trip_distance,
    CAST(trip_type AS INTEGER) AS trip_type,
    CAST(payment_type AS INTEGER) AS payment_type,
    CAST(fare_amount AS NUMERIC(10, 2)) AS fare_amount,
    CAST(extra AS NUMERIC(10, 2)) AS extra,
    CAST(mta_tax AS NUMERIC(10, 2)) AS mta_tax,
    CAST(tip_amount AS NUMERIC(10, 2)) AS tip_amount,
    CAST(tolls_amount AS NUMERIC(10, 2)) AS tolls_amount,
    CAST(ehail_fee AS NUMERIC(10, 2)) AS ehail_fee,
    CAST(improvement_surcharge AS NUMERIC(10, 2)) AS improvement_surcharge,
    CAST(total_amount AS NUMERIC(10, 2)) AS total_amount
FROM {{ source('raw_data', 'green_tripdata') }}
WHERE vendorid IS NOT NULL