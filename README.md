# Zomato Restaurant Data Analysis

## Project Overview

This project focuses on analysing Zomato restaurant data to identify trends in restaurant distribution, cuisine popularity, customer ratings, pricing, and delivery performance.

The project uses **SQL Server, Python, and Power BI** to transform raw restaurant data into meaningful insights and business recommendations.

The objective is to understand restaurant market patterns, evaluate customer experience, compare city-level performance, and present actionable insights through data analysis and visualisation.

## Project Objectives

- Analyse restaurant distribution across different cities.
- Identify popular cuisines and restaurant categories.
- Evaluate average restaurant ratings and pricing.
- Analyse delivery time and its relationship with customer ratings.
- Identify high-performing restaurants.
- Compare SQL and Python analytical results.
- Build an interactive Power BI dashboard.
- Generate AI-assisted business insights and recommendations.

##  Tools & Technologies

| Tool | Purpose |
|---|---|
| SQL Server | Data cleaning, transformation, and analysis |
| Python | Exploratory data analysis and statistical analysis |
| Pandas & NumPy | Data manipulation |
| Matplotlib & Seaborn | Data visualisation |
| Jupyter Notebook | Python analysis |
| Power BI | Interactive dashboard |
| Excel / CSV | Data storage and exports |
| AI | Business insights and recommendations |

##  Project Structure

```text
Zomato-Restaurant-Analysis/
│
├── powerbi/
│   ├── Zomato_Dashboard.pbix
│   └── Zomato_Dashboard_Preview.png
│
├── reports/
│   └── AI_Business_Insights.md
│
├── data/
│   └── tables/
│       ├── SQL analysis exports
│       ├── Python analysis exports
│       └── SQL_vs_Python_Comparison.csv
│
├── python/
│   └── Zomato_Analysis.ipynb
│
├── sql/
│   └── Zomato_Complete_Analysis.sql
│
└── README.md
```

## SQL Analysis

SQL Server was used to clean, transform, structure, and analyse the restaurant dataset.

Key activities:

- Data cleaning and handling missing values.
- Standardisation of ratings, prices, delivery times, and safety measures.
- Creation of structured restaurant and cuisine tables.
- City-wise restaurant performance analysis.
- Cuisine popularity analysis.
- Restaurant ranking and performance scoring.
- Rolling and cumulative analysis.
- City-level comparisons and rankings.
- Creation of analytical tables for further analysis.

##  Python Analysis

Python was used for exploratory data analysis, statistical analysis, and validation of SQL results.

Key analysis areas:

- Overall business KPIs.
- City-wise restaurant analysis.
- Cuisine popularity and distribution.
- Delivery performance analysis.
- Rating bucket analysis.
- Correlation analysis.
- SQL vs Python performance comparison.

Libraries used: Pandas, NumPy, Matplotlib, and Seaborn.

## Power BI Dashboard

An interactive dashboard was developed to present the major findings of the analysis.

Key dashboard components:

- Total unique restaurants.
- Number of cities and cuisines.
- Average restaurant rating.
- Average restaurant price.
- Average delivery time.
- Top cities by restaurant presence.
- Cuisine popularity.
- Restaurant performance rankings.
- Customer ratings and delivery-time relationship.

## Key Dataset Insights

The analysed dataset contains:

| Metric | Value |
|---|---:|
| Total Records | 44,891 |
| Unique Restaurants | 35,688 |
| Cities Covered | 98 |
| Cuisine Categories | 124 |
| Average Rating | 3.92 |
| Average Price | ₹172.47 |
| Average Delivery Time | 33.18 minutes |

### Key Observations

- North Indian cuisine has the highest representation, with approximately 15,790 restaurant records.
- Restaurants with delivery times below 20 minutes have an average rating of approximately 4.04.
- The correlation between restaurant ratings and delivery time is weakly negative (-0.1017).
- The correlation between ratings and average price is nearly zero (-0.0047).

These findings provide an overview of restaurant distribution, pricing, and customer experience across the analysed locations.

## SQL vs Python Comparison

Selected analytical queries were independently performed using SQL and Python to compare execution time and validate results.

| Analysis | SQL Execution Time | Python Execution Time | Results Match |
|---|---:|---:|---|
| City KPI | 0.1534 sec | 0.0306 sec | Yes |
| Restaurant Ranking | 0.1233 sec | 0.0309 sec | Yes |
| Rolling Analysis | 0.2160 sec | 0.0440 sec | Yes |

*Execution times are based on the project environment and may vary depending on system resources, caching, and execution conditions.*

##  Business Value

This analysis demonstrates how restaurant data can support business decisions by:

- Identifying cities with strong restaurant presence.
- Understanding cuisine demand and market distribution.
- Evaluating customer satisfaction patterns.
- Analysing delivery efficiency.
- Identifying high-performing restaurants.
- Supporting data-driven business recommendations.

## Project Workflow

1. Import and inspect the raw dataset.
2. Clean and transform data using SQL Server.
3. Create structured tables for analytical purposes.
4. Perform SQL-based business analysis.
5. Export analytical datasets for Python.
6. Conduct exploratory and statistical analysis.
7. Compare SQL and Python results.
8. Develop a Power BI dashboard.
9. Generate business insights and recommendations.

## Future Improvements

- Develop predictive models for restaurant ratings.
- Build delivery-time prediction models.
- Expand city-level market analysis.
- Automate data refresh and reporting.
- Integrate additional restaurant and customer datasets.

