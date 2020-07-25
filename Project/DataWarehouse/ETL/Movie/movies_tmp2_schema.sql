create table movie.fact_movie_daily_update(
  movie_seq_id int,
  purchase_date date,
  total_price_sum int,
  total_count int
);

create table tmp.fact_movie_daily_final
(
  movie_seq_id int,
  purchase_date date,
  total_price_sum int,
  total_count int
);
create table tmp.fact_movie_daily_source
(
  movie_seq_id int,
  purchase_date date,
  total_price int,
  total_count int
);



create or alter procedure "fact_movie_daily_update" as begin
  declare @factCount int;
  declare @tempCount int;
  declare @currdate date;

  set @factCount = (select count(*)
  from movie.fact_movie_daily_update);
  set @tempCount = (select count(*)
  from tmp.fact_movie_daily_final);

  if (@factCount = 0 and @tempCount > 0)
    return 0;

  if(@factCount = 0)
    set @currdate = CAST('2010-01-01' as date);
  else
    set @currdate = (select CAST(max(f.purchase_date) as date)
  from movie.fact_movie_daily_update as f)

  truncate table tmp.fact_movie_daily_final;

  while @currdate <= CAST(GETDATE() as date) begin
    insert into tmp.fact_movie_daily_source
      select m.movie_seq_id, m.purchase_date, total_price, 1
      from movie.fact_movie as m
      where m.purchase_date = DATEADD(day, 1, @currdate)

    insert into tmp.fact_movie_daily_final
      select m.movie_seq_id, max(m.purchase_date), sum(total_price) as total_price_sum, count(*) as total_count
      from tmp.fact_movie_daily_source as m
      group by m.movie_seq_id

    set @currdate = DATEADD(day, 1, @currdate);
  end

  insert into movie.fact_movie_daily_update
    select movie_seq_id, purchase_date, total_price_sum, total_count
    from tmp.fact_movie_daily_final
end