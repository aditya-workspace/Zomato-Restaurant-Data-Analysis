# Zomato Business Analysis Report

## 1. Executive Summary

1. The dataset contains **44,891 records**, covering **35,688 unique restaurants, 98 cities, and 124 cuisines**.
2. Overall customer experience is reasonably strong, with an average rating of **3.92**, average price of **₹172.47**, and average delivery time of **33.18 minutes**.
3. **Junagadh** is the strongest city among the listed city results, with a **4.09 average rating**, ₹121.72 average price, and 25.31-minute average delivery time.
4. **Desserts and Beverages** show relatively strong ratings among the major cuisines listed. Desserts have the highest average rating at approximately **4.00**.
5. The highest performance scores are concentrated among restaurants with very high ratings, with the top-performing restaurants achieving scores of **98.8**.

## 2. City Performance

| City | Avg Rating | Avg Price | Avg Delivery |
|---|---:|---:|---:|
| Junagadh | **4.09** | ₹121.72 | **25.31 min** |
| Delhi NCR | **4.09** | ₹207.67 | 41.54 min |
| Pune | 4.08 | ₹174.28 | 36.16 min |
| Mumbai | 4.05 | ₹202.27 | 37.82 min |
| Bangalore | 4.05 | ₹181.37 | 40.70 min |

Junagadh combines the highest listed rating with the lowest price and fastest delivery among these leading cities.

Among the cities shown in the supplied top-city output, **Jaipur has the lowest average rating at 3.99**. This should not be described as the weakest city overall because the supplied output only contains the top 10 city records.

## 3. Restaurant Performance

The performance-score analysis identifies several **Excellent** restaurants.

| Restaurant | City | Rating | Delivery | Price | Score |
|---|---|---:|---:|---:|---:|
| Rasoi Ghar Se | Palakkad | 4.9 | 32 min | ₹100 | **98.8** |
| Hangyo Ice Cream | Manipal | 4.9 | 8 min | ₹100 | **98.8** |
| Rambhai Special Butter Patties | Firozabad | 4.9 | 29 min | ₹100 | **98.8** |
| Cake Waves | Trichy | 4.9 | 24 min | ₹150 | **98.8** |

The performance score is a **constructed project metric**, not an official Zomato metric.

## 4. Cuisine Analysis

| Cuisine | Restaurant Count | Avg Rating | Avg Price | Avg Delivery |
|---|---:|---:|---:|---:|
| North Indian | 15,790 | 3.90 | ₹177.48 | 34.34 min |
| Chinese | 13,736 | 3.89 | ₹178.72 | 34.66 min |
| Fast Food | 13,233 | 3.90 | ₹171.76 | 34.08 min |
| Beverages | 10,572 | **3.95** | ₹177.91 | 33.76 min |
| Street Food | 7,057 | 3.92 | ₹165.89 | 32.83 min |
| Desserts | 6,654 | **4.00** | ₹179.63 | **32.51 min** |
| Biryani | 6,410 | 3.88 | ₹180.01 | 33.79 min |
| Pizza | 5,539 | **3.86** | ₹175.68 | 34.53 min |
| South Indian | 5,347 | 3.95 | ₹167.28 | **32.75 min** |
| Sandwich | 4,441 | 3.90 | ₹170.84 | 33.76 min |

North Indian, Chinese and Fast Food have the largest presence in the supplied cuisine analysis. Desserts have the highest average rating (**4.00**) among these cuisines. Pizza has the lowest average rating (**3.86**) among the listed cuisines.

## 5. Customer Experience

- **Average rating:** 3.92
- **Average delivery time:** 33.18 minutes
- **Average price:** ₹172.47
- **Rated restaurants:** 37,826
- **Restaurants with delivery data:** 39,592

Examples:
- Junagadh: **4.09 rating / 25.31 min**
- Chennai: **4.01 rating / 42.25 min**
- Desserts: **4.00 rating / 32.51 min**
- Pizza: **3.86 rating / 34.53 min**

The supplied summary does not contain correlation coefficients between rating, delivery time and price, so this analysis does not claim that delivery time or price directly causes higher or lower ratings.

## 6. Business Recommendations

1. **Prioritize high-performing city models.** Study cities such as Junagadh, where high ratings coexist with relatively low prices and fast delivery.
2. **Improve delivery performance in slower major cities.** Chennai, Hyderabad, Delhi NCR and Bangalore have average delivery times above 40 minutes in the supplied results.
3. **Promote high-performing cuisine categories.** Desserts, Beverages and South Indian cuisine show comparatively strong ratings.
4. **Investigate lower-rated cuisine segments.** Pizza and Biryani show relatively lower average ratings among the listed cuisines.
5. **Identify and replicate excellent restaurant practices.** Restaurants achieving 98.8 performance scores can serve as operational benchmarks.

## 7. Business Risks / Areas Requiring Attention

### Data Completeness
The dataset contains **44,891 records**, but only **37,826 have rating data** and **39,592 have delivery data**.

### City Naming Consistency
The supplied results contain city names such as **Delhi NCR** and **NCR** separately. This could represent a data-standardization issue.

### Performance-Score Dependency
The performance score is a project-derived metric and should not be interpreted as an official Zomato performance indicator.

### No Causal Conclusions
The available summary provides averages, rankings and benchmark results, but does not establish causal relationships between price, delivery time and ratings.

## 8. SQL vs Python

### SQL
SQL was used for:
- City-level KPI aggregation
- Restaurant ranking
- Rolling analysis
- Data transformation
- Window-function-based analysis

### Python
Python was used for:
- Data analysis
- Statistical calculations
- Ranking validation
- Business analysis
- Comparing SQL and Python results
- Preparing the AI-ready analytical summary

### Benchmark Results

| Analysis | SQL Time (sec) | Python Time (sec) | Results Match |
|---|---:|---:|---|
| City KPI | 0.1534 | **0.0306** | Yes |
| Restaurant Ranking | 0.1233 | **0.0309** | Yes |
| Rolling Analysis | 0.2160 | **0.0440** | Yes |

In these three notebook tests, Python completed the calculations faster, while all three analyses produced matching results.

## Project Workflow

**Zomato Raw Data**  
→ **SQL Server / Data Cleaning**  
→ **SQL Analysis**  
→ **Python Analysis & Statistics**  
→ **SQL vs Python Validation & Benchmarking**  
→ **AI-Assisted Business Interpretation**

## Conclusion

This project demonstrates an end-to-end data analyst workflow combining SQL, Python and AI-assisted interpretation. The analysis moves from structured data processing and validation to business insights and actionable recommendations while explicitly documenting data limitations and the SQL-versus-Python benchmark.
