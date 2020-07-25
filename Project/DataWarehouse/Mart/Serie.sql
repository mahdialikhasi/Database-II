Create SCHEMA serie;

-- ************************************** CREATE SONG DIMENSION
-- ************************************** Hierarchy : Country and Company
-- ************************************** SCD 1 : ProductionCompany_name
-- ************************************** SCD 2 : salesInfo_basePrice, salesInfo_discount
-- ************************************** SCD 3 : release date
-- ************************************** We have SCD 2 so Flag and start_date and end_date and seq_id is necessary
create table serie.dimension_episode(
  seqId                     int ,
  serieId                   int,
  series_title              varchar(100) ,
  releaseDate               date ,
  episodeId                 int ,
  title                     varchar(100) ,
 	productionCompany_name 		varchar(100) ,
	productionCompany_description 	text,
	productionCompany_website	varchar(100),
	productionCompany_phone		varchar(100),
	productionCompany_city 		varchar(100),
 	productionCompany_street  varchar(100),
 	productionCompany_country_name  varchar(100),
  productionCompany_country_region  varchar(100),
  productionCompany_country_subregion  varchar(100),
  salesInfo_basePrice       float ,
  salesInfo_discount        smallint,
  start_date                 date ,
  end_date                   date ,
  flag              int  ,
);

-- ************************************** CREATE Genre DIMENSION
create table serie.dimension_genre(
  id                        int,
  name                      varchar(100),
);

create table serie.dimension_director(
  id                        int,
  name                      varchar(100) ,
  birthdate                 date ,
  description               text ,
  country_name              varchar(100)  ,
);

-- ************************************** country name is SCD 1
create table serie.dimension_actor(
  id                        int,
  name                      varchar(100) ,
  birthdate                 date ,
  description               text ,
  country_name              varchar(100),
);

----------facts-----------------------------------------------------------------------------------------------------

-- ************************************** CREATE series Transactional Fact
create table serie.fact_serie(
  episode_seq_id            int ,
  purchase_date             date ,
  purchase_time             varchar(20),
  customer_id               int,
  total_price               int,
);


-- ************************************** CREATE series Genre Factless fact table
create table serie.fact_genre(
  serie_seq_id            int ,
  genre_id                  int  ,
);


-- ************************************** CREATE series Director Factless fact table
create table serie.fact_director(
  episode_seq_id          int ,
  director_id             int  ,
);

-- ************************************** CREATE series Actor Factless fact table
create table serie.fact_actor(
  episode_seq_id          int ,
  actor_id                int  ,
);

-- ************************************** CREATE Song Rating Accumulative fact table
create table serie.fact_rating(
  serie_seq_id          int ,
  avg_rating            float,
  rating_count          int,
  last_rate_date        date,
);

-- ************************************** CREATE Song Selling Accumulative fact table
create table serie.fact_selling(
  episode_seq_id        int ,
  total_price           int,
);

----------------------------------------------------------------------------------------------------------


