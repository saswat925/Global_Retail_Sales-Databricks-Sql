# Global_Retail_Sales-Databricks-Sql

# 🌍 Global Retail Sales Analytics

A full pipeline demonstration—data engineering, cleaning, dimensional modeling, and BI analytics—using a realistic global retail sales dataset. Built for Databricks SQL, demonstrating large-scale star schema design and high-value business insights.

---

## 📊 Project Overview

**Objective:** Deliver a robust, production-style analytics platform for a multinational retailer. All data engineering and analytics steps are traceable, highlighting best practices for quality assurance and business value extraction.

**Stack:**
- Platform: Databricks (SQL Warehouse, PRO, Photon enabled, AWS)
- Modeling: Star Schema (Fact & 5 Dimensions)
- Data: Synthetic, 62k sales, 2.5k products, 15k customers, multi-currency

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

**Table Summary:**
| Table                | Rows    | Description                          |
|----------------------|---------|--------------------------------------|
| `fact_sales`         | 62,884  | Sales transactions (central fact)    |
| `dim_customers`      | 15,266  | Customer demographics                |
| `dim_products`       | 2,517   | Product catalog and pricing          |
| `dim_stores`         | 67      | Stores by geography                  |
| `dim_exchange_rates` | 11,215  | Multi-currency rates (5 currencies)  |
| `dim_date`           | 1,641   | Calendar dimension                   |

---

## 🧹 Data Engineering & Cleaning

**Fact Table (`fact_sales`):**
- Nulls: 79% Delivery_Date missing (flagged for analytics exclusion)
- No duplicates (Order_Number, Line_Item, Product_Key)
- All required fields present

**Customer Dimension:**
- No nulls (all attributes complete)
- No duplicates
- Fixed 17 records with blanks/extra spaces

**Product Dimension:**
- 14 nulls (Unit_Cost), 158 nulls (Unit_Price) — replaced with 0
- No duplicates
- Consistent formatting for currency, brand, color

**Store Dimension:**
- One null (Square_Meters)—replaced with 0
- Fully validated; 67 store records

**Exchange Rates & Date Dimensions:**
- No duplicates, all structural fields present, no negative exchanges
- 5 currencies (AUD, CAD, USD, EUR, GBP)

---

## 🪐 Star Schema & Modeling

- Each dimension created from cleansed base tables using best-practice keys and type casting
- All analytical models are built to maximize query performance and reporting clarity

---

## 📈 Analytics & Insights

### KPIs
| Metric                       | Value         |
|------------------------------|--------------|
| Total Revenue                | $43,202,936  |
| Total Profit                 | $20,538,473  |
| Total Orders                 | 26,326       |
| Unique Customers             | 11,887       |
| Total Quantity Sold          | 197,757      |
| Average Orders per Customer  | 2.21         |
| Avg. Revenue per Order       | 1,614.07     |
| Repeat Customers             | 7,272        |

### Business Trends
- **Top Categories**: Computers, Cell phones, Home Appliances—top categories by revenue and profit
- **Top Brands**: Adventure Works, Wide World Importers, Contoso
- **Best Cities**: Toronto, New York, Los Angeles
- **Online Channel**: Store_Key 0 (online) generates most sales—digital first

### Time Insights
- **Revenue/Profit Growth**: Explosive growth in 2017–2019, crash after 2019 (COVID)
- **Peak Month**: December highest monthly revenue
- **Peak Day**: Saturday highest in week
- **Delivery**: 1,135 orders delayed >7 days (logistics risk)

### Financials by Currency
- Supports 5 currencies with exchange rate analytics
- AUD and CAD carry most rate volatility; USD fixed (base)

---

## 📁 Project Structure

```
/
├── Global Retail Sales.dbquery.ipynb  # Main SQL (all analysis)
├── Global Retail Sales Analytics - GitHub README.md
├── /data/
│    ├── sales           # Source transactional fact
│    ├── customers       # Raw customers
│    ├── products        # Raw products
│    ├── stores          # Store info
│    ├── exchange_rates  # FX data
│    └── date            # Calendar
```

---

## 🚀 Fast Start (How to Use)

**Prerequisites:**
- Databricks SQL Workspace (UC enabled)
- Attach to PRO/Photon serverless warehouse

**Steps:**
1. Load all raw data into tables (`sales`, `customers`, `products`, `stores`, `exchange_rates`)
2. Run all SQL from `Global Retail Sales.dbquery.ipynb` (statements auto-create cleaned/star tables and run analysis)
3. Read insights or build dashboards off final star schema

---

## 🧠 Best Practices Demonstrated

- Modular ETL: Separate cleaning, validation, dimensional logic
- Robust null/duplicate handling
- Analytical SQL: Window, CTE, LAG/LEAD, type casting
- Star schema for fast BI and self-service analytics

---

## 📝 Author & Contact

**Saswat Betta Aptakam**  
Data Engineer & Analytics Professional

Contact: saswatbetta.aptakam@gmail.com


*Built & optimized for Databricks SQL on AWS*
