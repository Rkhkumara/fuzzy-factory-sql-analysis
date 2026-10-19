-- A. Pilot socialbook vs channel lain (Jan-Mar 2014)
SELECT channel, COUNT(*) AS sesi, SUM(is_converted) AS jumlah_order,
       ROUND(100.0 * SUM(is_converted) / COUNT(*), 2) AS conv_rate_pct
FROM analytics.vw_sessions
WHERE session_month BETWEEN '2014-01-01' AND '2014-03-01'
GROUP BY channel ORDER BY sesi DESC;

-- B. Desktop-targeted vs channel lain (Agu-Des 2014, hanya desktop)
SELECT channel, COUNT(*) AS sesi, SUM(is_converted) AS jumlah_order,
       ROUND(100.0 * SUM(is_converted) / COUNT(*), 2) AS conv_rate_pct
FROM analytics.vw_sessions
WHERE session_month BETWEEN '2014-08-01' AND '2014-12-01' AND device_type = 'desktop'
GROUP BY channel ORDER BY sesi DESC;

-- C. bsearch vs gsearch nonbrand sejak Agustus 2012
SELECT channel, COUNT(*) AS sesi, SUM(is_converted) AS jumlah_order,
       ROUND(100.0 * SUM(is_converted) / COUNT(*), 2) AS conv_rate_pct
FROM analytics.vw_sessions
WHERE channel IN ('gsearch / nonbrand', 'bsearch / nonbrand') AND session_month >= '2012-08-01'
GROUP BY channel;

SELECT order_month, product_name,
       COUNT(*) AS item, SUM(is_refunded) AS item_direfund,
       ROUND(100.0 * SUM(is_refunded) / COUNT(*), 1) AS refund_rate_pct,
       SUM(price_usd) AS pendapatan, SUM(net_margin_usd) AS net_margin,
       ROUND(100.0 * SUM(net_margin_usd) / SUM(price_usd), 1) AS net_margin_pct
FROM analytics.vw_order_items_net
WHERE order_month BETWEEN '2014-05-01' AND '2014-11-01'
GROUP BY order_month, product_name
ORDER BY order_month, product_name;