Create SCHEMA song;

-- ************************************** CREATE SONG DIMENSION
-- ************************************** Hierarchy : Country and Company
-- ************************************** SCD 1 : ProductionCompany_name
-- ************************************** SCD 2 : salesInfo_basePrice, salesInfo_discount
-- ************************************** SCD 3 : release date
-- ************************************** We have SCD 2 so Flag and start_date and end_date and seq_id is necessary
create table song.dimension_track(
	seq_id 					int ,
	track_id 				int ,
	title 					varchar(100) ,
	album_title 			varchar(100) ,
	album_releaseDate 		date ,
	album_description 		text,
	length 					int ,
	salesInfo_basePrice 	float ,
	salesInfo_discount 		smallint,
	start_date 				date ,
	end_date 				date ,
	flag 			int,
);


-- ************************************** CREATE Genre DIMENSION
create table song.dimension_genre(
	id 						int,
	name 					varchar(100),
);

-- ************************************** CREATE Author DIMENSION
-- ************************************** country name is SCD 1
create table song.dimension_artist(
	id 						int,
	name 					varchar(100) ,
	birthdate 				date ,
	description 			text ,
	country_name 			varchar(100),
	region		 			varchar(100),
	subregion	 			varchar(100),
);



----------facts-----------------------------------------------------------------------------------------------------

-- ************************************** CREATE movie Transactional Fact
create table song.fact_song(
	song_seq_id 			int ,
	purchase_date 			date ,
	purchase_time 			varchar(20),
	customer_id 			int,
	total_price 			int,
);


-- ************************************** CREATE movie Genre Factless fact table
create table song.fact_genre(
	seq_id 					int ,
	genre_id 				int	,
);

-- ************************************** CREATE movie Director Factless fact table
create table song.fact_artist(
	movie_seq_id 			int ,
	director_id 			int	,
);

-- ************************************** CREATE Song Rating Accumulative fact table
create table song.fact_rating(
	song_seq_id 			int ,
	avg_rating 				float,
	rating_count 			int,
	last_rate_date			date,
);

-- ************************************** CREATE Song Selling Accumulative fact table
create table song.fact_selling(
	song_seq_id 			int ,
	total_price 			int,
);

----------------------------------------------------------------------------------------------------------


