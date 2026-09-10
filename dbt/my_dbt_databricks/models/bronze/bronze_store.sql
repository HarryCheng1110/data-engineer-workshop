SELECT
    *,
    _metadata.file_path AS file_location,
    CURRENT_TIMESTAMP() AS ingested_at
FROM {{ source('source', 'dim_store')}}