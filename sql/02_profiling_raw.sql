-- 1. Jumlah baris
SELECT 'products' t, COUNT(*) FROM raw.products UNION ALL
SELECT 'website_sessions', COUNT(*) FROM raw.website_sessions UNION ALL
SELECT 'website_pageviews', COUNT(*) FROM raw.website_pageviews UNION ALL
SELECT 'orders', COUNT(*) FROM raw.orders UNION ALL
SELECT 'order_items', COUNT(*) FROM raw.order_items UNION ALL
SELECT 'order_item_refunds', COUNT(*) FROM raw.order_item_refunds;

-- 2. Rentang tanggal
SELECT 'sessions' t, MIN(created_at), MAX(created_at) FROM raw.website_sessions UNION ALL
SELECT 'orders', MIN(created_at), MAX(created_at) FROM raw.orders UNION ALL
SELECT 'refunds', MIN(created_at), MAX(created_at) FROM raw.order_item_refunds;

-- 3. Nilai kosong di kolom kampanye (direct/organic = kosong?)
SELECT
  COUNT(*) FILTER (WHERE utm_source IS NULL)           AS src_null,
  COUNT(*) FILTER (WHERE utm_source = '')              AS src_empty,
  COUNT(*) FILTER (WHERE utm_source = 'NULL')          AS src_text_null,
  COUNT(*)                                             AS total
FROM raw.website_sessions;

-- 4. Nilai unik kolom kategori
--4a Sumber traffic dan kampanye
SELECT utm_source, utm_campaign, COUNT(*) 
FROM raw.website_sessions 
GROUP BY 1,2 ORDER BY 3 DESC;

--4b Jenis perangkat
SELECT device_type, COUNT(*) 
FROM raw.website_sessions 
GROUP BY 1;

-- 5. Duplikat primary key
SELECT 'orders' t, COUNT(*) - COUNT(DISTINCT order_id) dup FROM raw.orders UNION ALL
SELECT 'sessions', COUNT(*) - COUNT(DISTINCT website_session_id) FROM raw.website_sessions UNION ALL
SELECT 'order_items', COUNT(*) - COUNT(DISTINCT order_item_id) FROM raw.order_items UNION ALL
SELECT 'refunds', COUNT(*) - COUNT(DISTINCT order_item_refund_id) FROM raw.order_item_refunds;

-- 6. Baris yatim (orphan)
-- Q6a: order tanpa sesi
SELECT COUNT(*) AS orders_tanpa_sesi 
FROM raw.orders o
LEFT JOIN raw.website_sessions s ON s.website_session_id = o.website_session_id
WHERE s.website_session_id IS NULL;
-- Q6b: item tanpa order
SELECT COUNT(*) AS item_tanpa_order 
FROM raw.order_items i
LEFT JOIN raw.orders o ON o.order_id = i.order_id 
WHERE o.order_id IS NULL;
-- Q6c: refund tanpa item
SELECT COUNT(*) AS refund_tanpa_item 
FROM raw.order_item_refunds r
LEFT JOIN raw.order_items i ON i.order_item_id = r.order_item_id 
WHERE i.order_item_id IS NULL;

-- 7. Nilai non-numerik di kolom uang
SELECT COUNT(*) FROM raw.order_items WHERE price_usd !~ '^\d+(\.\d+)?$' OR cogs_usd !~ '^\d+(\.\d+)?$';

-- 8. Konsistensi: total harga order vs jumlah harga item-nya
SELECT COUNT(*) AS order_tidak_cocok
FROM raw.orders o
JOIN (SELECT order_id, SUM(price_usd::numeric) p, COUNT(*) n
      FROM raw.order_items GROUP BY order_id) i ON i.order_id = o.order_id
WHERE o.price_usd::numeric <> i.p OR o.items_purchased::int <> i.n;

-- 9. Apakah satu sesi bisa punya lebih dari satu order?
SELECT COUNT(*) AS sesi_dengan_banyak_order
FROM (SELECT website_session_id FROM raw.orders
      GROUP BY website_session_id HAVING COUNT(*) > 1) x;

-- 10. Sesi yang tidak punya pageview sama sekali
SELECT COUNT(*) AS sesi_tanpa_pageview
FROM raw.website_sessions s
LEFT JOIN raw.website_pageviews p ON p.website_session_id = s.website_session_id
WHERE p.website_session_id IS NULL;
-- Query C: referer untuk sesi tanpa kampanye
SELECT http_referer, COUNT(*) 
FROM raw.website_sessions
WHERE utm_source = 'NULL'
GROUP BY 1 ORDER BY 2 DESC;

-- D1: lima baris pertama orders (bandingkan dengan CSV: order 1 → sesi 20)
SELECT order_id, website_session_id, user_id, 
       LENGTH(website_session_id) AS panjang,
       website_session_id ~ '^[0-9]+$' AS angka_saja
FROM raw.orders ORDER BY order_id::int LIMIT 5;

-- D2: lima baris pertama sesi
SELECT website_session_id, LENGTH(website_session_id) AS panjang
FROM raw.website_sessions ORDER BY website_session_id::int LIMIT 5;

-- D3: tes JOIN langsung (seharusnya 32313 kalau normal)
SELECT COUNT(*) AS cocok
FROM raw.orders o
JOIN raw.website_sessions s ON s.website_session_id = o.website_session_id;