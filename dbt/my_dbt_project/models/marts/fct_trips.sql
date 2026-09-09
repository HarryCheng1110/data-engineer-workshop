{{ 
    config(
        materialized='incremental',
        unique_key='trip_id',
        incremental_strategy='merge',
        on_schema_change='append_new_columns'
    ) 
}}

WITH trips_unioned AS (
    SELECT * 
    FROM {{ ref('int_trips_unioned') }}
)