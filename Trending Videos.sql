CREATE TABLE trending_videos (
    id SERIAL PRIMARY KEY,
    channelId VARCHAR(255),
    channelTitle VARCHAR(255),
    videoId VARCHAR(255),
    publishedAt TIMESTAMP,
    videoTitle TEXT,
    videoDescription TEXT,
    videoCategoryId INTEGER,
    videoCategoryLabel VARCHAR(255),
    duration VARCHAR(50),
    durationSec INTEGER,
    definition VARCHAR(10),
    caption BOOLEAN,
    viewCount BIGINT,
    likeCount FLOAT,
    dislikeCount FLOAT,
    commentCount FLOAT
);

COPY trending_videos(
    id, channelId, channelTitle, videoId, publishedAt, 
    videoTitle, videoDescription, videoCategoryId, videoCategoryLabel, 
    duration, durationSec, definition, caption, viewCount, 
    likeCount, dislikeCount, commentCount
)
FROM 'C:/Program Files/PostgreSQL/17/data/Files/Trending videos on youtube dataset.csv'
DELIMITER ',' 
CSV HEADER;

SELECT * FROM trending_videos LIMIT 5;
SELECT COUNT(*) FROM trending_videos;

--1. Data Cleaning And Preprocessing
--(a) Convert publishedAt into DATE and TIME using SQL date functions.
ALTER TABLE trending_videos                      ---- Add new columns for date and time
ADD COLUMN published_date DATE,
ADD COLUMN published_time TIME;

UPDATE trending_videos                      ---- Update the new columns with extracted values
SET 
    published_date = publishedAt::DATE,
    published_time = publishedAt::TIME;

/* (b)Replace missing values in likeCount, dislikeCount, and commentCount
with 0 or filter them out.*/
UPDATE trending_videos
SET 
    likeCount = COALESCE(likeCount, 0), 
    dislikeCount = COALESCE(dislikeCount, 0),
    commentCount = COALESCE(commentCount, 0);

--(c) Remove videos with null or missing videoId, viewCount, or durationSec.
DELETE FROM trending_videos
WHERE 
    videoId IS NULL OR 
    viewCount IS NULL OR 
    durationSec IS NULL;

--2. Video Engagement And Popularity Analysis
--(a) Top 10 Most Viewed Videos: Based on viewCount.

SELECT videoTitle, channelTitle, viewCount
FROM trending_videos
ORDER BY viewCount DESC
LIMIT 10;

--(b) Top 5 Most Liked Videos: Based on likeCount.
SELECT videoTitle, channelTitle, likeCount
FROM trending_videos
ORDER BY likeCount DESC
LIMIT 5;

--(C) Engagement Rate: Calculate likes + dislikes + comments per 1000 views.
SELECT 
    videoTitle,
    channelTitle,
    viewCount,
    likeCount,
    dislikeCount,
    commentCount,
    ROUND((likeCount + dislikeCount + commentCount) * 1000.0 / viewCount) AS engagement_rate_per_1000
FROM trending_videos
WHERE viewCount > 0
ORDER BY engagement_rate_per_1000 DESC;

-- (d) Average Views By Category: Group by videoCategoryLabel and calculate average viewCount.
SELECT videoCategoryLabel, ROUND(AVG(viewCount)) AS average_views 
FROM trending_videos
GROUP BY videoCategoryLabel
ORDER BY average_views DESC;

-- (e) Short VS Long Video Views: 
SELECT
    CASE 
        WHEN durationSec < 300 THEN 'Short'
        WHEN durationSec > 900 THEN 'Long'
        ELSE 'Medium'
    END AS video_length_category,
    ROUND(AVG(viewCount)) AS avg_views
FROM trending_videos
WHERE durationSec < 300 OR durationSec > 900
GROUP BY video_length_category
ORDER BY video_length_category;

-- 3. Content And Category Trends
--(a) Most Common Video Category: Category with the highest number of videos.
SELECT 
    videoCategoryLabel, 
    COUNT(*) AS total_videos
FROM trending_videos
GROUP BY videoCategoryLabel
ORDER BY total_videos DESC
LIMIT 1;

-- (b) View Distribution By Definition: Compare views between HD and SD videos.
SELECT 
    definition,
    COUNT(*) AS video_count,
    SUM(viewCount) AS total_views,
    ROUND(AVG(viewCount)) AS avg_views
FROM trending_videos
GROUP BY definition
ORDER BY total_views DESC;

-- (c) Top Categories By Total Engagement: Sum of likes + comments grouped by category.
SELECT 
    videoCategoryLabel,
    SUM(likeCount + commentCount) AS total_engagement
FROM trending_videos
GROUP BY videoCategoryLabel
ORDER BY total_engagement DESC
LIMIT 5;

-- (d) Daily Uploads Trend: Extract upload day from publishedAt and count uploads per day.
SELECT 
    published_date,
    COUNT(*) AS uploads
FROM trending_videos
GROUP BY published_date
ORDER BY published_date;

-- 4. Advanced SQL Queries
/* (a) Engagement Leaders: Use window functions (RANK() or DENSE_RANK()) 
to find the top video per category by engagement.*/ 
SELECT *
FROM (
    SELECT 
        videoTitle,
        videoCategoryLabel,
        channelTitle,
        likeCount,
        commentCount,
        (likeCount + commentCount) AS engagement,
        RANK() OVER (
            PARTITION BY videoCategoryLabel 
            ORDER BY (likeCount + commentCount) DESC
        ) AS rank_in_category
    FROM trending_videos
) ranked
WHERE rank_in_category = 1;

-- (b) Trending Time Analysis: Extract upload hour and find the peak time range for video uploads.
SELECT 
    EXTRACT(HOUR FROM publishedAt) AS upload_hour,
    COUNT(*) AS video_count
FROM trending_videos
GROUP BY upload_hour
ORDER BY video_count DESC;

/* (c) Performance Outliers: Find videos with a likeCount significantly higher 
than the average for their category.*/
SELECT *
FROM trending_videos AS tv
JOIN (
    SELECT 
        videoCategoryLabel,
        AVG(likeCount) AS avg_likes
    FROM trending_videos
    GROUP BY videoCategoryLabel
) AS avg_data
ON tv.videoCategoryLabel = avg_data.videoCategoryLabel
WHERE tv.likeCount > 1.5 * avg_data.avg_likes
ORDER BY tv.likeCount DESC;

/* (d) Boolean Flag: Create a flag for videos where viewCount > 10000 
AND likeCount/viewCount > 0.1 → “High Engagement”.*/
SELECT 
    videoTitle,
    channelTitle,
    viewCount,
    likeCount,
    ROUND((likeCount / NULLIF(viewCount, 0))::numeric, 2) AS like_ratio,
    CASE 
        WHEN viewCount > 10000 AND (likeCount / NULLIF(viewCount, 0)) > 0.1 THEN 'High Engagement'
        ELSE 'Normal'
    END AS engagement_flag
FROM trending_videos;





