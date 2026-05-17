# 🌍 Global Retail Sales Analytics

A complete end-to-end data engineering and analytics pipeline demonstrating production-grade practices on a realistic global retail dataset. Built on Databricks SQL with Unity Catalog, featuring star schema modeling, comprehensive data quality validation, and actionable business insights.

---

## 📊 Project Overview

**Objective:** Deliver a robust, production-ready analytics platform for a multinational retailer with full traceability from raw data ingestion through dimensional modeling to business intelligence.

**Technology Stack:**
* Platform: Databricks SQL Warehouse (AWS)
* Compute: Serverless PRO (Photon-enabled)
* Catalog: Unity Catalog (`waerehouse.retail`)
* Modeling: Star Schema (1 Fact + 5 Dimensions)
* Languages: SQL (Databricks SQL)

**Dataset Scale:**
* 62,884 sales transactions
* 15,266 customers across 8 countries
* 2,517 products across 8 categories
* 67 physical stores + online channel
* 11,215 daily exchange rates (5 currencies)
* 1,641 calendar days (2016–2021)

---

## 🏗️ Architecture

```text
                  dim_customers
                        |
                        |
dim_products ---- fact_sales ---- dim_stores
                        |
                        |
              dim_exchange_rates
                        |
                        |
                    dim_date
```

### Star Schema Tables

| Table                | Rows    | Description                                    |
|----------------------|---------|------------------------------------------------|
| `fact_sales`         | 62,884  | Sales transactions (grain: order line item)    |
| `dim_customers`      | 15,266  | Customer demographics and location             |
| `dim_products`       | 2,517   | Product catalog with cost and pricing          |
| `dim_stores`         | 67      | Physical store locations by country            |
| `dim_exchange_rates` | 11,215  | Daily FX rates for 5 currencies                |
| `dim_date`           | 1,641   | Calendar dimension with date attributes        |

---

## 🧹 Data Engineering & Quality Validation

### Data Quality Checks (Validated via SQL)

**Fact Table (`fact_sales`):**
* ✅ 0 duplicates on composite key (Order_Number, Line_Item, Product_Key)
* ✅ All required fields complete (Order_Number, Order_Date, Customer_Key, Store_Key, Product_Key, Quantity, Currency_Code)
* ⚠️ 79.06% Delivery_Date missing (49,719 of 62,884) — expected for same-day/pickup orders
* ✅ No null values in critical fields

**Dimension Tables:**
* `dim_customers`: ✅ No nulls, no duplicates, all 15,266 records valid
* `dim_products`: ✅ No nulls in pricing fields (Unit_Cost_USD, Unit_Price_USD after cleaning)
* `dim_stores`: ✅ 67 stores validated (0 nulls post-cleaning)
* `dim_exchange_rates`: ✅ All rates present, no negative values
* `dim_date`: ✅ Complete calendar coverage 2016–2021

**Data Cleaning Applied:**
* Replaced product pricing nulls with $0
* Standardized customer name formatting (removed blanks/extra spaces)
* Replaced missing store square_meters with 0
* Validated all foreign key relationships

---

## 📈 Business Performance Metrics

### Core KPIs (Validated Results)

| Metric                       | Value           | Insight                              |
|------------------------------|-----------------|--------------------------------------|
| **Total Revenue**            | $42,845,041     | Across all currencies (USD equiv.)   |
| **Total Profit**             | $20,347,572     | 47.49% profit margin                 |
| **Total Orders**             | 26,326          | Distinct order numbers               |
| **Unique Customers**         | 11,887          | Active customer base                 |
| **Total Units Sold**         | 197,757         | Quantity across all transactions     |
| **Avg Orders per Customer**  | 2.21            | Customer engagement metric           |
| **Avg Revenue per Order**    | $1,627          | Average order value                  |
| **Avg Revenue per Customer** | $3,604          | Customer lifetime value proxy        |
| **Repeat Customer Rate**     | 61.18%          | 7,272 repeat / 11,887 total          |

---

## 🎯 Business Intelligence Insights

### Top Product Categories (by Revenue)

| Rank | Category                      | Revenue       | Profit      | Units Sold | Orders |
|------|-------------------------------|---------------|-------------|------------|--------|
| 1    | Computers                     | $15,913,046   | $7,956,392  | 44,151     | 10,990 |
| 2    | Cell phones                   | $6,118,492    | $3,462,855  | 31,477     | 8,442  |
| 3    | Home Appliances               | $5,843,212    | $1,789,861  | 18,401     | 5,195  |
| 4    | Cameras and camcorders        | $5,272,281    | $2,678,043  | 17,609     | 4,995  |
| 5    | Audio                         | $3,147,477    | $1,815,913  | 23,490     | 6,625  |
| 6    | Music, Movies and Audio Books | $3,113,972    | $1,899,609  | 28,802     | 7,784  |
| 7    | TV and Video                  | $2,717,959    | $352,102    | 11,236     | 3,325  |
| 8    | Games and Toys                | $718,603      | $392,798    | 22,591     | 6,128  |

**Key Insight:** Computers dominate at 37% of total revenue with healthy 50% margins.

### Top Brands (by Revenue)

| Brand                  | Revenue     | Profit      | Products | Units Sold |
|------------------------|-------------|-------------|----------|------------|
| Adventure Works        | $8,075,791  | $3,209,229  | 183      | 20,099     |
| Wide World Importers   | $8,038,186  | $4,282,640  | 170      | 27,413     |
| Contoso                | $7,873,459  | $3,429,493  | 708      | 49,827     |
| The Phone Company      | $5,328,364  | $3,025,630  | 152      | 18,764     |
| Fabrikam               | $4,473,941  | $1,983,300  | 267      | 11,384     |

### Top Cities (by Revenue)

| City         | Country        | Revenue     | Customers | Orders |
|--------------|----------------|-------------|-----------|--------|
| Toronto      | Canada         | $623,940    | 156       | 301    |
| New York     | United States  | $389,240    | 111       | 240    |
| Los Angeles  | United States  | $381,105    | 94        | 238    |
| Montreal     | Canada         | $299,640    | 70        | 141    |
| Houston      | United States  | $278,323    | 77        | 188    |

### Sales Channel Performance

| Channel          | Location       | Revenue       | Profit      | Orders | Units   |
|------------------|----------------|---------------|-------------|--------|---------|
| **Online**       | (Store_Key=0)  | $8,959,111    | $4,289,537  | 5,580  | 41,311  |
| Physical Store   | United States  | $18,353,872   | $8,697,143  | 11,153 | 83,638  |
| Physical Store   | Canada         | $3,762,622    | $1,815,649  | 1,769  | 12,991  |
| Physical Store   | United Kingdom | $3,501,639    | $1,692,198  | 2,784  | 20,625  |

**Key Insight:** Online channel represents 21% of revenue with strong profitability (47.9% margin).

---

## 📅 Temporal Analysis

### Year-over-Year Performance

| Year | Revenue        | Profit       | Orders | YoY Growth |
|------|----------------|--------------|--------|------------|
| 2016 | $4,725,738     | $1,999,588   | 2,865  | —          |
| 2017 | $5,558,018     | $2,591,442   | 3,280  | +17.61%    |
| 2018 | $9,661,618     | $4,558,449   | 5,965  | +73.83%    |
| 2019 | $14,656,525    | $7,188,316   | 9,083  | +51.70%    |
| 2020 | $7,400,924     | $3,592,000   | 4,635  | -49.50%    |
| 2021 | $842,217       | $417,777     | 498    | -88.62%    |

**Critical Insight:** Business peaked in 2019 ($14.7M), followed by sharp COVID-19 impact in 2020–2021.

### Seasonal Patterns

**Peak Month:** December ($5.82M revenue) — holiday shopping drive  
**Lowest Month:** April ($481k revenue)  

**Peak Day of Week:** Saturday ($10.08M total) — weekend shopping preference  
**Lowest Day:** Sunday ($740k total)

---

## 🚚 Delivery & Operations

### Delivery Performance Metrics

| Metric                   | Value    | Details                          |
|--------------------------|----------|----------------------------------|
| Orders with Delivery     | 13,165   | 20.9% of total orders tracked    |
| On-time (≤7 days)        | 12,030   | 91.4% delivery success rate      |
| Late (>7 days)           | 1,135    | 8.6% delayed shipments           |
| Average Delivery Time    | 4.53 days| Below 7-day target               |
| Max Delivery Time        | 17 days  | Outlier requiring investigation  |

**Operational Risk:** 1,135 late deliveries indicate potential logistics bottlenecks or carrier issues.

---

## 💱 Multi-Currency Analysis

### Revenue by Currency (USD Equivalent)

| Currency | Revenue       | Orders | Avg Exchange Rate | Volatility (CV) |
|----------|---------------|--------|-------------------|-----------------|
| USD      | $23,274,384   | 14,221 | 1.0000            | 0%              |
| EUR      | $7,701,736    | 5,221  | 0.8836            | 3.90%           |
| CAD      | $4,845,091    | 2,281  | 1.3168            | 3.33%           |
| GBP      | $4,269,833    | 3,421  | 0.7694            | 6.97%           |
| AUD      | $2,753,998    | 1,182  | 1.3947            | 5.68%           |

**Exchange Rate Risk:** GBP shows highest volatility (6.97% coefficient of variation), followed by AUD (5.68%).

---

## 👥 Customer Analytics

### Customer Segmentation

* **Repeat Customers:** 7,272 (61.18%) — strong retention
* **One-time Customers:** 4,615 (38.82%)
* **Top Customer:** Paul Warren (Atlanta, US) — $34,671 lifetime value

### Geographic Distribution

| Country        | Customers | Revenue       | Orders | Avg Revenue/Customer |
|----------------|-----------|---------------|--------|----------------------|
| United States  | 5,706     | $23,274,384   | 14,221 | $4,078               |
| Canada         | 1,179     | $4,845,091    | 2,281  | $4,110               |
| United Kingdom | 1,570     | $4,269,833    | 3,421  | $2,720               |
| Germany        | 1,150     | $3,557,130    | 2,440  | $3,093               |

### Gender Analysis

* **Male:** 6,029 customers, $21.65M revenue, $3,591/customer avg
* **Female:** 5,858 customers, $21.20M revenue, $3,619/customer avg
* **Insight:** Gender parity in spending with near-equal engagement

---

## 📁 Project Structure

```
/Users/saswatbetta.aptakam@gmail.com/
├── Global Retail Sales - Complete Analysis.sql    # All SQL queries (25+ statements)
├── GLOBAL_RETAIL_SALES_INSIGHTS.md                # Executive summary
├── Global Retail Sales Analytics - GitHub README.md (this file)
└── data/ (Unity Catalog: waerehouse.retail)
    ├── fact_sales                                  # Source: raw sales transactions
    ├── dim_customers                               # Cleansed customer dimension
    ├── dim_products                                # Cleansed product catalog
    ├── dim_stores                                  # Store master data
    ├── dim_exchange_rates                          # Daily FX rates
    └── dim_date                                    # Calendar dimension
```

---

## 🚀 Quick Start Guide

### Prerequisites
* Databricks Workspace (AWS)
* Unity Catalog enabled
* SQL Warehouse (Serverless PRO recommended)

### Setup Steps

1. **Create Schema**
   ```sql
   CREATE SCHEMA IF NOT EXISTS waerehouse.retail;
   ```

2. **Load Raw Data**
   * Upload source files (sales, customers, products, stores, exchange_rates, date)
   * Load into staging tables using `COPY INTO` or Auto Loader

3. **Run Complete Analysis**
   * Execute `Global Retail Sales - Complete Analysis.sql`
   * All 25+ queries run sequentially for validation and insights

4. **View Results**
   * Query results available in SQL history
   * Key metrics summarized in `GLOBAL_RETAIL_SALES_INSIGHTS.md`

---

## 🧠 Data Engineering Best Practices Demonstrated

✅ **Dimensional Modeling**
* Proper star schema design with clear fact/dimension separation
* Surrogate and natural keys for flexibility
* Type 1 slowly changing dimensions

✅ **Data Quality Engineering**
* Comprehensive null analysis and handling
* Duplicate detection at grain level
* Referential integrity validation

✅ **Performance Optimization**
* Denormalized dimensions for query speed
* Pre-aggregated metrics where appropriate
* Indexed foreign keys for joins

✅ **SQL Best Practices**
* CTEs for readability and modularity
* Window functions (LAG, LEAD) for time-series
* Proper aggregation with GROUP BY validation
* Format functions for business-friendly output

✅ **Analytics Engineering**
* Repeatable, version-controlled SQL
* Clear separation of ETL vs. analytics queries
* Comprehensive documentation and lineage

---

## 📊 Sample Queries

### Revenue by Category
```sql
SELECT 
  p.Category,
  CONCAT('$', FORMAT_NUMBER(SUM(f.Quantity * p.Unit_Price_USD * e.Exchange), '#,###')) AS revenue
FROM waerehouse.retail.fact_sales f
LEFT JOIN waerehouse.retail.dim_products p ON f.Product_Key = p.Product_Key
LEFT JOIN waerehouse.retail.dim_exchange_rates e ON f.Order_Date = e.Date AND f.Currency_Code = e.Currency
GROUP BY p.Category
ORDER BY SUM(f.Quantity * p.Unit_Price_USD * e.Exchange) DESC;
```

### Year-over-Year Growth
```sql
WITH yearly AS (
  SELECT d.Year, SUM(f.Quantity * p.Unit_Price_USD * e.Exchange) AS revenue
  FROM waerehouse.retail.fact_sales f
  LEFT JOIN waerehouse.retail.dim_date d ON f.Order_Date = d.Order_Date
  LEFT JOIN waerehouse.retail.dim_products p ON f.Product_Key = p.Product_Key
  LEFT JOIN waerehouse.retail.dim_exchange_rates e ON f.Order_Date = e.Date AND f.Currency_Code = e.Currency
  GROUP BY d.Year
)
SELECT 
  Year,
  revenue,
  ((revenue - LAG(revenue) OVER (ORDER BY Year)) / LAG(revenue) OVER (ORDER BY Year)) * 100 AS yoy_growth_pct
FROM yearly;
```

---

## 🎓 Learning Outcomes

This project demonstrates:
* End-to-end data pipeline construction
* Dimensional modeling for analytics
* Data quality validation techniques
* SQL aggregation and window functions
* Multi-currency business logic
* Time-series analysis and trends
* Customer segmentation and cohort analysis
* Operational metrics (delivery, fulfillment)

---

## 📝 Author & Contact

**Saswat Betta Aptakam**  
Data Engineer & Analytics Professional

📧 Email: saswatbetta.aptakam@gmail.com  
💼 LinkedIn: [Connect on LinkedIn](#)  
🐙 GitHub: [View Portfolio](#)

---

---

##  Acknowledgments

* Dataset: Synthetic retail data modeled after real-world patterns
* Platform: Databricks Community / AWS
* Inspiration: Production data engineering pipelines in e-commerce
  
*Platform: Databricks SQL on AWS | Unity Catalog: waerehouse.retail*
