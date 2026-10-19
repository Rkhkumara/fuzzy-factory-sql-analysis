BEGIN;
INSERT INTO analytics.products
SELECT product_id::INT, created_at::TIMESTAMP, product_name FROM raw.products;

INSERT INTO analytics.website_sessions
SELECT website_session_id::INT, created_at::TIMESTAMP, user_id::INT, is_repeat_session::SMALLINT,
       NULLIF(NULLIF(utm_source,''),'NULL'),
       NULLIF(NULLIF(utm_campaign,''),'NULL'),
       NULLIF(NULLIF(utm_content,''),'NULL'),
       device_type,
       NULLIF(NULLIF(http_referer,''),'NULL')
FROM raw.website_sessions;

INSERT INTO analytics.website_pageviews
SELECT website_pageview_id::INT, created_at::TIMESTAMP, website_session_id::INT, pageview_url
FROM raw.website_pageviews;

INSERT INTO analytics.orders
SELECT order_id::INT, created_at::TIMESTAMP, website_session_id::INT, user_id::INT,
       primary_product_id::INT, items_purchased::SMALLINT, price_usd::NUMERIC, cogs_usd::NUMERIC
FROM raw.orders;

INSERT INTO analytics.order_items
SELECT order_item_id::INT, created_at::TIMESTAMP, order_id::INT, product_id::INT,
       is_primary_item::SMALLINT, price_usd::NUMERIC, cogs_usd::NUMERIC
FROM raw.order_items;

INSERT INTO analytics.order_item_refunds
SELECT order_item_refund_id::INT, created_at::TIMESTAMP, order_item_id::INT, order_id::INT,
       refund_amount_usd::NUMERIC
FROM raw.order_item_refunds;
COMMIT;

SELECT 'products' t, (SELECT COUNT(*) FROM raw.products) raw_n, (SELECT COUNT(*) FROM analytics.products) analytics_n
UNION ALL SELECT 'website_sessions', (SELECT COUNT(*) FROM raw.website_sessions), (SELECT COUNT(*) FROM analytics.website_sessions)
UNION ALL SELECT 'website_pageviews', (SELECT COUNT(*) FROM raw.website_pageviews), (SELECT COUNT(*) FROM analytics.website_pageviews)
UNION ALL SELECT 'orders', (SELECT COUNT(*) FROM raw.orders), (SELECT COUNT(*) FROM analytics.orders)
UNION ALL SELECT 'order_items', (SELECT COUNT(*) FROM raw.order_items), (SELECT COUNT(*) FROM analytics.order_items)
UNION ALL SELECT 'order_item_refunds', (SELECT COUNT(*) FROM raw.order_item_refunds), (SELECT COUNT(*) FROM analytics.order_item_refunds);