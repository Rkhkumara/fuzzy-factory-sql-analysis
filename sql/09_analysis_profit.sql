-- 5a. Profitabilitas per produk (seluruh periode)
SELECT product_name,
       COUNT(*) AS item,
       SUM(price_usd) AS pendapatan,
       ROUND(100.0 * SUM(gross_margin_usd) / SUM(price_usd), 1) AS margin_kotor_pct,
       ROUND(100.0 * SUM(is_refunded) / COUNT(*), 1) AS refund_rate_pct,
       SUM(net_margin_usd) AS net_margin,
       ROUND(100.0 * SUM(net_margin_usd) / SUM(price_usd), 1) AS net_margin_pct
FROM analytics.vw_order_items_net
GROUP BY product_name
ORDER BY net_margin DESC;

-- 5b. Apakah lonjakan refund Mr. Fuzzy Agu–Sep 2014 anomali, atau pola yang berulang?
SELECT order_month,
       COUNT(*) AS item,
       SUM(is_refunded) AS item_direfund,
       ROUND(100.0 * SUM(is_refunded) / COUNT(*), 1) AS refund_rate_pct
FROM analytics.vw_order_items_net
WHERE product_name = 'The Original Mr. Fuzzy'
GROUP BY order_month
ORDER BY order_month;

