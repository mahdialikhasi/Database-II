Create SCHEMA movie;

-- ************************************** CREATE MOVIE DIMENSION
-- ************************************** Hierarchy : Country and Company
-- ************************************** SCD 1 : ProductionCompany_name
-- ************************************** SCD 2 : salesInfo_basePrice, salesInfo_discount
-- ************************************** SCD 3 : release date
-- ************************************** We have SCD 2 so Flag and start_date and end_date and seq_id is necessary
create table movie.dimension_movie(
	seq_id							int ,
	movie_id    					int ,
 	title							varchar(100) ,
 	releaseDate1		    		date ,
 	releaseDate2		    		date ,
 	releaseDate3		    		date ,
 	description     				text ,
 	productionCompany_name 			varchar(100) ,
	productionCompany_description 	text,
	productionCompany_website		varchar(100),
	productionCompany_phone			varchar(100),
	productionCompany_city 			varchar(100),
 	productionCompany_street      	varchar(100),
 	productionCompany_country_name  varchar(100),
	productionCompany_country_region  varchar(100),
	productionCompany_country_subregion  varchar(100),
	salesInfo_basePrice    		    float ,
	salesInfo_discount				smallint,
	start_date 						date ,
	end_date						date ,
	flag							int ,
);

-- ************************************** CREATE Genre DIMENSION
create table movie.dimension_genre(
	id 						int,
	name 					varchar(100),
);

-- ************************************** CREATE Author DIMENSION
-- ************************************** country name is SCD 1
create table movie.dimension_director(
	id 						int,
	name        			varchar(100) ,
 	birthdate   			date ,
 	description 			text ,
 	country_name 			varchar(100) ,
);

-- ************************************** country name is SCD 1
create table movie.dimension_actor(
	id 						int,
	name        			varchar(100) ,
 	birthdate   			date ,
 	description 			text ,
 	country_name 			varchar(100) ,
);

----------facts-----------------------------------------------------------------------------------------------------

-- ************************************** CREATE movie Transactional Fact
create table movie.fact_movie(
	movie_seq_id			int ,
	purchase_date			date ,
	purchase_time			varchar(20),
	customer_id				int,
	total_price				int,
);


-- ************************************** CREATE movie Genre Factless fact table
create table movie.fact_genre(
	movie_seq_id			int ,
	genre_id				int ,
);

-- ************************************** CREATE movie Director Factless fact table
create table movie.fact_director(
	movie_seq_id			int ,
	director_id				int ,
);

-- ************************************** CREATE movie Actor Factless fact table
create table movie.fact_actor(
	movie_seq_id			int ,
	actor_id				int ,
);

-- ************************************** CREATE movie Rating Accumulative fact table
create table movie.fact_rating(
	movie_seq_id			int ,
	avg_rating				float,
	rating_count			int,
	last_rate_date			date,
);

-- ************************************** CREATE movie Rating Accumulative fact table
create table movie.fact_selling(
	movie_seq_id			int ,
	total_price				int,
);

----------------------------------------------------------------------------------------------------------


