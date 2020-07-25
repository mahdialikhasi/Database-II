Create SCHEMA customer;

-- ************************************** CREATE Customer DIMENSION
-- ************************************** email and country_name is SCD 1
create table customer.dimension_customer
(
  customer_id int ,
  firstName varchar(100) ,
  lastName varchar(100) ,
  gender varchar(20) ,
  email varchar(100) ,
  phone varchar(100) ,
  dateJoined date ,
  country_name varchar(100)
  ,
);

-- ************************************** CREATE Customer purchase Accumulative fact table
create table customer.fact_acc_customer
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

create table customer.fact_customer
(
  customer_id int,
  type int,
  book_seq_id int,
  movie_seq_id int,
  song_seq_id int,
  episod_seq_id int,
  purchase_date date ,
  purchase_time varchar(20),
  total_price int,
);