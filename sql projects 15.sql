# What is the total number of records in each table: movie, season, tv_show, and view_summary?
# SELECT 'movie' AS table_name, COUNT(*) AS total_records
# FROM movie
# UNION ALL
# SELECT 'season', COUNT(*)
# FROM season
# UNION ALL
# SELECT 'tv_show', COUNT(*)
# FROM tv_show
# UNION ALL
# SELECT 'view_summary', COUNT(*)
# FROM view_summary;
# 2.  What are the titles, original titles, release dates, and runtimes of all movies released before 2020?
# SELECT
 #   title,
 #    original_title,
 #   release_date,
 #   runtime
# FROM movie
# WHERE release_date < '2020-01-01'
# ORDER BY release_date ASC;
# 3. What are the top 10 longest movies, ranked by runtime?
#SELECT
#    title,
#    original_title,
#    release_date,
#    runtime
# FROM movie
# WHERE runtime IS NOT NULL
# ORDER BY runtime DESC
# LIMIT 10;
# 4.  How many movies were released in each year? Display the years in descending order.
# SELECT
 #   YEAR(release_date) AS release_year,
 #   COUNT(*) AS total_movies
#  FROM movie
# WHERE release_date IS NOT NULL
# GROUP BY YEAR(release_date)
# ORDER BY release_year DESC;
# 5. How many movies belong to each original language or locale? Which five locales have the most movies?
# SELECT
#    COLUMN_NAME,
#    DATA_TYPE,
#    IS_NULLABLE,
#    COLUMN_KEY
# FROM INFORMATION_SCHEMA.COLUMNS
# WHERE TABLE_SCHEMA = DATABASE()
#  AND TABLE_NAME = 'movie'
# ORDER BY ORDINAL_POSITION;
# 6.  What are the average, median, minimum, maximum, and standard deviation of movie runtimes?
# WITH runtime_data AS (
 #   SELECT
 #       runtime,
 #       ROW_NUMBER() OVER (ORDER BY runtime) AS row_num,
 #       COUNT(*) OVER () AS total_rows
 #   FROM movie
 #   WHERE runtime IS NOT NULL
# )
 # SELECT
 #   ROUND(AVG(runtime), 2) AS average_runtime,
 #   (
 #       SELECT AVG(runtime)
 #       FROM runtime_data
 #       WHERE row_num IN (
 #           FLOOR((total_rows + 1) / 2),
 #           FLOOR((total_rows + 2) / 2)
 #       )
 #   ) AS median_runtime,
 #   MIN(runtime) AS minimum_runtime,
 #   MAX(runtime) AS maximum_runtime,
 #   ROUND(STDDEV_POP(runtime), 2) AS standard_deviation
# FROM runtime_data;
# 7.  What percentage of movies are available globally, and how does this compare with movies that are not available globally?
# SELECT
 #   COUNT(*) AS total_movies,
  #  SUM(CASE
  #      WHEN available_globally = 'Yes' THEN 1
  #      ELSE 0
 #   END) AS globally_available,
 #   ROUND(
 #       SUM(CASE WHEN available_globally = 'Yes' THEN 1 ELSE 0 END)
 #       * 100.0 / COUNT(*), 2
 #   ) AS global_percentage,
  #  SUM(CASE
  #      WHEN available_globally = 'No' THEN 1
  #      ELSE 0
  #  END) AS not_globally_available,
 #   ROUND(
 #       SUM(CASE WHEN available_globally = 'No' THEN 1 ELSE 0 END)
 #       * 100.0 / COUNT(*), 2
 #   ) AS not_global_percentage
# FROM movie;
# 8.  How many seasons does each TV show have? Which 10 shows have the most seasons?
# SELECT
#    t.title,
#    COUNT(s.id) AS total_seasons
# FROM tv_show t
# JOIN season s
#    ON t.id = s.tv_show_id
# GROUP BY t.id, t.title
# ORDER BY total_seasons DESC
# LIMIT 10;

# 9.  Which 10 movies or TV shows have the highest total viewing activity, based on the metric available in view_summary?
# SELECT
 #   TABLE_NAME,
 #   COLUMN_NAME,
 #   DATA_TYPE,
 #   COLUMN_TYPE,
 #   IS_NULLABLE,
 #   COLUMN_KEY,
 #   ORDINAL_POSITION
# FROM INFORMATION_SCHEMA.COLUMNS
# WHERE TABLE_SCHEMA = DATABASE()
# AND TABLE_NAME = 'view_summary'
# ORDER BY ORDINAL_POSITION;

# 10. How has the number of movie releases changed across decades, from the 1990s onward?
# SELECT
#    CONCAT(FLOOR(YEAR(release_date) / 10) * 10, 's') AS decade,
#    COUNT(*) AS total_movies
# FROM movie
# WHERE release_date >= '1990-01-01'
# GROUP BY decade
# ORDER BY decade;

# 11. Which movies have runtimes above the overall average? Calculate how many minutes each exceeds the average.
# SELECT
#    title,
#    runtime,
#    ROUND(runtime - (SELECT AVG(runtime)
#                     FROM movie
#                     WHERE runtime IS NOT NULL), 2) AS extra_minutes
# FROM movie
# WHERE runtime > (SELECT AVG(runtime)
#                 FROM movie
#                 WHERE runtime IS NOT NULL)
# ORDER BY extra_minutes DESC;

# 12. Rank movies and TV shows by total viewing activity using SQL window functions. Which titles rank in the top 10?
# DESCRIBE view_summary;
# SELECT *
# FROM view_summary
# LIMIT 10;

# 13.Which movies drove the most viewing in H1 2024, and how deep was the engagement?
# SELECT
#    m.title,
#    v.views,
#    v.hours_viewed,
#    ROUND(v.hours_viewed / NULLIF(v.views, 0), 2) AS hours_per_view,
#    RANK() OVER (ORDER BY v.views DESC) AS reach_rank
# FROM view_summary v
# JOIN movie m ON m.id = v.movie_id
# WHERE v.duration = 'SEMI_ANNUALLY'
#  AND v.start_date = '2024-01-01'
# ORDER BY v.views DESC
# LIMIT 10;

# 14.Which titles had the longest staying power in the weekly Top 10?
# WITH weekly AS (
 #   SELECT movie_id, cumulative_weeks_in_top10, view_rank, views, start_date
 #   FROM view_summary
 #   WHERE duration = 'WEEKLY' AND movie_id IS NOT NULL
# )
# SELECT
 #   m.title,
 #   MAX(w.cumulative_weeks_in_top10)  AS weeks_in_top10,
 #   MIN(w.view_rank)                  AS peak_rank,
 #   MAX(w.views)                      AS peak_weekly_views,
 #   MIN(w.start_date)                 AS first_week,
 #   DENSE_RANK() OVER (ORDER BY MAX(w.cumulative_weeks_in_top10) DESC) AS longevity_rank
# FROM weekly w
# JOIN movie m ON m.id = w.movie_id
# GROUP BY m.id, m.title
# ORDER BY weeks_in_top10 DESC, peak_weekly_views DESC
# LIMIT 10;

# 15 .Which movies lost the most audience between H2 2023 and H1 2024?
# WITH halves AS (
#    SELECT
#        movie_id,
#        SUM(CASE WHEN start_date = '2023-07-01' THEN views END) AS h2_2023_views,
#        SUM(CASE WHEN start_date = '2024-01-01' THEN views END) AS h1_2024_views
#    FROM view_summary
#    WHERE duration = 'SEMI_ANNUALLY' AND movie_id IS NOT NULL
#    GROUP BY movie_id
# )
# SELECT
#   m.title,    h.h2_2023_views,
#   h.h1_2024_views,
# h.h1_2024_views - h.h2_2023_views AS abs_change,
# ROUND(100.0 * (h.h1_2024_views - h.h2_2023_views) / h.h2_2023_views, 1) AS pct_change
# FROM halves h
# JOIN movie m ON m.id = h.movie_id
# WHERE h.h2_2023_views IS NOT NULL
#  AND h.h1_2024_views IS NOT NULL
# ORDER BY abs_change ASC
# LIMIT 10;





