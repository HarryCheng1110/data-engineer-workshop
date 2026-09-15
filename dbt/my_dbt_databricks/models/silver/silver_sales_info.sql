WITH sales AS (
    SELECT
        sales_id,
        product_sk,
        customer_sk,
        {{ multiply('unit_price', 'quantity') }} AS gross_amount,
        net_amount,
        payment_method
    FROM {{ ref('bronze_sales') }}
), product AS (
    SELECT
        product_sk,
        product_name,
        category
    FROM {{ ref('bronze_product') }}
), customer AS (
    SELECT
        customer_sk,
        gender,
        loyalty_tier
    FROM {{ ref('bronze_customer') }}
)
SELECT
    s.sales_id,
    s.product_sk,
    p.product_name,
    p.category,
    c.gender,
    c.loyalty_tier,
    s.payment_method,
    s.gross_amount,
    s.net_amount
FROM sales s
LEFT JOIN product p ON s.product_sk = p.product_sk
LEFT JOIN customer c ON s.customer_sk = c.customer_sk