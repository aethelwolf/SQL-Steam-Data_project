SQL-Steam-Data Project
Overview
This repository contains a comprehensive data analysis project focused on the Steam Store, a leading global platform for video game producers to sell and market their games online, owned by Valve Corporation. The project utilizes raw and cleaned datasets from Steam Store and Steam Spy to uncover consumer trends and patterns, aiming to enhance marketing strategies and boost sales.
Project Details

Objective: Analyze consumer trends on the Steam Store to improve marketing and increase sales.
Stakeholders: Gabe Logan (Founder), Valve Corporation Marketing Department, Valve Marketing Analytics Team, and global Steam users/gamers.
Dataset Sources:
Uncleaned: Steam Store Raw Data
Cleaned: Steam Store Games


Tools Used:
SQL (BigQuery) for data import, cleaning, and analysis
Excel for quick visualizations and reference
Tableau for advanced visualizations and recommendations



Data Analysis Process
The project follows a structured data analytics approach:

Ask: Define the business task and key questions (e.g., popular genres, price vs. ownership, multiplayer vs. single-player trends).
Prepare: Import Steam datasets into BigQuery.
Process: Clean data by fixing types, removing nulls/duplicates, and eliminating irrelevant columns.
Analyze: Generate insights using SQL queries (e.g., genre popularity, release timing effects).
Share: Create visualizations in Excel and Tableau to share findings (note: visualizations not included here but can be added).
Act: Apply insights to recommend marketing strategies.

Key Insights

Popular Genres: Action, Indie, Free-to-Play, and Strategy lead in ownership.
Price vs. Ownership: Lower prices don’t directly correlate with higher ownership.
Multiplayer Games: Show 5x higher average ownership than single-player games.
Release Timing: Sales peak in July, October, and November, suggesting seasonal campaign opportunities.
Top Games: Multiplayer, free-to-play Action games (e.g., by Valve) dominate ownership.
Concurrent Users: High engagement in top games offers DLC marketing potential.
Playtime: MMO and Free-to-Play genres, plus software categories, show high playtime.
Ratings: Non-game software (e.g., Training, Web Publishing) scores highest in positive ratings.

Recommendations

Target marketing on Action, Indie, Adventure, and Free-to-Play genres.
Promote multiplayer games emphasizing social connectivity.
Market non-gaming tools like software training and design tools.
Launch campaigns in July, October, and November with holiday themes.
Support top games with DLCs to boost revenue.

Files

docs/: Contains project documentation.
queries/: SQL scripts for data analysis.
tableau_viz/: Placeholder for Tableau dashboard preview (image not included but can be added).

How to Contribute
Feel free to fork this repository, submit issues, or propose enhancements. Contributions to improve data cleaning, analysis, or visualizations are welcome!
License
[Add license information here if applicable]
