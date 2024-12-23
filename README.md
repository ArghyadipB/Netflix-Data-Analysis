# Netflix-Data-Analysis
This project entails a thorough SQL analysis of Netflix's movie and TV show data. The objective is to use the dataset to answer a variety of business questions and extract insightful information. The project's goals, business issues, solutions, findings, and conclusions are all thoroughly described in the README that follows.

## Author(s)
**Arghyadip Bagchi**
Linkedin profile: https://linkedin.com/in/arghyadip-bagchi\
GitHub profile: https://github.com/ArghyadipB

## Objective
* Examine how different content types are distributed (movies vs. TV shows).
* Determine the most popular movie and TV show ratings.
* Sort and evaluate content according to countries, years of release, and durations.
* Examine and group content according to particular standards and keywords.

## Dataset
The dataset can be found from the kaggle link: [Netflix Movie Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema
```postgresql
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
); 
```

## Business Problem and Solutions

### 1. Count the number of Movies vs TV Shows
```postgresql
SELECT 
	type,
	COUNT(type)
FROM netflix
GROUP BY type;
```
**Objective**: Determine the distribution of content types on Netflix.
### 2. Find the most common rating for Movies and TV shows
```postgresql
SELECT type, rating, count FROM
(SELECT
	type,
	rating,
	COUNT(rating),
	RANK() OVER (PARTITION BY type ORDER BY COUNT(rating) DESC) AS rank
FROM netflix
GROUP BY type, rating)
WHERE rank = 1;
```
**Objective**: Determine which rating appears most frequently for each kind of material.\
**Impact**: Better content recommendation and content acquisition

### 3. List all movies released in a specific year (e.g., 2020)
```postgresql
SELECT 
	title
FROM netflix
WHERE type = 'Movie' AND release_year = 2020;
```
**Object**: Get all the contents of a particular year.\
**Impact**: May be used to know how the contents performed in a particular year. 

### 4. Find the top 5 countries with the most content on Netflix
```postgresql
SELECT 
	TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) as new_country,
	COUNT(show_id) as total_content
FROM netflix
WHERE country IS NOT NULL
GROUP BY new_country
ORDER BY total_content DESC
LIMIT 5;
```
**Objective**: Determine which five countries have the most content items.\
**Impact**: Can be used to assess how the platform is doing and where the platform is most popular.

### 5. Identify the longest movie
```postgresql
SELECT 
	title,
	duration
FROM netflix
WHERE type = 'Movie' AND duration IS NOT NULL
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC;
```
**Objective**: To find out the movie with the longest runtime.\
**Impact**: Can be used to see how the content with the longest duration is doing with respect to other content.

### 6. Find content added in the last 5 years
```postgresql
SELECT
	*
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';
```
**Objective**: Retrieve content added to Netflix in the last 5 years.\
**Impact**: Can be used to see how many contents were added in the last 5 years for advanced analytics like trend analysis and performance evaluation.


### 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
```postgresql
SELECT
	title,
	director
FROM netflix
WHERE director LIKE '%Rajiv Chilaka%'
```
**Objective**: Get all the contents directed by a director.\
**Impact**: Can be used to analyze how the contents of a director are performing, thus exploring the further possibilities of further collaboration with that director.

### 8. List all TV shows with more than 5 seasons
```postgresql
SELECT
	title,
	duration
FROM netflix
WHERE type = 'TV Show' AND SPLIT_PART(duration, ' ', 1)::INT > 5
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC;
```
**Objective**: Identify TV shows with more than 5 seasons.\
**Impact**: Can be used to show how well liked a TV show is.

### 9. Count the number of content items in each genre
```postgresql
SELECT 
	TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) as new_genre,
	COUNT(*) AS total_content
FROM netflix
GROUP BY new_genre
ORDER BY total_content DESC;
```
**Objective**: Count the number of content items in each genre.\
**Impact**: Can be used to analyze genre popularity, diversity, market share and genre based content recommendation.

### 10. Find each year the number of contents released by India monthly on netflix. 
```postgresql
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
```
**Objective**: Finding out the number of contents per year, per month, in a country like India.\
**Impact**: Can be used to analyze the year-to-year growth in the number of contents. Also can be used for trend identification and market share analysis for a particular analysis. 

### 11. List all movies that are documentaries
```postgresql
SELECT * FROM netflix
WHERE listed_in LIKE '%Documentaries%';
```
**Objective**: Retrieve all movies that are documentaries.\
**Impact**: Listing all the documentaries.

### 12. Find all content without a director
```postgresql
SELECT * FROM netflix
WHERE director IS NULL;
```
**Objective**: Get all the contents without director.\
**Impact**: Finding uncleaned data, such as null values.

### 13. How many Indian TV Series were released in last 10 years
```postgresql
SELECT
	country,
	COUNT(*) as last_10_yr_count
FROM netflix
WHERE country = 'India' AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10
GROUP BY country
```
**Objective**: Get the TV series released by India in the last 10 years.\
**Impact**: Finding out the recent performance of the platform in showing TV series in a particular country like India, can help in future content curation and profit assessment.

### 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
```postgresql
SELECT 
	UNNEST(STRING_TO_ARRAY(casts, ',')) as actor,
	COUNT(*) AS content_count
FROM netflix
WHERE country = 'India'
GROUP BY actor
ORDER BY content_count DESC
LIMIT 10;
```
**Objective**: Identify the top 10 actors with the most appearances in Indian-produced movies.\
**Impact**: Finding out the most popular actors in a region for better content recommendation.

### 15: Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field. Label content containing these keywords as 'Bad_for_children' and all other content as 'Good_for_children'. Count how many items fall into each category across movies and tv series.
```postgresql
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
```
**Objective**: Categorize content as 'Bad_for_children' if it contains 'kill' or 'violence' and 'Good_for_children' otherwise. Count the number of items in each category across movies and TV series.\
**Object**: Can be used to filter content for children and thus make better recommendations when the user creates a "Kid's profile".

## Findings and Conclusions
**Distribution of Content**: The dataset includes a wide variety of films and television series with different genres and ratings.\
**Common Ratings**: Knowledge of the most popular ratings helps determine who the content is intended for.\
**Geographical Insights**: Regional content distribution is highlighted by the top nations and India's average content releases.\
**Content Categorisation**: Sorting content according to particular keywords aids in comprehending the type of content that is accessible on Netflix.\
This research offers a thorough look into Netflix's content and can assist in guiding decision-making and content strategy.