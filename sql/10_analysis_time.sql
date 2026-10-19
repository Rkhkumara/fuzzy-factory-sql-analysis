-- 6a. Per jam
SELECT EXTRACT(HOUR FROM ws.created_at)::int AS jam,
       COUNT(*) AS sesi,
       SUM(v.is_converted) AS jumlah_order,
       ROUND(100.0 * SUM(v.is_converted) / COUNT(*), 2) AS conv_rate_pct
FROM analytics.website_sessions ws
JOIN analytics.vw_sessions v USING (website_session_id)
WHERE ws.created_at >= '2014-01-01' AND ws.created_at < '2015-01-01'
GROUP BY 1
ORDER BY 1;

-- 6b. Per hari dalam seminggu (1 = Senin ... 7 = Minggu)
SELECT EXTRACT(ISODOW FROM ws.created_at)::int AS hari,
       COUNT(*) AS sesi,
       SUM(v.is_converted) AS jumlah_order,
       ROUND(100.0 * SUM(v.is_converted) / COUNT(*), 2) AS conv_rate_pct
FROM analytics.website_sessions ws
JOIN analytics.vw_sessions v USING (website_session_id)
WHERE ws.created_at >= '2014-01-01' AND ws.created_at < '2015-01-01'
GROUP BY 1
ORDER BY 1;