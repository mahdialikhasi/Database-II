create table tmp.dimension_serie_source_join
(
  serie_id int,
  title varchar(100),
  releaseDate date,
  --releaseDate2 date,
  --releaseDate3 date,
  episodeId int,
  series_title varchar(100),
  productionCompany_name varchar(100),
  productionCompany_description text,
  productionCompany_website varchar(100),
  productionCompany_phone varchar(100),
  productionCompany_city varchar(100),
  productionCompany_street varchar(100),
  productionCompany_country_name varchar(100),
  productionCompany_country_region varchar(100),
  productionCompany_country_subregion varchar(100),
  salesInfo_basePrice float,
  salesInfo_discount smallint
);
create table tmp.dimension_serie_active
(
  seq_id int,
  serie_id int,
  title varchar(100),
  releaseDate date,
  --releaseDate2 date,
  --releaseDate3 date,
  episodeId int,
  series_title varchar(100),
  productionCompany_name varchar(100),
  productionCompany_description text,
  productionCompany_website varchar(100),
  productionCompany_phone varchar(100),
  productionCompany_city varchar(100),
  productionCompany_street varchar(100),
  productionCompany_country_name varchar(100),
  productionCompany_country_region varchar(100),
  productionCompany_country_subregion varchar(100),
  salesInfo_basePrice float,
  salesInfo_discount smallint,
  start_date date,
  end_date date,
  flag int,
);
create table tmp.dimension_serie_final
(
  seq_id int IDENTITY(1,1),
  serie_id int,
  title varchar(100),
  releaseDate date,
  --releaseDate2 date,
  --releaseDate3 date,
  episodeId int,
  series_title varchar(100),
  productionCompany_name varchar(100),
  productionCompany_description text,
  productionCompany_website varchar(100),
  productionCompany_phone varchar(100),
  productionCompany_city varchar(100),
  productionCompany_street varchar(100),
  productionCompany_country_name varchar(100),
  productionCompany_country_region varchar(100),
  productionCompany_country_subregion varchar(100),
  salesInfo_basePrice float,
  salesInfo_discount smallint,
  start_date date,
  end_date date,
  flag int,
);
create table tmp.dimension_serie_genre_final
(
  id int,
  name varchar(100),
);
create table tmp.dimension_serie_genre_source
(
  id int,
  name varchar(100),
);
create table tmp.dimension_serie_director_final
(
  id int,
  name varchar(100),
  birthdate date,
  description text,
  country_name varchar(100),
);
create table tmp.dimension_serie_director_source
(
  id int,
  name varchar(100),
  birthdate date,
  description text,
  country_name varchar(100)
  ,
);
create table tmp.fact_serie_source
(
  id int,
  customerId int,
  serieId int,
  date date,
  time varchar(20),
  price int,
);
create table tmp.fact_serie_source_join
(
  serie_seq_id int,
  purchase_date date,
  purchase_time varchar(20),
  customer_id int,
  total_price int,
);
create table tmp.fact_serie_final
(
  serie_seq_id int,
  purchase_date date,
  purchase_time varchar(20),
  customer_id int,
  total_price int,
);
create table tmp.fact_serie_rating_source
(
  id int,
  customerId int,
  serieId int,
  rating int,
  description varchar(200),
  date date,
);
create table tmp.fact_serie_rating_source_join
(
  seq_id int,
  customerId int,
  rating int,
  date date,
);
create table tmp.fact_serie_rating_avg
(
  serie_seq_id int,
  avg_rating float,
  rating_count int,
  last_rate_date date,
);
create table tmp.fact_serie_rating_final
(
  serie_seq_id int,
  avg_rating float,
  rating_count int,
  last_rate_date date,
);
create table tmp.fact_serie_rating_tmp
(
  serie_seq_id int,
  avg_rating float,
  rating_count int,
  last_rate_date date,
);
create table tmp.fact_serie_genre_source
(
  serieId int,
  genreId int
);
create table tmp.fact_serie_genre_join
(
  serie_seq_id int,
  serieId int,
  genre_id int
);
create table tmp.fact_serie_genre_final
(
  serie_seq_id int,
  genre_id int
);