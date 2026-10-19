--Q1
WITH monthly AS (
  SELECT session_month AS bulan,
         COUNT(*) AS sesi,
         SUM(is_converted) AS jumlah_order,
         ROUND(100.0 * SUM(is_converted) / COUNT(*), 2) AS conv_rate_pct
  FROM analytics.vw_sessions
  GROUP BY session_month
),
rev AS (
  SELECT order_month AS bulan,
         SUM(price_usd) AS revenue_usd,
         SUM(net_margin_usd) AS net_margin_usd
  FROM analytics.vw_order_items_net
  GROUP BY order_month
)
SELECT m.bulan, m.sesi, m.jumlah_order, m.conv_rate_pct,
       r.revenue_usd, r.net_margin_usd,
       ROUND(100.0 * (m.sesi - LAG(m.sesi) OVER (ORDER BY m.bulan))
             / NULLIF(LAG(m.sesi) OVER (ORDER BY m.bulan), 0), 1) AS sesi_mom_pct,
       ROUND(100.0 * (r.revenue_usd - LAG(r.revenue_usd) OVER (ORDER BY m.bulan))
             / NULLIF(LAG(r.revenue_usd) OVER (ORDER BY m.bulan), 0), 1) AS revenue_mom_pct
FROM monthly m
LEFT JOIN rev r USING (bulan)
ORDER BY m.bulan;

--Q2
SELECT s.channel_group, s.channel,
       COUNT(*) AS sesi,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pangsa_sesi_pct,
       SUM(s.is_converted) AS jumlah_order,
       ROUND(100.0 * SUM(s.is_converted) / COUNT(*), 2) AS conv_rate_pct,
       ROUND(SUM(COALESCE(o.price_usd, 0)) / COUNT(*), 2) AS revenue_per_sesi,
       ROUND(AVG(o.price_usd), 2) AS rata_rata_nilai_order
FROM analytics.vw_sessions s
LEFT JOIN analytics.orders o ON o.order_id = s.order_id
GROUP BY s.channel_group, s.channel
ORDER BY sesi DESC;

--Additional
SELECT channel, MIN(session_month) AS bulan_pertama, MAX(session_month) AS bulan_terakhir, COUNT(*) AS sesi
FROM analytics.vw_sessions
GROUP BY channel ORDER BY bulan_pertama;