SELECT
    gender,
    ROUND(SUM(gross_amount), 2) AS total_gross_amount,
    ROUND(SUM(net_amount), 2) AS total_net_amount,
    COUNT( DISTINCT sales_id) AS total_sales_count,
    ROUND(SUM(gross_amount) / COUNT( DISTINCT sales_id), 2) AS avg_gross_amount_per_sale,
    ROUND(SUM(net_amount) / COUNT( DISTINCT sales_id), 2) AS avg_net_amount_per_sale
FROM {{ ref('silver_sales_info') }}
GROUP BY gender