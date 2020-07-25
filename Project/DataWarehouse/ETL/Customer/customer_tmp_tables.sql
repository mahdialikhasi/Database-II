create table tmp.dimension_customer_source_join
(
  customer_id int,
  firstName varchar(100) ,
  lastName varchar(100),
  gender varchar(20),
  email varchar(100),
  phone varchar(100),
  dateJoined date ,
  country_name varchar(100),
  country_region varchar(100),
  country_subregion varchar(100)
);

create table tmp.dimension_customer_final
(
  seq_id int IDENTITY(1,1),
  customer_id int,
  firstName varchar(100) ,
  lastName varchar(100),
  gender varchar(20),
  email varchar(100),
  phone varchar(100),
  dateJoined date ,
  country_name varchar(100),
  country_region varchar(100),
  country_subregion varchar(100)
);

create table tmp.fact_acc_customer_final
(
  customer_id int,
  purchase_total_price int,
  purchase_total_count int,
  last_purchase_total_price int,
  last_purchase_date date,
  last_purchase_time time,
  max_purchase_total_price int,
  max_purchase_date date,
  max_purchase_time varchar(50),
  days_without_purchase int
);
create table tmp.fact_customer_final(
  customer_id       int,
  type          int,
  book_seq_id       int,
  movie_seq_id      int,
  song_seq_id       int,
  episode_seq_id     int,
  purchase_date     date ,
  purchase_time     varchar(20),
  total_price       int,
);