Create SCHEMA book;
-- ************************************** CREATE BOOK DIMENSION
-- ************************************** SALESINFO IS SCD 2 so Flag and start_date and end_date and seq_id is necessary
-- ************************************** Hierarchy :: Publication, Country
-- ************************************** Publisher name is SCD 1

create table book.dimension_book(
	seq_id					int,
	book_id    				int ,
 	isbn 					varchar(100) ,
 	title					varchar(100) ,
 	publicationDate		 	date ,
 	edition					int ,
 	description     		text ,
 	publisher_name 			varchar(100) ,
	publisher_description 	text,
	publisher_website		varchar(100),
	publisher_phone			varchar(100),
	publisher_city    		varchar(100),
 	publisher_street      	varchar(100),
 	publisher_country_name  varchar(100),
 	region					varchar(100),
 	subregion				varchar(100),
	salesInfo_basePrice     float ,
	salesInfo_discount		smallint,
	start_date 				date ,
	end_date				date ,
	flag					int ,
);

-- ************************************** In dimension ha ro az ostad migirim
create table dimension_date();

create table dimension_time();

Create SCHEMA customer;

-- ************************************** CREATE Customer DIMENSION
-- ************************************** email and country_name is SCD 1
create table customer.dimension_customer(
	customer_id				int ,
 	firstName  				varchar(100) ,
 	lastName				varchar(100) ,
 	gender					varchar(20) ,
 	email					varchar(100) ,
 	phone 					varchar(100) ,
 	dateJoined				date ,
 	country_name  			varchar(100) ,
 	region  				varchar(100) ,
 	subregion	  			varchar(100) ,
);

-- ************************************** CREATE Book Transactional Fact
create table book.fact_book(
	book_seq_id				int ,
	purchase_date			date ,
	purchase_time			varchar(20),
	customer_id				int,
	total_price				int,
);

-- ************************************** CREATE Genre DIMENSION
create table book.dimension_genre(
	id 						int,
	name 					varchar(100),
);

-- ************************************** CREATE Book Genre Factless fact table
create table book.fact_genre(
	book_seq_id				int ,
	genre_id				int ,
);


-- ************************************** CREATE Author DIMENSION
-- ************************************** country name is SCD 1
create table book.dimension_author(
	id 						int,
	name        			varchar(100) ,
 	birthdate   			date ,
 	description 			text ,
 	country_name 			varchar(100) ,
 	region					varchar(100),
 	subregion				varchar(100),
);

-- ************************************** CREATE Book Author Factless fact table
create table book.fact_author(
	book_seq_id				int ,
	author_id				int ,
);

-- ************************************** CREATE Book Rating Accumulative fact table
create table book.fact_rating(
	book_seq_id				int ,
	avg_rating				float,
	rating_count			int,
	last_rate_date			date,
);

-- ************************************** CREATE Customer purchase Accumulative fact table
create table customer.fact_acc_customer(
	customer_id				int,
	purchase_total 			int,
	purchase_total_count		int,
	last_purchase_total_price	int,	
	last_purchase			date,
	last_purchase_time		varchar(20),
	max_purchase_total_price	int,
	max_purchase_date		date,
	max_purchase_time		varchar(20),
	days_without_purchase	int,
);

-- ************************************** CREATE Customer purchase transactional fact table
create table type(
	type_id					int,
	type_description		varchar(100),
);

create table customer.fact_customer(
	customer_id				int,
	type 					int,
	book_seq_id				int,
	movie_seq_id			int,
	song_seq_id				int,
	episode_seq_id			int,
	purchase_date			date ,
	purchase_time			varchar(20),
	total_price 			int,
);
