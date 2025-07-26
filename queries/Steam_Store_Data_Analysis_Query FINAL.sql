/*
Project: Steam Store Marketing Analysis
Author: Jason Juarbe
Date: 2025-07-14
Datasets:
- Steam Store Raw Data (uncleaned): https://www.kaggle.com/datasets/nikdavis/steam-store-raw?select=steam_app_data.csv
- Steam Store Data (cleaned): https://www.kaggle.com/datasets/nikdavis/steam-store-games?select=steam.csv
Dataset Date: June 12, 2019

TO UPLOAD FILES IN SQL PLEASE FOLLOW THESE DIRECTIONS:

PROJECT NAME: jasons-sandbox-463122

DATA SET: steam_data

Create tables for steam_data: FROM Steam Store Raw Data (uncleaned) csv files:
applist01 <- app_list.csv
unclean_steam_app <- steam_app_data.csv
steamspy_data <- steamspy_data.csv

Create tables for steam_data: FROM Steam Store Raw Data (cleaned) csv files:
steam_app_data_clean <- steam_data_01

Goal: Analyze consumer trends and patterns in video game purchases on the Steam Store to improve marketing and campaign strategies and increase overall sales. These datasets represent real-world products available on the Steam Store.
*/

/*
CHANGE LOG:
2025-07-14: Imported and cleaned table datasets
2025-07-15: Cleaned and reformatted tables
2025-07-16: Filtered tables and started analysis
2025-07-17: Completed analysis
*/

/* RENAME TABLES AND DELETE OLD ONES: Renamed tables for clarity and simplification. */

-- Rename applist_01 to raw_applist
CREATE TABLE `jasons-sandbox-463122.steam_data.raw_applist` AS
SELECT *
FROM `jasons-sandbox-463122.steam_data.applist01` ;

-- Rename un_cleaned_steam_app to raw_app_data_unknown
CREATE TABLE `jasons-sandbox-463122.steam_data.raw_app_data_unknown` AS
SELECT *
FROM `jasons-sandbox-463122.steam_data.unclean_steam_app` ;

-- Rename steamspy_data to raw_steamspy
CREATE TABLE `jasons-sandbox-463122.steam_data.raw_steamspy` AS
SELECT *
FROM `jasons-sandbox-463122.steam_data.steamspy_data` ;

-- Create table cleaned_steam_data for cleaned and merged datasets
CREATE TABLE `jasons-sandbox-463122.steam_data.clean_steam_data` AS
SELECT *
FROM `jasons-sandbox-463122.steam_data.steam_app_data_clean` ;

/* EXAMINE AND INSPECT: Preview, familiarize, and inspect datasets to gain a deeper understanding of their contents. */

-- Inspect raw_applist (cleaning required: remove nulls and duplicates)
SELECT *
FROM `jasons-sandbox-463122.steam_data.raw_applist`
LIMIT 10000;

-- Inspect raw_steamspy (cleaning required: format 'owners' from string to integer, add decimals to 'price' and 'initialprice', convert to price format, remove nulls and duplicates)
SELECT *
FROM `jasons-sandbox-463122.steam_data.raw_steamspy`
LIMIT 1000;

-- Inspect raw_app_data_unknown (removing this dataset due to excessive nulls and irrelevant information)
SELECT *
FROM `jasons-sandbox-463122.steam_data.raw_app_data_unknown`
LIMIT 5000;

/* CLEAN TABLES: 
After familiarizing myself with the datasets, I will begin cleaning. First, remove the irrelevant table 'raw_app_data_unknown'. Then, clean tables raw_applist and raw_steamspy by addressing nulls, missing values, spelling, spacing, ranges, distinct values, irrelevant information, inconsistencies, and adding dates.
*/

-- Remove irrelevant table
DROP TABLE `jasons-sandbox-463122.steam_data.raw_app_data_unknown`;

-- Noticed raw_applist contains columns 'appid' and 'name', which are already in raw_steamspy. Comparing both tables to check if raw_applist is redundant.
-- First, create a new table for raw_steamspy to format appid from string to integer
CREATE TABLE `jasons-sandbox-463122.steam_data.raw_steamspy_v2` AS
SELECT
  CAST(appid AS INT64) AS appid,
  name,
  developer,
  publisher,
  score_rank,
  positive,
  negative,
  userscore,
  owners,
  average_forever,
  average_2weeks,
  median_forever,
  median_2weeks,
  price,
  initialprice,
  discount,
  languages,
  genre,
  ccu,
  tags
FROM `jasons-sandbox-463122.steam_data.raw_steamspy`
WHERE SAFE_CAST(appid AS INT64) IS NOT NULL;

-- Check which rows were removed
SELECT *
FROM `jasons-sandbox-463122.steam_data.raw_steamspy`
WHERE SAFE_CAST(appid AS INT64) IS NULL;

-- Delete raw_steamspy table
DROP TABLE `jasons-sandbox-463122.steam_data.raw_steamspy`;

-- Compare tables using JOIN to count common appids between raw_applist and raw_steamspy_v2 to check for redundancy
-- Result: 29228 matching appids, same as the row count in raw_steamspy_v2
SELECT COUNT(*) AS matching_appids
FROM `jasons-sandbox-463122.steam_data.raw_applist` a
INNER JOIN `jasons-sandbox-463122.steam_data.raw_steamspy_v2` s
ON a.appid = s.appid;

-- Check which appids exist in raw_applist but not in raw_steamspy_v2
SELECT a.appid, a.name
FROM `jasons-sandbox-463122.steam_data.raw_applist` a
LEFT JOIN `jasons-sandbox-463122.steam_data.raw_steamspy_v2` s
ON s.appid = a.appid
WHERE s.appid IS NULL;

-- Confirmed raw_applist is redundant, so it will be removed
DROP TABLE `jasons-sandbox-463122.steam_data.raw_applist`;

/* Import a new dataset from the same Kaggle author to add release dates for appids and cross-reference the raw dataset for accuracy. Clean raw_steamspy_v2 before joining with clean_steam_data for the release_date column. */

SELECT
  COUNT(*) AS total_rows,
  COUNT(appid) AS appid_non_null,
  COUNT(name) AS name_non_null,
  COUNT(developer) AS developer_non_null,
  COUNT(publisher) AS publisher_non_null,
  COUNT(score_rank) AS score_rank_non_null,
  COUNT(positive) AS positive_non_null,
  COUNT(negative) AS negative_non_null,
  COUNT(userscore) AS userscore_non_null,
  COUNT(owners) AS owners_non_null,
  COUNT(price) AS price_non_null,
  COUNT(genre) AS genre_non_null,
  COUNT(average_forever) AS average_forever_non_null,
  COUNT(discount) AS discount_non_null,
  COUNT(languages) AS languages_non_null,
  COUNT(ccu) AS ccu_non_null,
  COUNT(tags) AS tags_non_clean
FROM `jasons-sandbox-463122.steam_data.raw_steamspy_v2`;

-- Create a new table for raw_steamspy_v2, removing score_rank due to excessive nulls and average_2weeks, median_forever, median_2weeks, initialprice due to irrelevance for analysis. Remove rows with nulls.
CREATE OR REPLACE TABLE `jasons-sandbox-463122.steam_data.cleaned_steamspy_v3` AS
SELECT
  appid,
  name,
  developer,
  publisher,
  positive,
  negative,
  userscore,
  owners,
  average_forever,
  price,
  discount,
  languages,
  genre,
  ccu,
  tags
FROM `jasons-sandbox-463122.steam_data.raw_steamspy_v2`
WHERE
  appid IS NOT NULL
  AND name IS NOT NULL
  AND developer IS NOT NULL
  AND publisher IS NOT NULL
  AND positive IS NOT NULL
  AND negative IS NOT NULL
  AND userscore IS NOT NULL
  AND owners IS NOT NULL
  AND average_forever IS NOT NULL
  AND price IS NOT NULL
  AND initialprice IS NOT NULL
  AND discount IS NOT NULL
  AND languages IS NOT NULL
  AND genre IS NOT NULL
  AND ccu IS NOT NULL
  AND tags IS NOT NULL;

-- Remove raw_steamspy_v2 table
DROP TABLE `jasons-sandbox-463122.steam_data.raw_steamspy_v2`;

-- Check cleaned_steamspy_v3 for duplicate appids
SELECT 
  appid,
  COUNT(*) AS count
FROM `jasons-sandbox-463122.steam_data.cleaned_steamspy_v3`
GROUP BY appid
HAVING COUNT(*) > 1
ORDER BY count DESC;
-- No duplicate appids found

-- Rename columnas for clarity and consistency
CREATE OR REPLACE TABLE `jasons-sandbox-463122.steam_data.cleaned_steamspy_v4` AS
SELECT
  appid,
  name,
  developer,
  publisher,
  positive AS positive_ratings,
  negative AS negative_ratings,
  userscore AS user_score,
  owners,
  average_forever AS average_playtime,
  price,
  discount,
  languages,
  genre,
  ccu AS concurrent_users,
  tags
FROM `jasons-sandbox-463122.steam_data.cleaned_steamspy_v3`;

-- Convert price column to FLOAT and add decimals
CREATE OR REPLACE TABLE `jasons-sandbox-463122.steam_data.cleaned_steamspy_v5` AS
SELECT
  appid,
  name,
  developer,
  publisher,
  positive_ratings,
  negative_ratings,
  user_score,
  owners,
  average_playtime,
  CAST(price AS FLOAT64) / 100.0 AS price,
  discount,
  languages,
  genre,
  concurrent_users,
  tags
FROM `jasons-sandbox-463122.steam_data.cleaned_steamspy_v4`;

-- Join missing columns from clean_steam_data into cleaned_steamspy_v5
-- Join release_date from clean_steam_data
CREATE OR REPLACE TABLE `jasons-sandbox-463122.steam_data.cleaned_steamspy_v6` AS
SELECT
  v.*,
  c.release_date
FROM `jasons-sandbox-463122.steam_data.cleaned_steamspy_v5` AS v
LEFT JOIN `jasons-sandbox-463122.steam_data.clean_steam_data` AS c
  ON v.appid = c.appid;

-- Add platforms, required_age, categories, steamspy_tags from clean_steam_data to cleaned_steamspy_v6
CREATE OR REPLACE TABLE `jasons-sandbox-463122.steam_data.cleaned_steamspy_v7` AS
SELECT
  v.*,
  c.platforms,
  c.required_age,
  c.categories,
  c.steamspy_tags
FROM `jasons-sandbox-463122.steam_data.cleaned_steamspy_v6` v
LEFT JOIN `jasons-sandbox-463122.steam_data.clean_steam_data` c
  ON v.appid = c.appid;

-- Remove user_score, discount, tags columns from cleaned_steamspy_v7 and reorganize columns for better format
CREATE OR REPLACE TABLE `jasons-sandbox-463122.steam_data.cleaned_steamspy_v7` AS
SELECT
  appid AS app_id,
  name,
  release_date,
  developer,
  publisher,
  platforms,
  categories,
  genre,
  steamspy_tags,
  languages,
  required_age,
  positive_ratings,
  negative_ratings,
  owners,
  price,
  average_playtime,
  concurrent_users
FROM `jasons-sandbox-463122.steam_data.cleaned_steamspy_v7`;

-- Remove old versions of tables
DROP TABLE `jasons-sandbox-463122.steam_data.cleaned_steamspy_v3`;
DROP TABLE `jasons-sandbox-463122.steam_data.cleaned_steamspy_v4`;
DROP TABLE `jasons-sandbox-463122.steam_data.cleaned_steamspy_v5`;
DROP TABLE `jasons-sandbox-463122.steam_data.cleaned_steamspy_v6`;

-- Convert owners column in cleaned_steamspy_v7 to integer and calculate midpoint between the two numbers
CREATE OR REPLACE TABLE `jasons-sandbox-463122.steam_data.cleaned_steamspy_v8` AS
SELECT
  *,
  CAST((
    SAFE_CAST(REPLACE(SPLIT(owners, ' .. ')[OFFSET(0)], ',', '') AS INT64) +
    SAFE_CAST(REPLACE(SPLIT(owners, ' .. ')[OFFSET(1)], ',', '') AS INT64)
  ) / 2 AS INT64) AS owners_mid
FROM `jasons-sandbox-463122.steam_data.cleaned_steamspy_v7`;

-- Replace delimiters in cleaned_steamspy_v8 genre column from commas to semicolons for consistency
CREATE OR REPLACE TABLE `jasons-sandbox-463122.steam_data.cleaned_steamspy_v9` AS
SELECT
  *,
  REPLACE(genre, ',', ';') AS genre_clean
FROM `jasons-sandbox-463122.steam_data.cleaned_steamspy_v8` ;

-- Address additional delimiter inconsistencies
CREATE OR REPLACE TABLE `jasons-sandbox-463122.steam_data.cleaned_steamspy_v10_step1` AS
SELECT
  *,
  REPLACE(categories, ',', ';') AS categories_clean,
  REPLACE(steamspy_tags, ',', ';') AS steamspy_tags_clean,
  REPLACE(platforms, ',', ';') AS platforms_clean,
  REPLACE(languages, ',', ';') AS languages_clean
FROM
  `jasons-sandbox-463122.steam_data.cleaned_steamspy_v9`;

-- Clean negative values and convert developer, publisher, and name to lowercase with trimming
CREATE OR REPLACE TABLE `jasons-sandbox-463122.steam_data.cleaned_steamspy_v10_step2` AS
SELECT
  *,
  TRIM(LOWER(developer)) AS developer_clean,
  TRIM(LOWER(publisher)) AS publisher_clean,
  TRIM(name) AS name_clean
FROM
  `jasons-sandbox-463122.steam_data.cleaned_steamspy_v10_step1`;

-- Replace nulls in numeric columns with 0
CREATE OR REPLACE TABLE `jasons-sandbox-463122.steam_data.cleaned_steamspy_v10_step3` AS
SELECT
  *,
  IFNULL(positive_ratings, 0) AS positive_ratings_filled,
  IFNULL(negative_ratings, 0) AS negative_ratings_filled,
  IFNULL(required_age, 0) AS required_age_filled,
  IFNULL(average_playtime, 0) AS average_playtime_filled,
  IFNULL(concurrent_users, 0) AS concurrent_users_filled,
  IFNULL(owners_mid, 0) AS owners_mid_filled
FROM
  `jasons-sandbox-463122.steam_data.cleaned_steamspy_v10_step2`;

-- Create new columns for total_ratings and percent_positive
CREATE OR REPLACE TABLE `jasons-sandbox-463122.steam_data.cleaned_steamspy_v10_step4` AS
SELECT
  *,
  positive_ratings_filled + negative_ratings_filled AS total_ratings,
  SAFE_DIVIDE(positive_ratings_filled, positive_ratings_filled + negative_ratings_filled) AS percent_positive
FROM
  `jasons-sandbox-463122.steam_data.cleaned_steamspy_v10_step3`;

-- Remove updated columns for cleanliness
CREATE OR REPLACE TABLE `jasons-sandbox-463122.steam_data.cleaned_steamspy_v10_final` AS
SELECT
  app_id,
  name_clean AS name,
  release_date,
  developer_clean AS developer,
  publisher_clean AS publisher,
  REPLACE(platforms, ',', ';') AS platforms,
  categories_clean AS categories,
  genre_clean AS genre,
  steamspy_tags_clean AS steamspy_tags,
  languages_clean AS languages,
  required_age_filled AS required_age,
  positive_ratings_filled AS positive_ratings,
  negative_ratings_filled AS negative_ratings,
  price,
  average_playtime_filled AS average_playtime,
  concurrent_users_filled AS concurrent_users,
  owners_mid_filled AS owners,
  total_ratings,
  percent_positive
FROM
  `jasons-sandbox-463122.steam_data.cleaned_steamspy_v10_step4`;

-- Round percent_positive to 2 decimal places
CREATE OR REPLACE TABLE `jasons-sandbox-463122.steam_data.cleaned_steamspy_v10_final` AS
SELECT
  *,
  ROUND(percent_positive, 2) AS percent_positive_rounded
FROM
  `jasons-sandbox-463122.steam_data.cleaned_steamspy_v10_step4`;

-- Final cleanup of columns
CREATE OR REPLACE TABLE `jasons-sandbox-463122.steam_data.cleaned_steamspy_v11` AS
SELECT
  app_id,
  name_clean AS name,
  release_date,
  developer_clean AS developer,
  publisher_clean AS publisher,
  platforms_clean AS platforms,
  categories_clean AS categories,
  genre_clean AS genre,
  steamspy_tags_clean AS steamspy_tags,
  languages_clean AS languages,
  required_age_filled AS required_age,
  positive_ratings_filled AS positive_ratings,
  negative_ratings_filled AS negative_ratings,
  price,
  average_playtime_filled AS average_playtime,
  concurrent_users_filled AS concurrent_users,
  owners_mid_filled AS owners_mid,
  total_ratings,
  percent_positive_rounded AS percent_positive
FROM
  `jasons-sandbox-463122.steam_data.cleaned_steamspy_v10_final`;

-- Remove all old table versions
DROP TABLE `jasons-sandbox-463122.steam_data.cleaned_steamspy_v10_final`;
DROP TABLE `jasons-sandbox-463122.steam_data.cleaned_steamspy_v10_step1`;
DROP TABLE `jasons-sandbox-463122.steam_data.cleaned_steamspy_v10_step2`;
DROP TABLE `jasons-sandbox-463122.steam_data.cleaned_steamspy_v10_step3`;
DROP TABLE `jasons-sandbox-463122.steam_data.cleaned_steamspy_v10_step4`;
DROP TABLE `jasons-sandbox-463122.steam_data.cleaned_steamspy_v7`;
DROP TABLE `jasons-sandbox-463122.steam_data.cleaned_steamspy_v8`;
DROP TABLE `jasons-sandbox-463122.steam_data.cleaned_steamspy_v9`;

-- Add estimated_revenue column by multiplying owners_mid and price
CREATE OR REPLACE TABLE `jasons-sandbox-463122.steam_data.cleaned_steamspy_v12` AS
SELECT
  *,
  owners_mid * price AS estimated_revenue
FROM
  `jasons-sandbox-463122.steam_data.cleaned_steamspy_v11`;

-- Reorganize columns for final analysis
CREATE OR REPLACE TABLE `jasons-sandbox-463122.steam_data.cleaned_steamspy` AS
SELECT
  app_id,
  name,
  release_date,
  developer,
  publisher,
  platforms,
  categories,
  genre AS genres,
  steamspy_tags,
  languages,
  required_age,
  positive_ratings,
  negative_ratings,
  total_ratings,
  percent_positive,
  owners_mid AS estimated_owners,
  price,
  estimated_revenue,
  average_playtime,
  concurrent_users
FROM `jasons-sandbox-463122.steam_data.cleaned_steamspy_v12`;

-- Remove final old table versions
DROP TABLE `jasons-sandbox-463122.steam_data.cleaned_steamspy_v11`;
DROP TABLE `jasons-sandbox-463122.steam_data.cleaned_steamspy_v12`;

-- Check for duplicates in app_id before analysis
SELECT
  app_id,
  COUNT(*) AS count
FROM `jasons-sandbox-463122.steam_data.cleaned_steamspy`
GROUP BY
  app_id
HAVING
  COUNT(*) > 1;
-- No duplicates found, ready for analysis

-- Check for price outliers, cross-referenced with Steam Store for accuracy
SELECT 
  name,
  price
FROM `jasons-sandbox-463122.steam_data.cleaned_steamspy`
ORDER BY price DESC;

-- Remove publisher column due to irrelevance
CREATE OR REPLACE TABLE `jasons-sandbox-463122.steam_data.cleaned_steamspy` AS
SELECT
  app_id,
  name,
  release_date,
  developer,
  platforms,
  categories,
  genres,
  steamspy_tags,
  languages,
  required_age,
  positive_ratings,
  negative_ratings,
  total_ratings,
  percent_positive,
  estimated_owners,
  price,
  estimated_revenue,
  average_playtime,
  concurrent_users
FROM `jasons-sandbox-463122.steam_data.cleaned_steamspy`;

/* ANALYSIS: With cleaned, consolidated, and enhanced data in cleaned_steamspy, analysis can now begin. */

-- Split genres column by semicolon and analyze popularity based on estimated owners. Results exported to Excel for charting.
WITH genre_split AS (
  SELECT 
    name,
    estimated_owners,
    TRIM(genre) AS genre
  FROM `jasons-sandbox-463122.steam_data.cleaned_steamspy`,
  UNNEST(SPLIT(genres, ';')) AS genre
)
SELECT 
  genre,
  COUNT(*) AS number_of_games,
  SUM(estimated_owners) AS total_estimated_owners,
  ROUND(AVG(estimated_owners)) AS avg_estimated_owners
FROM genre_split
WHERE genre IS NOT NULL AND genre != ''
GROUP BY genre
ORDER BY total_estimated_owners DESC
LIMIT 10;
-- Action, Indie, Free to Play, and Strategy are the most popular genres by estimated owners.

-- Do cheaper games have more owners?
SELECT
  ROUND(price, 2) AS price,
  COUNT(*) AS num_of_games,
  ROUND(AVG(estimated_owners)) AS avg_estimated_owners
FROM `jasons-sandbox-463122.steam_data.cleaned_steamspy`
WHERE
  estimated_owners IS NOT NULL
  AND price IS NOT NULL
GROUP BY
  price
ORDER BY
  price ASC;
-- Results show no strong correlation between lower price points and higher estimated owners.

-- Clean nulls to improve accuracy and clarity
CREATE OR REPLACE TABLE `jasons-sandbox-463122.steam_data.cleaned_steamspy_v2` AS
SELECT *
FROM `jasons-sandbox-463122.steam_data.cleaned_steamspy`
WHERE 
  app_id IS NOT NULL
  AND name IS NOT NULL
  AND release_date IS NOT NULL
  AND developer IS NOT NULL
  AND platforms IS NOT NULL
  AND categories IS NOT NULL
  AND genres IS NOT NULL
  AND steamspy_tags IS NOT NULL
  AND languages IS NOT NULL
  AND required_age IS NOT NULL
  AND positive_ratings IS NOT NULL
  AND negative_ratings IS NOT NULL
  AND total_ratings IS NOT NULL
  AND percent_positive IS NOT NULL
  AND estimated_owners IS NOT NULL
  AND price IS NOT NULL
  AND estimated_revenue IS NOT NULL
  AND average_playtime IS NOT NULL
  AND concurrent_users IS NOT NULL;

-- Remove cleaned_steamspy table with nulls
DROP TABLE `jasons-sandbox-463122.steam_data.cleaned_steamspy`;

-- Do multiplayer games have higher sales than single-player games?
SELECT
  CASE 
    WHEN categories LIKE '%Multi-player%' OR categories LIKE '%Online Multi-Player%' THEN 'Multiplayer'
    WHEN categories LIKE '%Single-player%' THEN 'Single Player'
    ELSE 'Other'
  END AS game_type,
  COUNT(*) AS num_games,
  ROUND(AVG(estimated_owners)) AS avg_estimated_owners
FROM
  `jasons-sandbox-463122.steam_data.cleaned_steamspy_v2`
GROUP BY
  game_type
ORDER BY
  avg_estimated_owners DESC;

-- Does release timing affect sales?
SELECT
  EXTRACT(MONTH FROM release_date) AS release_month,
  COUNT(*) AS num_games,
  ROUND(AVG(estimated_owners)) AS avg_estimated_owners
FROM
  `jasons-sandbox-463122.steam_data.cleaned_steamspy_v2`
GROUP BY
  release_month
ORDER BY
  release_month;

-- Ensure consistent delimiters before exporting to Google Sheets
-- Identify top 10 games and their common characteristics
SELECT
  name,
  release_date,
  developer,
  platforms,
  categories,
  genres,
  steamspy_tags,
  positive_ratings,
  negative_ratings,
  percent_positive,
  estimated_owners,
  price,
  estimated_revenue,
  average_playtime,
  concurrent_users
FROM `jasons-sandbox-463122.steam_data.cleaned_steamspy_v2`
ORDER BY estimated_owners DESC
LIMIT 10;

-- Identify top 5 games by concurrent users
SELECT
  name,
  concurrent_users AS `concurrent users`,
  developer,
  platforms,
  genres,
  price
FROM `jasons-sandbox-463122.steam_data.cleaned_steamspy_v2`
ORDER BY concurrent_users DESC
LIMIT 5;
-- Top games: Dota 2, PLAYERUNKNOWN'S BATTLEGROUNDS, Counter-Strike: Global Offensive

-- Do certain genres have higher average playtime (e.g., RPGs vs. casual games)?
SELECT 
  genre AS individual_genre,
  ROUND(AVG(average_playtime), 2) AS avg_playtime_minutes
FROM (
  SELECT 
    TRIM(genre) AS genre,
    average_playtime
  FROM `jasons-sandbox-463122.steam_data.cleaned_steamspy_v2`,
  UNNEST(SPLIT(genres, ';')) AS genre
  WHERE 
    genres IS NOT NULL AND
    average_playtime IS NOT NULL
)
GROUP BY individual_genre
ORDER BY avg_playtime_minutes DESC
LIMIT 10;
-- Massively multiplayer and free-to-play games have the highest average playtime.

-- Which developers have the most owners?
SELECT 
  name,
  developer,
  estimated_owners
FROM `jasons-sandbox-463122.steam_data.cleaned_steamspy_v2`
ORDER BY estimated_owners DESC
LIMIT 10;
-- Valve dominates in estimated owners.

-- Which games 10 years or older have high concurrent players?
SELECT
  name,
  release_date,
  concurrent_users,
  total_ratings,
  average_playtime,
  genres
FROM
  `jasons-sandbox-463122.steam_data.cleaned_steamspy_v2`
WHERE
  release_date <= DATE_SUB(CURRENT_DATE(), INTERVAL 10 YEAR)
  AND concurrent_users IS NOT NULL
ORDER BY
  concurrent_users DESC
LIMIT 5;
-- Action-based genres tend to remain popular over time.

-- Average positive rating by genre
SELECT
  genre AS individual_genre,
  ROUND(AVG(percent_positive), 2) AS avg_percent_positive
FROM
  `jasons-sandbox-463122.steam_data.cleaned_steamspy_v2`,
  UNNEST(SPLIT(genres, ';')) AS genre
WHERE
  genres IS NOT NULL
  AND percent_positive IS NOT NULL
GROUP BY
  individual_genre
ORDER BY
  avg_percent_positive DESC
LIMIT 20;
-- Some of the highest-rated products are non-games.
