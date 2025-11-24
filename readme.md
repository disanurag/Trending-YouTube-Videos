#  Trending YouTube Videos (SQL Project)

##  Objective
Analyze YouTube trending videos dataset to explore video performance, audience engagement, and content trends using SQL.

---

##  Dataset
- Provided by **Cuvette** (as part of Data Science Pay After Placement Program)  
- Contains:
  - Video metadata (title, description, channel, category, duration, resolution)
  - Engagement metrics (views, likes, dislikes, comments)
  - Publish details (date, time)

---

##  Tools & Skills Used
- **PostgreSQL**  
- SQL concepts: `Data Cleaning`, `Date/Time Functions`, `Aggregations`, `CASE`, `Window Functions (RANK)`, `Joins`

---

##  Process
1. **Data Cleaning**
   - Extracted `published_date` and `published_time`  
   - Handled missing values (likes, dislikes, comments → 0)  
   - Removed rows with null `videoId`, `viewCount`, or `durationSec`

2. **Exploratory Queries**
   - Top 10 most viewed & Top 5 most liked videos  
   - Engagement rate per 1000 views  
   - Average views by category  
   - Short (<5 min) vs Long (>15 min) video performance  

3. **Trends & Insights**
   - Most common video category  
   - Views by definition (HD vs SD)  
   - Top categories by engagement  
   - Daily upload trends  

4. **Advanced Analysis**
   - **Engagement Leaders:** RANK() to find top video per category  
   - **Trending Time:** Upload hour analysis  
   - **Performance Outliers:** Videos with likes 1.5x above category average  
   - **Boolean Flag:** High Engagement videos (`viewCount > 10k` & `like/view > 0.1`)

---

##  Key Insights
- Engagement rate is a stronger metric than views alone  
- Short vs Long videos show very different audience patterns  
- Peak upload hours highlight creator activity trends  
- Certain categories consistently drive higher engagement  

---

##  Business Impact
- Helps **creators** identify the best category, video length, and upload timing  
- Enables **platforms** to optimize recommendations and content strategies  

---

##  Learnings
- Data preprocessing is as important as analysis  
- Window functions (`RANK`, `DENSE_RANK`) are powerful for category-wise insights  
- SQL alone can uncover deep business-level patterns from raw data  

---

##  Queries Used
All SQL queries including data cleaning, analysis, and advanced insights are available in the project files.  

---

##  Conclusion
This project demonstrates how SQL can transform raw YouTube data into **actionable insights** for decision-making in digital content strategy.
