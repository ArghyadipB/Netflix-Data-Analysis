-- Start of Report


-- Showing all the columns
SELECT * FROM netflix;


-- 1. Count the number of Movies vs TV Shows
SELECT 
	type,
	COUNT(type)
FROM netflix
GROUP BY type;


-- 2. Find the most common rating for movies and TV shows
SELECT type, rating, count FROM
(SELECT
	type,
	rating,
	COUNT(rating),
	RANK() OVER (PARTITION BY type ORDER BY COUNT(rating) DESC) AS rank
FROM netflix
GROUP BY type, rating)
WHERE rank = 1;


-- 3. List all movies released in a specific year (e.g., 2020)
SELECT 
	title
FROM netflix
WHERE type = 'Movie' AND release_year = 2020;


-- 4. Find the top 5 countries with the most content on Netflix
SELECT 
	TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) as new_country,
	COUNT(show_id) as total_content
FROM netflix
WHERE country IS NOT NULL
GROUP BY new_country
ORDER BY total_content DESC
LIMIT 5;


-- 5. Identify the longest movie
SELECT 
	title,
	duration
FROM netflix
WHERE type = 'Movie' AND duration IS NOT NULL
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC;


-- 6. Find content added in the last 5 years
SELECT
	*
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';


-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
SELECT
	title,
	director
FROM netflix
WHERE director LIKE '%Rajiv Chilaka%'


-- 8. List all TV shows with more than 5 seasons
SELECT
	title,
	duration
FROM netflix
WHERE type = 'TV Show' AND SPLIT_PART(duration, ' ', 1)::INT > 5
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC;


-- 9. Count the number of content items in each genre
SELECT 
	TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) as new_genre,
	COUNT(*) AS total_content
FROM netflix
GROUP BY new_genre
ORDER BY total_content DESC;


-- 10. Find each year the monthly number of contents released by India on netflix. 
SELECT 
	year,
	TO_CHAR(TO_DATE(month || ' 1', 'MM DD'), 'Month') AS month_name,
	COUNT(month)
	FROM (
SELECT
    country,
    title,
    EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year,
	EXTRACT(MONTH FROM TO_DATE(date_added, 'Month DD, YYYY')) AS month
FROM netflix
WHERE country = 'India') AS sub_q
GROUP BY year, month
ORDER BY year, month


-- 11. List all movies that are documentaries
SELECT * FROM netflix
WHERE listed_in LIKE '%Documentaries%';


-- 12. Find all content without a director
SELECT * FROM netflix
WHERE director IS NULL;


-- 13. How many Indian TV Series were released in last 10 years
SELECT
	country,
	COUNT(*) as last_10_yr_count
FROM netflix
WHERE country = 'India' AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10
GROUP BY country


-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
SELECT 
	UNNEST(STRING_TO_ARRAY(casts, ',')) as actor,
	COUNT(*) AS content_count
FROM netflix
WHERE country = 'India'
GROUP BY actor
ORDER BY content_count DESC
LIMIT 10


-- 15: Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
-- the description field. Label content containing these keywords as 'Bad_for_children' and all other 
-- content as 'Good_for_children'. Count how many items fall into each category across movie and tv series.
SELECT 
	type,
	category_for_children,
	count(*)
FROM
(
SELECT 
	type,
	CASE 
		WHEN description LIKE '%kill%' OR description LIKE '%violence%' THEN 'Bad'
		ELSE 'Good'
	END AS category_for_children
FROM netflix
)
GROUP BY type, category_for_children


-- End of report