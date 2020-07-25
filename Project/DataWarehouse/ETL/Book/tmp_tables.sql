Create SCHEMA tmp;
create table tmp.dimension_book_source_join(
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
);
create table tmp.dimension_book_active(
	seq_id					int ,
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
create table tmp.dimension_book_final(
	seq_id					int IDENTITY(1,1),
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
create table tmp.dimension_book_genre_final(
	id 						int,
	name 					varchar(100),
);
create table tmp.dimension_book_genre_source(
	id 						int,
	name 					varchar(100),
);
create table tmp.dimension_book_author_final(
	id 						int,
	name        			varchar(100) ,
 	birthdate   			date ,
 	description 			text ,
 	country_name 			varchar(100) ,
 	region					varchar(100),
 	subregion				varchar(100),
);
create table tmp.dimension_book_author_source(
	id 						int,
	name        			varchar(100) ,
 	birthdate   			date ,
 	description 			text ,
 	country_name 			varchar(100) ,
 	region					varchar(100),
 	subregion				varchar(100),
);
create table tmp.dimension_customer_source_join(
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
create table tmp.dimension_customer_final(
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
create table tmp.fact_book_source(
	id 						int ,
	customerId				int,
	bookId 					int ,
	date 					date ,
	time 					varchar(20),
	price 					int,
);
create table tmp.fact_book_source_join(
	book_seq_id				int ,
	purchase_date			date ,
	purchase_time			varchar(20),
	customer_id				int,
	total_price				int,
);
create table tmp.fact_book_final(
	book_seq_id				int ,
	purchase_date			date ,
	purchase_time			varchar(20),
	customer_id				int,
	total_price				int,
);
create table tmp.fact_book_rating_source(
	id 						int,
	customerId 				int,
	bookId 					int,
	rating 					int,
	description 			varchar(200),
	date 					date,
);
create table tmp.fact_book_rating_source_join(
	seq_id 					int,
	customerId 				int,
	rating 					int,
	date 					date,
);
create table tmp.fact_book_rating_avg(
	book_seq_id				int ,
	avg_rating				float,
	rating_count			int,
	last_rate_date			date,
);
create table tmp.fact_book_rating_final(
	book_seq_id				int ,
	avg_rating				float,
	rating_count			int,
	last_rate_date			date,
);
create table tmp.fact_book_rating_tmp(
	book_seq_id				int ,
	avg_rating				float,
	rating_count			int,
	last_rate_date			date,
);
create table tmp.fact_book_genre_source(
	bookId 					int,
	genreId 				int
);
create table tmp.fact_book_genre_join(
	book_seq_id				int,
	bookId 					int,
	genre_id 				int
);
create table tmp.fact_book_author_final(
	book_seq_id				int,
	author_id 				int
);
create table tmp.fact_book_author_source(
	bookId 					int,
	authorId 				int
);
create table tmp.fact_book_author_join(
	book_seq_id				int,
	bookId 					int,
	author_id 				int
);
create table tmp.fact_book_author_final(
	book_seq_id				int,
	author_id 				int
);
