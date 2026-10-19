EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM analytics.website_pageviews WHERE website_session_id = 100000;

CREATE INDEX idx_pageviews_session ON analytics.website_pageviews (website_session_id);
CREATE INDEX idx_orders_session    ON analytics.orders (website_session_id);
ANALYZE analytics.website_pageviews;
ANALYZE analytics.orders;