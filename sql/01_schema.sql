CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS analytics;

-- ===== RAW: semua kolom TEXT, apa adanya dari CSV =====
CREATE TABLE raw.products (
  product_id TEXT, created_at TEXT, product_name TEXT);

CREATE TABLE raw.website_sessions (
  website_session_id TEXT, created_at TEXT, user_id TEXT, is_repeat_session TEXT,
  utm_source TEXT, utm_campaign TEXT, utm_content TEXT, device_type TEXT, http_referer TEXT);

CREATE TABLE raw.website_pageviews (
  website_pageview_id TEXT, created_at TEXT, website_session_id TEXT, pageview_url TEXT);

CREATE TABLE raw.orders (
  order_id TEXT, created_at TEXT, website_session_id TEXT, user_id TEXT,
  primary_product_id TEXT, items_purchased TEXT, price_usd TEXT, cogs_usd TEXT);

CREATE TABLE raw.order_items (
  order_item_id TEXT, created_at TEXT, order_id TEXT, product_id TEXT,
  is_primary_item TEXT, price_usd TEXT, cogs_usd TEXT);

CREATE TABLE raw.order_item_refunds (
  order_item_refund_id TEXT, created_at TEXT, order_item_id TEXT,
  order_id TEXT, refund_amount_usd TEXT);

-- ===== ANALYTICS: tipe benar + PK/FK =====
CREATE TABLE analytics.products (
  product_id   INTEGER PRIMARY KEY,
  created_at   TIMESTAMP NOT NULL,
  product_name TEXT NOT NULL);

CREATE TABLE analytics.website_sessions (
  website_session_id INTEGER PRIMARY KEY,
  created_at         TIMESTAMP NOT NULL,
  user_id            INTEGER NOT NULL,
  is_repeat_session  SMALLINT NOT NULL CHECK (is_repeat_session IN (0,1)),
  utm_source TEXT, utm_campaign TEXT, utm_content TEXT,
  device_type TEXT, http_referer TEXT);

CREATE TABLE analytics.website_pageviews (
  website_pageview_id INTEGER PRIMARY KEY,
  created_at          TIMESTAMP NOT NULL,
  website_session_id  INTEGER NOT NULL REFERENCES analytics.website_sessions,
  pageview_url        TEXT NOT NULL);

CREATE TABLE analytics.orders (
  order_id           INTEGER PRIMARY KEY,
  created_at         TIMESTAMP NOT NULL,
  website_session_id INTEGER NOT NULL REFERENCES analytics.website_sessions,
  user_id            INTEGER NOT NULL,
  primary_product_id INTEGER NOT NULL REFERENCES analytics.products,
  items_purchased    SMALLINT NOT NULL,
  price_usd          NUMERIC(10,2) NOT NULL,
  cogs_usd           NUMERIC(10,2) NOT NULL);

CREATE TABLE analytics.order_items (
  order_item_id   INTEGER PRIMARY KEY,
  created_at      TIMESTAMP NOT NULL,
  order_id        INTEGER NOT NULL REFERENCES analytics.orders,
  product_id      INTEGER NOT NULL REFERENCES analytics.products,
  is_primary_item SMALLINT NOT NULL,
  price_usd       NUMERIC(10,2) NOT NULL,
  cogs_usd        NUMERIC(10,2) NOT NULL);

CREATE TABLE analytics.order_item_refunds (
  order_item_refund_id INTEGER PRIMARY KEY,
  created_at           TIMESTAMP NOT NULL,
  order_item_id        INTEGER NOT NULL REFERENCES analytics.order_items,
  order_id             INTEGER NOT NULL REFERENCES analytics.orders,
  refund_amount_usd    NUMERIC(10,2) NOT NULL);