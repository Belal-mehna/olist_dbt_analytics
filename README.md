# Olist E-Commerce Analytics Engineering Pipeline (dbt + PostgreSQL)

## Overview
This project transforms raw e-commerce data from the Olist dataset into a production-grade, analytics-ready Data Mart using **dbt (data build tool)** and **PostgreSQL**. 

The main objective is to establish a robust **Star Schema** architecture, strictly managing table grain and resolving multi-level join fan-out issues to provide reliable financial and operational metrics for BI tools and data analysts.

---

## Data Architecture & Layer Separation

The pipeline follows modular analytics engineering best practices, separating concerns into distinct layers:

Raw Sources (PostgreSQL) ──> Staging Layer (stg_) ──> Marts Layer (fct_ / dim_)


### 1. Staging Layer (`models/staging/`)
* **Purpose:** Lightweight data cleansing, renaming, data type casting, and standardizing column naming conventions.
* **Key Operations:**
  * Renamed `order_item_id` to `item_sequence` to clarify structural intent.
  * Explicit timestamp and numeric casting.
  * Preserved original Portuguese product categories while mapping translations.

### 2. Marts Layer (`models/marts/`)
* **Purpose:** Dimensional modeling (Star Schema) and business logic consolidation.
* **Fact Models:**
  * `fct_orders`: Grain set strictly at **1 row per order**. Uses early aggregations (CTEs) on items and payments to prevent **Fan-Out** errors and duplicate revenue metrics.
* **Dimension Models:**
  * `dim_customers`: Grain set at **1 row per unique customer** (`customer_unique_id`), tracking customer Lifetime Value (LTV) and repeat buyer flags (`is_repeat_buyer`).
  * `dim_products`: Contains product physical metrics (calculating volume in $cm^3$) alongside category translations.
  * `dim_sellers`: Tracks seller performance metrics including total revenue, items sold, and handled orders.

---

## Key Engineering & Modeling Decisions

* **Strict Grain Management:** Designed `fct_orders` to preserve order-level granularity while safely incorporating item-level and payment-level sums via CTE Pre-Aggregations.
* **Handling Nulls:** Utilized `COALESCE` logic across financial and count metrics to maintain downstream statistical consistency for new entities or missing values.
* **Derived Business Metrics:** Engineered actionable business attributes such as `is_repeat_buyer`, `product_volume_cm3`, and seller sales totals.

---

## Tech Stack
* **Transformation:** dbt Core (v1.x)
* **Database:** PostgreSQL
* **Data Modeling:** Dimensional Modeling (Star Schema)
* **Version Control:** Git / GitHub (Conventional Commits)

---

## Data Quality & Testing
Data integrity is maintained using dbt tests defined in `_marts__models.yml`:
* **Primary Key Constraints:** `unique` and `not_null` tests applied across all primary keys (`order_id`, `customer_unique_id`, `product_id`, `seller_id`).
* **Referential Integrity:** `relationships` tests validating foreign keys between fact and dimension tables.

---

## How to Run This Project Locally

1. **Clone the repository:**
   ```bash
   git clone [https://github.com/Belal-mehna/Olist_project.git](https://github.com/Belal-mehna/Olist_project.git)
   cd Olist_project

    Configure profiles.yml:
    Ensure your local PostgreSQL connection is configured in ~/.dbt/profiles.yml.

    Install Dependencies & Run dbt:
    Bash

dbt debug
dbt run
dbt test

Generate & View Documentation:
Bash

    dbt docs generate
    dbt docs serve