-- Query 4a: konversi per device
SELECT device_type,
       COUNT(*) AS sesi,
       SUM(is_converted) AS jumlah_order,
       ROUND(100.0 * SUM(is_converted) / COUNT(*), 2) AS conv_rate_pct
FROM analytics.vw_sessions
GROUP BY device_type
ORDER BY sesi DESC;

-- Query 4b: di langkah funnel mana beda device paling besar
SELECT s.device_type,
       SUM(f.s1_landing) AS landing,
       ROUND(100.0 * SUM(f.s2_products)     / SUM(f.s1_landing),     1) AS ke_products_pct,
       ROUND(100.0 * SUM(f.s3_product_page) / SUM(f.s2_products),    1) AS ke_product_page_pct,
       ROUND(100.0 * SUM(f.s4_cart)         / SUM(f.s3_product_page),1) AS ke_cart_pct,
       ROUND(100.0 * SUM(f.s5_shipping)     / SUM(f.s4_cart),        1) AS ke_shipping_pct,
       ROUND(100.0 * SUM(f.s6_billing)      / SUM(f.s5_shipping),    1) AS ke_billing_pct,
       ROUND(100.0 * SUM(f.s7_thank_you)    / SUM(f.s6_billing),     1) AS ke_thank_you_pct
FROM analytics.vw_sessions s
JOIN analytics.vw_session_funnel f USING (website_session_id)
GROUP BY s.device_type
ORDER BY landing DESC;

-- Query 4c: cek apakah bsearch = gsearch tetap benar setelah dipecah per device
SELECT channel, device_type,
       COUNT(*) AS sesi,
       SUM(is_converted) AS jumlah_order,
       ROUND(100.0 * SUM(is_converted) / COUNT(*), 2) AS conv_rate_pct
FROM analytics.vw_sessions
WHERE channel IN ('gsearch / nonbrand', 'bsearch / nonbrand')
  AND session_month >= '2012-08-01'
GROUP BY channel, device_type
ORDER BY device_type, channel;