# E-commerce Revenue and Customer Behaviour Analysis

## Overview

An e-commerce data analytics project using SQL and Google BigQuery to investigate customer engagement, purchasing behaviour, product performance, revenue trends, and transaction data quality.

The analysis uses event-level e-commerce data to identify purchasing patterns, evaluate product performance, and assess the reliability of recorded revenue metrics.

## Business Objectives

- Analyse customer engagement across key e-commerce events.
- Evaluate monthly purchasing activity and recorded revenue.
- Identify top-performing products by units sold and recorded revenue.
- Examine user activity across product viewing, cart addition, checkout, and purchase events.
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

The project uses SQL filtering, aggregation, conditional calculations, common table expressions (CTEs), distinct counts, and `UNNEST` to analyse nested product data.

The analysis covers:

- Event frequency and user engagement
- Monthly purchase activity and recorded revenue
- Product-level performance by units sold and recorded revenue
- User-level purchasing behaviour across key e-commerce events
- Monthly user purchase rates
- Transaction identifier completeness and repeated transaction records
- Revenue consistency across purchase events

## Key Findings

- Page views were the most frequent of the key engagement events examined.
- December 2020 recorded the highest event-level purchase revenue during the analysis period.
- January 2021 had the lowest user purchase rate among the three months.
- Google-branded apparel featured prominently among the highest-revenue products in the sample.
- Some purchase events contained missing or unusable transaction identifiers.
- Repeated transaction identifiers and conflicting revenue values highlighted the importance of validating transaction records before using them for revenue reporting.

## Data Quality Considerations

Purchase-event counts and distinct transaction counts measure different things. Repeated transaction IDs do not automatically indicate duplicate purchases, and the maximum-revenue-per-transaction calculation is an estimate, not a verified accounting figure. Revenue findings should therefore be interpreted with these limitations in mind. The dataset is historical and obfuscated, so the results do not represent current business performance or verified profit.

## Business Recommendations

- Strengthen transaction identifier validation and investigate repeated purchase events.
- Monitor purchasing activity alongside overall customer engagement.
- Use product performance analysis to identify opportunities for further merchandising investigation.
- Validate revenue definitions and aggregation rules before using reported figures for business decisions.
