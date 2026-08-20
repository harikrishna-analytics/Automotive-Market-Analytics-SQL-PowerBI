
drop table cars_raw

CREATE TABLE cars_data (
    make                 VARCHAR(50),
    model                VARCHAR(100),
    year                 INTEGER,
    engine_fuel_type     VARCHAR(100),
    engine_hp             NUMERIC(10,2),
    engine_cylinders     NUMERIC(5,2),
    transmission_type     VARCHAR(30),
    driven_wheels        VARCHAR(50),
    number_of_doors      NUMERIC(5,2),
    market_category      VARCHAR(200),
    vehicle_size         VARCHAR(30),
    vehicle_style        VARCHAR(50),
    highway_mpg          INTEGER,
    city_mpg             INTEGER,
    popularity            INTEGER,
    msrp                  NUMERIC(12,2)
);

select * from cars_data

---------------------- data quality-----------------


select count(*) from cars_data

SELECT
    COUNT(*) AS total_rows,

    COUNT(*) FILTER (WHERE make IS NULL) AS make_nulls,
    COUNT(*) FILTER (WHERE model IS NULL) AS model_nulls,
    COUNT(*) FILTER (WHERE year IS NULL) AS year_nulls,
    COUNT(*) FILTER (WHERE engine_fuel_type IS NULL) AS engine_fuel_type_nulls,
    COUNT(*) FILTER (WHERE engine_hp IS NULL) AS engine_hp_nulls,
    COUNT(*) FILTER (WHERE engine_cylinders IS NULL) AS engine_cylinders_nulls,
    COUNT(*) FILTER (WHERE transmission_type IS NULL) AS transmission_type_nulls,
    COUNT(*) FILTER (WHERE driven_wheels IS NULL) AS driven_wheels_nulls,
    COUNT(*) FILTER (WHERE number_of_doors IS NULL) AS number_of_doors_nulls,
    COUNT(*) FILTER (WHERE market_category IS NULL) AS market_category_nulls,
    COUNT(*) FILTER (WHERE vehicle_size IS NULL) AS vehicle_size_nulls,
    COUNT(*) FILTER (WHERE vehicle_style IS NULL) AS vehicle_style_nulls,
    COUNT(*) FILTER (WHERE highway_mpg IS NULL) AS highway_mpg_nulls,
    COUNT(*) FILTER (WHERE city_mpg IS NULL) AS city_mpg_nulls,
    COUNT(*) FILTER (WHERE popularity IS NULL) AS popularity_nulls,
    COUNT(*) FILTER (WHERE msrp IS NULL) AS msrp_nulls

FROM cars_data;






SELECT *
FROM cars_data
WHERE engine_hp IS NULL;



select * from cars_data where engine_hp is not null;




SELECT *
FROM cars_data
WHERE engine_hp IS NULL
   OR engine_cylinders IS NULL
   OR number_of_doors IS NULL
   OR market_category IS NULL;


   ======================== Replacing null values with 0 ========================


      CREATE TABLE cars_clean AS
SELECT
    make,
    model,
    COALESCE(year, 0) AS year,
    engine_fuel_type,
    COALESCE(engine_hp, 0) AS engine_hp,
    COALESCE(engine_cylinders, 0) AS engine_cylinders,
    transmission_type,
    driven_wheels,
    COALESCE(number_of_doors, 0) AS number_of_doors,
    market_category,
    vehicle_size,
    vehicle_style,
    COALESCE(highway_mpg, 0) AS highway_mpg,
    COALESCE(city_mpg, 0) AS city_mpg,
    COALESCE(popularity, 0) AS popularity,
    COALESCE(msrp, 0) AS msrp
FROM cars_data;

select * from cars_clean

SELECT
    COUNT(*) FILTER (WHERE year IS NULL) AS year_nulls,
    COUNT(*) FILTER (WHERE engine_hp IS NULL) AS engine_hp_nulls,
    COUNT(*) FILTER (WHERE engine_cylinders IS NULL) AS engine_cylinders_nulls,
    COUNT(*) FILTER (WHERE number_of_doors IS NULL) AS doors_nulls,
    COUNT(*) FILTER (WHERE highway_mpg IS NULL) AS highway_mpg_nulls,
    COUNT(*) FILTER (WHERE city_mpg IS NULL) AS city_mpg_nulls,
    COUNT(*) FILTER (WHERE popularity IS NULL) AS popularity_nulls,
    COUNT(*) FILTER (WHERE msrp IS NULL) AS msrp_nulls
FROM cars_clean;

=============== Renaming table=============

ALTER TABLE cars_clean
RENAME TO car_sales;


select * from car_sales


SELECT
    COUNT(*) FILTER (WHERE year IS NULL) AS year_nulls,
    COUNT(*) FILTER (WHERE engine_hp IS NULL) AS engine_hp_nulls,
    COUNT(*) FILTER (WHERE engine_cylinders IS NULL) AS engine_cylinders_nulls,
    COUNT(*) FILTER (WHERE number_of_doors IS NULL) AS doors_nulls,
    COUNT(*) FILTER (WHERE highway_mpg IS NULL) AS highway_mpg_nulls,
    COUNT(*) FILTER (WHERE city_mpg IS NULL) AS city_mpg_nulls,
    COUNT(*) FILTER (WHERE popularity IS NULL) AS popularity_nulls,
    COUNT(*) FILTER (WHERE msrp IS NULL) AS msrp_nulls
FROM car_sales;
================================ done data preparation==========
========= which manufactor has highest vehicle records ====================

select make,count(*) as vehilcle_records from car_sales group by make order by  count(*) desc 

================= which manufacture has highest avg msrp==================


select make , round(avg(msrp),2) as  avg_msrp from car_sales group by make order by avg_msrp desc

============== how does price vary from vehicle size ============

select vehicle_size, '$' || round(sum(msrp),2)   ||   'RS' as price from
car_sales group by vehicle_size order by price desc

====================== which vehicle style has  strong mpg===========

    select vehicle_size, sum(highway_mpg) MPG from car_sales
	group by vehicle_size order by MPG desc

select vehicle_size, sum(city_mpg) as MPG from car_sales group by
vehicle_size order by MPG desc

================= which transmission type are most common ===========================


     select transmission_type , count(*) as highest from car_sales 
	 group by transmission_type order by count(*) desc

============== which manufacture have highest popularity ===============

    select make, sum(popularity) Popularity from car_sales group by
	make order by Popularity desc
================================which models are most expensive ====================


 select model,  '$' || round(sum(msrp),2) as Price  from car_sales group by model order by Price desc



select model,  '$' || round(sum(msrp),2) as Price  from 
car_sales group by model order by Price desc limit 5


================= How does vehicle mix change by year=========

select year,count(*) from car_sales  group by year  order by year 



================= which vehicle combine high perfomance with lower price ==============

SELECT
    make,
    model,
    engine_hp,
    msrp
FROM car_sales
WHERE engine_hp >= 300
  AND msrp > 0
ORDER BY msrp ASC, engine_hp DESC;


   


WITH manufacturer_sales AS (
    SELECT make, SUM(msrp) AS total_msrp
    FROM car_sales
    GROUP BY make
)
SELECT
    make,
    total_msrp,
    ROUND(100.0 * total_msrp / SUM(total_msrp) OVER (), 2) AS contribution_pct
FROM manufacturer_sales
ORDER BY total_msrp DESC;


CREATE VIEW vw_manufacturer_summary AS
SELECT
    make,
    COUNT(*) AS vehicle_count,
    ROUND(AVG(msrp), 2) AS avg_msrp,
    ROUND(AVG(engine_hp), 2) AS avg_engine_hp,
    ROUND(AVG(city_mpg), 2) AS avg_city_mpg,
    ROUND(AVG(highway_mpg), 2) AS avg_highway_mpg,
    ROUND(AVG(popularity), 2) AS avg_popularity
FROM car_sales
GROUP BY make;

select * from vw_manufacturer_summary


SELECT
    make,
    model,
    engine_hp,
    msrp,
    market_category
FROM car_sales
WHERE market_category LIKE '%High Performance%'
  AND engine_hp IS NOT NULL
  AND msrp > 0
ORDER BY
    msrp ASC,
    engine_hp DESC;
	 
SELECT
    make,
    model,
    engine_hp,
    msrp
FROM car_sales
WHERE engine_hp >= 300
  AND msrp > 0
ORDER BY msrp ASC, engine_hp DESC;

================================================================================================
   WITH manufacturer_stats AS (
    SELECT
        make,
        COUNT(*) AS vehicle_count,
        AVG(msrp) AS avg_msrp
    FROM car_sales
    GROUP BY make
)
SELECT
    make,
    vehicle_count,
    ROUND(avg_msrp, 2) AS avg_msrp,
    RANK() OVER (ORDER BY avg_msrp DESC) AS price_rank
FROM manufacturer_stats
ORDER BY price_rank;

===================== case ==================


     SELECT
    make,
    model,
    msrp,
    CASE
        WHEN msrp < 30000 THEN 'Budget'
        WHEN msrp < 60000 THEN 'Mid Range'
        ELSE 'Premium'
    END AS price_segment
FROM car_sales;



=======================================================================

 ----- Avg Selling price -----------

  select make,  '$' || round(avg(msrp),2) as Avg_selling_price  from car_sales group by make order by Avg_selling_price desc 

----------- Avg MPG-------------------

 select  make,( avg(highway_mpg+city_mpg)/2 ) :: numeric as avg_mpg from car_sales  group by make order by  avg_mpg desc

================ Vehicle age =====

 select make, model, 
 year,
 extract(year from current_date) - year as  car_age from car_sales
               
SELECT
    model, sum(msrp) as price,
    CASE
        WHEN msrp < 30000 THEN 'Budget'
        WHEN msrp < 60000 THEN 'Midrange'
        ELSE 'Premium'
    END AS price_category
FROM car_sales
GROUP BY
    model,
    CASE
        WHEN msrp < 30000 THEN 'Budget'
        WHEN msrp < 60000 THEN 'Midrange'
        ELSE 'Premium'
    END;

============model plus count category ==================


	   SELECT
    model,
    CASE
        WHEN msrp < 30000 THEN 'Budget'
        WHEN msrp < 60000 THEN 'Midrange'
        ELSE 'Premium'
    END AS price_category,
    COUNT(*) AS car_count
FROM car_sales
GROUP BY model, price_category
ORDER BY model;

=================== HP Per 10K ============
SELECT
    make,
    ROUND(SUM(engine_hp / (msrp / 10000))::NUMERIC, 2) AS hp_per_10k
FROM car_sales
GROUP BY make
ORDER BY hp_per_10k DESC;

================== manufacturer avg_price   ===================


            select make , '$' || round( avg(msrp),2) as manufacturer_avg_price from car_sales 
			group by make order by   manufacturer_avg_price desc 


================= Model avg_price ================4

 select model, '$' || round( avg(msrp),2) as model_avg_price from car_sales 
			group by model order by model_avg_price desc 







v