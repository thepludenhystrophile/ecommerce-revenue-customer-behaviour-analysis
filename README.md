# E-commerce Revenue and Customer Behaviour Analysis

## Overview

An e-commerce data analytics project using SQL and Google BigQuery to investigate customer engagement, purchasing behaviour, product performance, revenue trends, and transaction data quality.

The analysis examines event-level e-commerce data to identify purchasing patterns, evaluate product performance, and assess the reliability of reported revenue metrics.

## Business Objectives

- Analyse customer engagement across key e-commerce events.
- Evaluate monthly purchasing activity and revenue trends.
- Identify top-performing products by units sold and recorded revenue.
- Examine customer progression through product viewing, cart addition, checkout, and purchase events.
- Calculate user-level purchase rates and compare monthly performance.
- Investigate transaction data quality issues that may affect revenue reporting.

## Tools and Technologies

- SQL
- Google BigQuery

## Dataset

**Source:** Google Analytics 4 public e-commerce sample dataset

**Table:** `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`

**Analysis period:** November 1, 2020 – January 31, 2021

The dataset contains event-level customer activity, purchase records, transaction identifiers, and product information.

## Analytical Approach

The project uses SQL aggregation, conditional calculations, common table expressions (CTEs), distinct counts, window-independent grouping, and `UNNEST` to examine nested product data.

The analysis covers:
- Event frequency and user engagement
- Monthly purchase activity and recorded revenue
- Average revenue per transaction
- Product-level sales performance
- User-level purchase funnel overview
- Monthly user purchase rates
- Transaction identifier completeness and repeated transaction records
- Revenue consistency across purchase events

## Key Findings

- Page views were the most frequent event among the major engagement events examined.
- December 2020 recorded the highest monthly purchase revenue during the analysis period.
- January 2021 had the lowest user purchase rate among the three months.
- Google-branded apparel featured prominently among the highest-revenue products in the sample.
- Some purchase records contained missing or unusable transaction identifiers.
- Repeated transaction identifiers and conflicting event-level revenue values highlighted the need for careful revenue aggregation.

## Data Quality Considerations

Purchase-event counts and distinct transaction counts are not interchangeable. Repeated transaction identifiers do not necessarily prove duplicate purchases, and selecting the maximum revenue per transaction is an estimate rather than a verified accounting measure. Revenue figures are therefore interpreted in the context of the source data and aggregation method. The dataset is historical and obfuscated, and the findings should not be treated as current business performance or profit.

## Business Recommendations

- Strengthen transaction identifier validation and investigate repeated purchase events.
- Monitor customer purchasing activity alongside overall engagement.
- Use product performance analysis to guide further investigation of merchandising opportunities.
- Validate revenue definitions and aggregation rules before using reported figures for business decisions.
