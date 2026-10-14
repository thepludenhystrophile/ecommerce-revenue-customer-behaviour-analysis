-- Objectives:
--   1. Analyse customer engagement and purchasing behaviour.
--   2. Evaluate monthly purchase activity and product performance.
--   3. Assess transaction data quality and revenue reliability.

-- 1. Event activity and unique users
-- Which event types occurred most frequently?

SELECT
  event_name,
  COUNT(*) AS total_events,
  COUNT(DISTINCT user_pseudo_id) AS unique_users
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
GROUP BY event_name
ORDER BY total_events DESC;

-- 2. Frequency of key engagement events per user

SELECT
  event_name,
  COUNT(*) AS total_events,
  COUNT(DISTINCT user_pseudo_id) AS unique_users,
  ROUND(
    SAFE_DIVIDE(COUNT(*), COUNT(DISTINCT user_pseudo_id)),
    2
  ) AS events_per_user
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
  AND event_name IN ('page_view', 'user_engagement', 'scroll')
GROUP BY event_name
ORDER BY events_per_user DESC;

-- 3. Monthly purchase activity and recorded event-level revenue
-- Revenue is summed across purchase events, so repeated events may affect the total. See the transaction validation sections below.

SELECT
  FORMAT_DATE('%Y-%m', PARSE_DATE('%Y%m%d', event_date)) AS purchase_month,
  COUNT(*) AS purchase_events,
  COUNT(DISTINCT IF(
    ecommerce.transaction_id IS NOT NULL
    AND TRIM(CAST(ecommerce.transaction_id AS STRING)) != ''
    AND LOWER(TRIM(CAST(ecommerce.transaction_id AS STRING))) != '(not set)',
    CAST(ecommerce.transaction_id AS STRING),
    NULL
  )) AS valid_unique_transactions,
  ROUND(SUM(ecommerce.purchase_revenue), 2) AS event_level_purchase_revenue
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
  AND event_name = 'purchase'
GROUP BY purchase_month
ORDER BY purchase_month;

-- 4. Top 10 products by recorded item revenue

SELECT
  item.item_name AS product_name,
  SUM(item.quantity) AS units_sold,
  ROUND(SUM(item.item_revenue_in_usd), 2) AS product_revenue_usd
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`,
UNNEST(items) AS item
WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
  AND event_name = 'purchase'
GROUP BY product_name
ORDER BY product_revenue_usd DESC
LIMIT 10;


-- 5. User-level purchase behaviour overview
-- Counts users who triggered each event at any point in the period.
-- This is not a sequential or same-session conversion funnel.

WITH user_stages AS (
  SELECT
    user_pseudo_id,
    MAX(IF(event_name = 'view_item', 1, 0)) AS viewed_product,
    MAX(IF(event_name = 'add_to_cart', 1, 0)) AS added_to_cart,
    MAX(IF(event_name = 'begin_checkout', 1, 0)) AS began_checkout,
    MAX(IF(event_name = 'purchase', 1, 0)) AS completed_purchase
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
    AND user_pseudo_id IS NOT NULL
  GROUP BY user_pseudo_id
)
SELECT
  SUM(viewed_product) AS product_viewers,
  SUM(added_to_cart) AS users_added_to_cart,
  SUM(began_checkout) AS users_began_checkout,
  SUM(completed_purchase) AS users_with_purchase
FROM user_stages;

-- 6. Monthly active users and user purchase rate
-- User purchase rate = purchasing users / active users in each month.

SELECT
  FORMAT_DATE('%Y-%m', PARSE_DATE('%Y%m%d', event_date)) AS month,
  COUNT(DISTINCT user_pseudo_id) AS active_users,
  COUNT(DISTINCT IF(
    event_name = 'purchase',
    user_pseudo_id,
    NULL
  )) AS purchasing_users,
  ROUND(
    SAFE_DIVIDE(
      COUNT(DISTINCT IF(event_name = 'purchase', user_pseudo_id, NULL)),
      COUNT(DISTINCT user_pseudo_id)
    ) * 100,
    2
  ) AS user_purchase_rate_pct
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
GROUP BY month
ORDER BY month;


-- 7. Purchase transaction ID quality checks
-- Separates NULL, blank, and '(not set)' identifiers.

SELECT
  COUNT(*) AS total_purchase_events,
  COUNTIF(ecommerce.transaction_id IS NULL) AS null_transaction_ids,
  COUNTIF(
    TRIM(CAST(ecommerce.transaction_id AS STRING)) = ''
  ) AS blank_transaction_ids,
  COUNTIF(
    LOWER(TRIM(CAST(ecommerce.transaction_id AS STRING))) = '(not set)'
  ) AS not_set_transaction_ids
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
  AND event_name = 'purchase';


-- 8. Summary of repeated valid transaction IDs
-- Repetition warrants investigation but does not by itself prove that a transaction was duplicated.

WITH transaction_counts AS (
  SELECT
    CAST(ecommerce.transaction_id AS STRING) AS transaction_id,
    COUNT(*) AS event_count
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
    AND event_name = 'purchase'
    AND ecommerce.transaction_id IS NOT NULL
    AND TRIM(CAST(ecommerce.transaction_id AS STRING)) != ''
    AND LOWER(TRIM(CAST(ecommerce.transaction_id AS STRING))) != '(not set)'
  GROUP BY transaction_id
)
SELECT
  COUNT(*) AS unique_valid_transaction_ids,
  COUNTIF(event_count > 1) AS transaction_ids_repeated,
  SUM(IF(event_count > 1, event_count, 0)) AS events_with_repeated_ids,
  MAX(event_count) AS highest_event_count_for_one_transaction
FROM transaction_counts;


-- 9. Revenue consistency for repeated valid transaction IDs
-- Lists up to 20 repeated IDs for inspection.

SELECT
  CAST(ecommerce.transaction_id AS STRING) AS transaction_id,
  COUNT(*) AS event_count,
  COUNT(DISTINCT ecommerce.purchase_revenue) AS distinct_revenue_values,
  MIN(ecommerce.purchase_revenue) AS minimum_event_revenue,
  MAX(ecommerce.purchase_revenue) AS maximum_event_revenue
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
  AND event_name = 'purchase'
  AND ecommerce.transaction_id IS NOT NULL
  AND TRIM(CAST(ecommerce.transaction_id AS STRING)) != ''
  AND LOWER(TRIM(CAST(ecommerce.transaction_id AS STRING))) != '(not set)'
GROUP BY transaction_id
HAVING COUNT(*) > 1
ORDER BY event_count DESC
LIMIT 20;


-- 10. Revenue reconciliation
-- Compares raw event-level revenue with a diagnostic estimate that takes the maximum recorded revenue per valid transaction ID.
-- The estimate is not a verified sales total.

WITH purchases AS (
  SELECT
    CAST(ecommerce.transaction_id AS STRING) AS transaction_id,
    ecommerce.purchase_revenue AS revenue
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
    AND event_name = 'purchase'
),
transaction_summary AS (
  SELECT
    transaction_id,
    COUNT(*) AS event_count,
    COUNT(DISTINCT revenue) AS distinct_revenue_values,
    MAX(revenue) AS transaction_revenue_estimate
  FROM purchases
  WHERE transaction_id IS NOT NULL
    AND TRIM(transaction_id) != ''
    AND LOWER(TRIM(transaction_id)) != '(not set)'
  GROUP BY transaction_id
)
SELECT
  (SELECT ROUND(SUM(revenue), 2) FROM purchases)
    AS raw_purchase_event_revenue,
  ROUND(SUM(transaction_revenue_estimate), 2)
    AS max_per_transaction_revenue_estimate,
  COUNT(*) AS valid_unique_transactions,
  COUNTIF(distinct_revenue_values > 1)
    AS transactions_with_conflicting_revenue
FROM transaction_summary;
