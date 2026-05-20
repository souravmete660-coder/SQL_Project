#Netflix project
create database netflix_db;

show variables like "secure_file_priv";
 
 drop table netflix;
 
create table netflix(
show_id varchar(10),
type varchar(10),
title varchar(120),
director varchar(210),
cast varchar(900),
country varchar(150),
date_added varchar(50),
release_year int,
rating varchar(15),
duration varchar(20),
listed_in varchar(85),
description varchar(150)
);

load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads"
into table netflix
fields terminated by ','
lines terminated by'\n'
ignore 1 lines;


#1. Count the number of Movies vs TV Shows
select type, count(*) as total_content
 from netflix
 group by type;
 
 #2. Find the most common rating for movies and TV shows
select type, rating 
from
(select type, rating,
count(*),
rank() over (partition by type order by count(*) desc) as ranking
from netflix
group by type, rating)
as t1
where ranking = 1;

#3. List all movies released in a specific year (e.g., 2020)
select * from netflix
where type = 'Movie' and release_year = 2020;

#4. Find the top 5 countries with the most content on Netflix

select 
(select unnest(string_to_array(country, ',')) as new_country
from netflix),
count(*) as content
from netflix
group by country
order by count(cast) desc limit 5;

#5. Identify the longest movie

select * from netflix
where type='Movie' and
duration = (select max(duration) from netflix);

#6. Find content added in the last 5 years

select * from netflix
where to_date(date_added, 'month DD, YYYY') = current_date - interval '5 years';

#7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

select * from netflix
where director like '%Rajiv Chilaka%';

#8. List all TV shows with more than 5 seasons

select * from netflix
where type = 'TV show'
and
split_part(duration, ' ',1)>5;

#9. Count the number of content items in each genre

WITH RECURSIVE genre_split AS (
    SELECT 
        show_id,
        TRIM(SUBSTRING_INDEX(listed_in, ',', 1)) AS genre,
        SUBSTRING(listed_in, LENGTH(SUBSTRING_INDEX(listed_in, ',', 1)) + 2) AS rest
    FROM netflix

    UNION ALL

    SELECT 
        show_id,
        TRIM(SUBSTRING_INDEX(rest, ',', 1)),
        SUBSTRING(rest, LENGTH(SUBSTRING_INDEX(rest, ',', 1)) + 2)
    FROM genre_split
    WHERE rest != ''
)

SELECT 
    genre,
    COUNT(show_id) AS total_content
FROM genre_split
GROUP BY genre
ORDER BY total_content DESC;

#10.Find each year and the average numbers of content release in India on netflix. 

select 
extract (year from to_date(date_added, 'Month DD, YYYY' )) as year,
count(*),
count(*)/(select count(*) from netflix where country = 'india')* 100 as avg_content_per_year
from netflix
where  country ='India'
group by 1;

#11. List all movies that are documentaries

SELECT *
FROM netflix
WHERE LOWER(listed_in) LIKE '%documentaries%';

#12. Find all content without a director

select * from netflix
where director is null;

#13. Find how many movies actor 'Salman Khan' appeared in last 10 years.

select * from netflix
where cast ilike 'Salman Khan'
and
release_year >extract (year from current date) -10



