-- View 1: satu baris per sesi, dengan klasifikasi channel dan flag konversi
-- Aman di-JOIN ke orders karena satu sesi paling banyak satu order (Q9 = 0)
CREATE OR REPLACE VIEW analytics.vw_sessions AS
SELECT
  s.website_session_id,
  s.created_at,
  DATE_TRUNC('month', s.created_at)::date AS session_month,
  s.user_id,
  s.is_repeat_session,
  s.device_type,
  s.utm_source, s.utm_campaign, s.utm_content,
  CASE
    WHEN s.utm_source IS NULL AND s.http_referer IS NULL THEN 'direct'
    WHEN s.utm_source IS NULL THEN 'organic_search'
    ELSE s.utm_source || ' / ' || s.utm_campaign
  END AS channel,
  CASE
    WHEN s.utm_source IS NULL AND s.http_referer IS NULL THEN 'direct'
    WHEN s.utm_source IS NULL THEN 'organic_search'
    WHEN s.utm_source IN ('gsearch','bsearch') THEN 'paid_search'
    WHEN s.utm_source = 'socialbook' THEN 'paid_social'
    ELSE 'other'
  END AS channel_group,
  o.order_id,
  CASE WHEN o.order_id IS NOT NULL THEN 1 ELSE 0 END AS is_converted
FROM analytics.website_sessions s
LEFT JOIN analytics.orders o ON o.website_session_id = s.website_session_id;

-- View 2: satu baris per item, dengan refund yang SUDAH diagregasi (mencegah fan-out)
-- Asumsi: net_margin = harga - cogs - refund (biaya produk dianggap tidak kembali saat refund)
CREATE OR REPLACE VIEW analytics.vw_order_items_net AS
SELECT
  i.order_item_id, i.order_id, i.product_id, p.product_name,
  i.created_at,
  DATE_TRUNC('month', i.created_at)::date AS order_month,
  i.is_primary_item,
  i.price_usd, i.cogs_usd,
  COALESCE(r.refund_amount_usd, 0) AS refund_usd,
  i.price_usd - i.cogs_usd AS gross_margin_usd,
  i.price_usd - i.cogs_usd - COALESCE(r.refund_amount_usd, 0) AS net_margin_usd,
  CASE WHEN r.order_item_id IS NOT NULL THEN 1 ELSE 0 END AS is_refunded
FROM analytics.order_items i
JOIN analytics.products p ON p.product_id = i.product_id
LEFT JOIN (
  SELECT order_item_id, SUM(refund_amount_usd) AS refund_amount_usd
  FROM analytics.order_item_refunds
  GROUP BY order_item_id
) r ON r.order_item_id = i.order_item_id;

-- View 3: flag langkah funnel per sesi (apakah sesi pernah mengunjungi tiap langkah)
-- Penyederhanaan: tidak memeriksa urutan waktu antar langkah
CREATE OR REPLACE VIEW analytics.vw_session_funnel AS
SELECT
  website_session_id,
  MAX(CASE WHEN pageview_url IN ('/home','/lander-1','/lander-2','/lander-3','/lander-4','/lander-5') THEN 1 ELSE 0 END) AS s1_landing,
  MAX(CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END) AS s2_products,
  MAX(CASE WHEN pageview_url LIKE '/the-%' THEN 1 ELSE 0 END) AS s3_product_page,
  MAX(CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END) AS s4_cart,
  MAX(CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END) AS s5_shipping,
  MAX(CASE WHEN pageview_url IN ('/billing','/billing-2') THEN 1 ELSE 0 END) AS s6_billing,
  MAX(CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END) AS s7_thank_you
FROM analytics.website_pageviews
GROUP BY website_session_id;

-- Run satu persatu
SELECT COUNT(*) AS jumlah_sesi, SUM(is_converted) AS jumlah_order FROM analytics.vw_sessions;
-- harus: 472871 dan 32313

SELECT COUNT(*) AS jumlah_item, SUM(refund_usd) AS total_refund FROM analytics.vw_order_items_net;
SELECT SUM(refund_amount_usd) AS total_refund_tabel FROM analytics.order_item_refunds;
-- jumlah_item harus 40025, dan kedua total refund harus sama persis

SELECT COUNT(*) AS jumlah_sesi, SUM(s7_thank_you) AS sampai_checkout FROM analytics.vw_session_funnel;
-- harus: 472871 dan 32313

SELECT COUNT(*) AS jumlah_item, SUM(refund_usd) AS total_refund
FROM analytics.vw_order_items_net;