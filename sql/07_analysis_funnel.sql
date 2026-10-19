SELECT * FROM analytics.vw_session_funnel LIMIT 5;

WITH f AS (
  SELECT
    COUNT(*)              AS sesi_total,
    SUM(s1_landing)       AS landing,
    SUM(s2_products)      AS products,
    SUM(s3_product_page)  AS product_page,
    SUM(s4_cart)          AS cart,
    SUM(s5_shipping)      AS shipping,
    SUM(s6_billing)       AS billing,
    SUM(s7_thank_you)     AS thank_you
  FROM analytics.vw_session_funnel
)
SELECT *,
  ROUND(100.0 * products     / landing,      1) AS lolos_ke_products_pct,
  ROUND(100.0 * product_page / products,     1) AS lolos_ke_product_page_pct,
  ROUND(100.0 * cart         / product_page, 1) AS lolos_ke_cart_pct,
  ROUND(100.0 * shipping     / cart,         1) AS lolos_ke_shipping_pct,
  ROUND(100.0 * billing      / shipping,     1) AS lolos_ke_billing_pct,
  ROUND(100.0 * thank_you    / billing,      1) AS lolos_ke_thank_you_pct
FROM f;

SELECT
  EXTRACT(YEAR FROM s.session_month)::int AS tahun,
  SUM(f.s1_landing) AS landing,
  ROUND(100.0 * SUM(f.s2_products)     / SUM(f.s1_landing),     1) AS ke_products_pct,
  ROUND(100.0 * SUM(f.s3_product_page) / SUM(f.s2_products),    1) AS ke_product_page_pct,
  ROUND(100.0 * SUM(f.s4_cart)         / SUM(f.s3_product_page),1) AS ke_cart_pct,
  ROUND(100.0 * SUM(f.s5_shipping)     / SUM(f.s4_cart),        1) AS ke_shipping_pct,
  ROUND(100.0 * SUM(f.s6_billing)      / SUM(f.s5_shipping),    1) AS ke_billing_pct,
  ROUND(100.0 * SUM(f.s7_thank_you)    / SUM(f.s6_billing),     1) AS ke_thank_you_pct
FROM analytics.vw_session_funnel f
JOIN analytics.vw_sessions s USING (website_session_id)
GROUP BY 1
ORDER BY 1;

SELECT
  EXTRACT(YEAR FROM s.session_month)::int AS tahun,
  COUNT(*)                                AS sesi,
  SUM(s.is_converted)                     AS order_dari_vw_sessions,
  SUM(f.s7_thank_you)                     AS thank_you_dari_funnel,
  ROUND(100.0 * SUM(s.is_converted) / COUNT(*), 2)        AS conv_pct_vw_sessions,
  ROUND(100.0 * SUM(f.s7_thank_you) / SUM(f.s1_landing), 2) AS conv_pct_funnel
FROM analytics.vw_sessions s
JOIN analytics.vw_session_funnel f USING (website_session_id)
GROUP BY 1
ORDER BY 1;