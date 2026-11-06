# E-Commerce Sales Data Quality & Business Analysis

A MySQL portfolio project focused on exploring, cleaning, validating, and analysing an e-commerce sales transaction dataset.

## Project overview

This project investigates transaction-level data quality, creates a cleaned table, validates cleaning decisions, and analyses revenue, products, categories, payment methods, locations, and customer purchasing behaviour.

- **Database:** `ecommerce_sales_project`
- **Raw table:** `raw_sales_data`
- **Dataset size:** 12,575 rows and 11 columns
- **Tools:** MySQL / MySQL Workbench
- **SQL concepts:** filtering, aggregation, `CASE`, CTEs, window functions (`LAG`, `SUM() OVER`), date functions, joins, and updates

## Repository structure

```text
.
├── README.md
├── .gitignore
├── sql/
│   └── E-Commerce-Sales-Data-Quality-Analysis.sql
├── dataset/
│   └── E-commerce_sales.csv
├── insights/
└── screenshots/
```

## Dataset fields

The CSV contains transaction ID, customer ID, category, item, price per unit, quantity, total spent, payment method, location, transaction date, and discount applied.

## Data quality work

The SQL script profiles missing values and date ranges, investigates missing item/price/quantity/spend/discount fields, checks invalid numeric values and dates, creates and validates a cleaned table, and conditionally recovers eligible missing unit prices where quantity is positive, total spent is present, and the discount flag is false.

## How to run

1. Create and select the database:

   ```sql
   CREATE DATABASE ecommerce_sales_project;
   USE ecommerce_sales_project;
   ```

2. Import `dataset/E-commerce_sales.csv` into MySQL Workbench as `raw_sales_data`, retaining the original column names (including spaces).
3. Keep the raw table unchanged. The SQL script reads from `raw_sales_data`.
4. Open `sql/E-Commerce-Sales-Data-Quality-Analysis.sql`.
5. Execute the script section by section: exploration, cleaning, validation, and analysis.

## Important execution notes

- The SQL file contains two alternative ways to create `cleaned_sales_data`: `CREATE TABLE ... AS SELECT` or `CREATE TABLE` followed by `INSERT ... SELECT`. Choose one approach; do not execute both table-creation approaches in sequence.
- Review the rows and assumptions before running the `UPDATE` statement that recovers missing unit prices.
- Do not run the full SQL file as one unrestricted batch. Execute and validate each section.

## Analysis included

- Dataset size, distinct transactions/customers, missing-value patterns, and date range
- Cleaned-table creation and validation
- Missing-value investigation and numeric/date quality checks
- Revenue coverage and overall sales summary
- Monthly revenue, month-over-month and year-over-year trends
- Category contribution and top products by revenue
- Product Pareto / cumulative revenue analysis
- Payment method and location/channel analysis
- Customer purchasing behaviour and repeat versus one-time customers

## Notes

The CSV is included as supplied. The SQL file expects it to be imported as `raw_sales_data`; it does not perform the import itself. The project comments contain draft findings—re-run the relevant queries and verify the figures before using them in a portfolio or interview. The data should not be described as live or real-time unless that is independently established.

## Skills demonstrated

SQL data profiling, data cleaning, missing-value investigation, data validation, conditional logic, aggregation, CTEs, window functions, trend analysis, contribution analysis, Pareto analysis, and customer segmentation.
