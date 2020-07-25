create table tmp.dimension_track_source_join
(
  track_Id int,
  title varchar(100) ,
  length int,
  album_title varchar(100),
  album_releaseDate date,
  album_description text,
  salesInfo_basePrice float ,
  salesInfo_discount smallint,
);
create table tmp.dimension_track_active
(
  seq_id int ,
  track_Id int,
  title varchar(100) ,
  album_title varchar(100),
  album_releaseDate date,
  album_description text,
  length int,
  salesInfo_basePrice float ,
  salesInfo_discount smallint,
  start_date date ,
  end_date date ,
  flag int,
);
create table tmp.dimension_track_final
(
  seq_id int IDENTITY(1,1),
  track_Id int,
  title varchar(100) ,
  album_title varchar(100),
  album_releaseDate date,
  album_description text,
  length int,
  salesInfo_basePrice float ,
  salesInfo_discount smallint,
  start_date date ,
  end_date date ,
  flag int,
);
create table tmp.dimension_album_genre_final
(
  id int,
  name varchar(100),
);
create table tmp.dimension_album_genre_source
(
  id int,
  name varchar(100),
);
create table tmp.dimension_track_artist_final
(
  id int,
  name varchar(100) ,
  birthdate date ,
  description text ,
  country_name varchar(100) ,
  region varchar(100),
  subregion varchar(100),
);
create table tmp.dimension_track_artist_source
(
  id int,
  name varchar(100) ,
  birthdate date ,
  description text ,
  country_name varchar(100) ,
  region varchar(100),
  subregion varchar(100),
);
create table tmp.fact_track_source
(
  id int ,
  customerId int,
  track_Id int ,
  date date ,
  time varchar(20),
  price int,
);
create table tmp.fact_track_source_join
(
  track_seq_id int ,
  purchase_date date ,
  purchase_time varchar(20),
  customer_id int,
  total_price int,
);
create table tmp.fact_track_final
(
  track_seq_id int ,
  purchase_date date ,
  purchase_time varchar(20),
  customer_id int,
  total_price int,
);
create table tmp.fact_track_rating_source
(
  id int,
  customerId int,
  track_Id int,
  rating int,
  description varchar(200),
  date date,
);
create table tmp.fact_track_rating_source_join
(
  seq_id int,
  customerId int,
  rating int,
  date date,
);
create table tmp.fact_track_rating_avg
(
  track_seq_id int ,
  avg_rating float,
  rating_count int,
  last_rate_date date,
);
create table tmp.fact_track_rating_final
(
  track_seq_id int ,
  avg_rating float,
  rating_count int,
  last_rate_date date,
);
create table tmp.fact_track_rating_tmp
(
  track_seq_id int ,
  avg_rating float,
  rating_count int,
  last_rate_date date,
);
create table tmp.fact_album_genre_source
(
  track_Id int,
  genreId int
);
create table tmp.fact_album_genre_join
(
  track_seq_id int,
  track_Id int,
  genre_id int
);
create table tmp.fact_album_genre_final
(
  track_seq_id int,
  genre_id int
);
