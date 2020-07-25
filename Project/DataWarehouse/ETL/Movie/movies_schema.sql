CREATE OR ALTER PROCEDURE "dimension_movie_update"
as
begin
  declare @dimCount int;
  declare @tempCount int;

  set @dimCount = (select count(*)
  from movie.dimension_movie);
  set @tempCount = (select count(*)
  from tmp.dimension_movie_final);

  if (@dimCount = 0 and @tempCount > 0)
        return 0;

  truncate table tmp.dimension_movie_source_join;
  truncate table tmp.dimension_movie_active;
  truncate table tmp.dimension_movie_final;

  SET IDENTITY_INSERT tmp.dimension_movie_final ON;

  insert into tmp.dimension_movie_source_join
    select
      b.id as movie_id, b.title, b.releaseDate, b.description,
      p.name as productionCompany_name, p.description as productionCompany_description, p.website as productionCompany_website,
        p.phone as productionCompany_phone, p.city as productionCompany_city, p.street as productionCompany_street,
      c.name as productionCompany_country_name, c.region as productionCompany_country_region, c.subregion as productionCompany_country_subregion,
      s.basePrice as salesInfo_basePrice, s.discount as salesInfo_discount

    from [db2_source].Movies.Movies as b
      inner join [db2_source].Movies.ProductionCompanies as p on b.productionCompanyId = p.id
      inner join [db2_source].dbo.SalesInfo as s on b.salesInfoId = s.id
      inner join [db2_source].dbo.Countries c on c.id = p.countryId

  insert into tmp.dimension_movie_active
  select
    seq_id, movie_id, title, releaseDate, description,
    productionCompany_name, productionCompany_description, productionCompany_website,
      productionCompany_phone, productionCompany_city, productionCompany_street,
    productionCompany_country_name, productionCompany_country_region, productionCompany_country_subregion,
    salesInfo_basePrice, salesInfo_discount,
    start_date, end_date, flag
  from movie.dimension_movie
  where flag = 1;

  insert into tmp.dimension_movie_final
    (seq_id, movie_id, title, releaseDate, description,
    productionCompany_name, productionCompany_description, productionCompany_website,
      productionCompany_phone, productionCompany_city, productionCompany_street,
    productionCompany_country_name, productionCompany_country_region, productionCompany_country_subregion,
    salesInfo_basePrice, salesInfo_discount,
    start_date, end_date, flag)
  select
    seq_id, movie_id, title, releaseDate, description,
    productionCompany_name, productionCompany_description, productionCompany_website,
      productionCompany_phone, productionCompany_city, productionCompany_street,
    productionCompany_country_name, productionCompany_country_region, productionCompany_country_subregion,
    salesInfo_basePrice, salesInfo_discount,
    start_date, end_date, flag
  from movie.dimension_movie
  where flag = 0;

  insert into tmp.dimension_movie_final
    (seq_id, movie_id, title, releaseDate, description,
    productionCompany_name, productionCompany_description, productionCompany_website,
      productionCompany_phone, productionCompany_city, productionCompany_street,
    productionCompany_country_name, productionCompany_country_region, productionCompany_country_subregion,
    salesInfo_basePrice, salesInfo_discount,
    start_date, end_date, flag)
  select
    o.seq_id, o.movie_id, o.title, o.releaseDate, o.description,
    isnull(n.productionCompany_name, o.productionCompany_name), o.productionCompany_description, o.productionCompany_website,
      o.productionCompany_phone, o.productionCompany_city, o.productionCompany_street,
    o.productionCompany_country_name, o.productionCompany_country_region, o.productionCompany_country_subregion,
    o.salesInfo_basePrice, o.salesInfo_discount,
    o.start_date, o.end_date, o.flag
  from tmp.dimension_movie_source_join as n
    full outer join tmp.dimension_movie_active as o on o.movie_id = n.movie_id
  where (o.movie_id is not null and n.movie_id is null)
    or (o.salesInfo_basePrice = n.salesInfo_basePrice and o.salesInfo_discount = n.salesInfo_discount)

  insert into tmp.dimension_movie_final
    (seq_id, movie_id, title, releaseDate, description,
    productionCompany_name, productionCompany_description, productionCompany_website,
      productionCompany_phone, productionCompany_city, productionCompany_street,
    productionCompany_country_name, productionCompany_country_region, productionCompany_country_subregion,
    salesInfo_basePrice, salesInfo_discount,
    start_date, end_date, flag)
  select
    o.seq_id, o.movie_id, o.title, o.releaseDate, o.description,
    o.productionCompany_name, o.productionCompany_description, o.productionCompany_website,
      o.productionCompany_phone, o.productionCompany_city, o.productionCompany_street,
    o.productionCompany_country_name, o.productionCompany_country_region, o.productionCompany_country_subregion,
    o.salesInfo_basePrice, o.salesInfo_discount,
    o.start_date, getdate(), 0
  from tmp.dimension_movie_source_join as n
    inner join tmp.dimension_movie_active as o on o.movie_id = n.movie_id
  where (o.salesInfo_basePrice != n.salesInfo_basePrice or o.salesInfo_discount != n.salesInfo_discount)


  SET IDENTITY_INSERT tmp.dimension_movie_final OFF;
  insert into tmp.dimension_movie_final
  select
    n.movie_id, n.title, n.releaseDate, n.description,
    n.productionCompany_name, n.productionCompany_description, n.productionCompany_website,
      n.productionCompany_phone, n.productionCompany_city, n.productionCompany_street,
    n.productionCompany_country_name, n.productionCompany_country_region, n.productionCompany_country_subregion,
    n.salesInfo_basePrice, n.salesInfo_discount,
    getdate(), null, 1
  from tmp.dimension_movie_source_join as n
    full outer join tmp.dimension_movie_active as o on o.movie_id = n.movie_id
  where (n.movie_id is not null and o.movie_id is null)
    or (o.salesInfo_basePrice != n.salesInfo_basePrice or o.salesInfo_discount != n.salesInfo_discount)


  truncate table movie.dimension_movie;

  insert into movie.dimension_movie
  select
    seq_id, movie_id, title, releaseDate, description,
    productionCompany_name, productionCompany_description, productionCompany_website,
      productionCompany_phone, productionCompany_city, productionCompany_street,
    productionCompany_country_name, productionCompany_country_region, productionCompany_country_subregion,
    salesInfo_basePrice, salesInfo_discount,
    start_date, end_date, flag
  from tmp.dimension_movie_final;
end

CREATE OR ALTER PROCEDURE "dimension_movie_genre_update"
as
begin
  declare @dimCount int;
  declare @tempCount int;

  set @dimCount = (select count(*)
  from movie.dimension_genre);
  set @tempCount = (select count(*)
  from tmp.dimension_movie_genre_final);

  if (@dimCount = 0 and @tempCount > 0)
        return 0;

  truncate table tmp.dimension_movie_genre_source;
  truncate table tmp.dimension_movie_genre_final;

  insert into tmp.dimension_movie_genre_source
  select
    id, name
  from [db2_source].Movies.Genres

  insert into tmp.dimension_movie_genre_final
  select
    isnull(o.id, n.id), isnull(o.name, n.name)
  from tmp.dimension_movie_genre_source as n
    full outer join movie.dimension_genre as o on o.id = n.id

  truncate table movie.dimension_genre;

  insert into movie.dimension_genre
  select
    id, name
  from tmp.dimension_movie_genre_final;
end

CREATE OR ALTER PROCEDURE "dimension_movie_director_update"
as
begin
  declare @dimCount int;
  declare @tempCount int;

  set @dimCount = (select count(*)
  from movie.dimension_director);
  set @tempCount = (select count(*)
  from tmp.dimension_movie_director_final);

  if (@dimCount = 0 and @tempCount > 0)
        return 0;

  truncate table tmp.dimension_movie_director_source;
  truncate table tmp.dimension_movie_director_final;

  insert into tmp.dimension_movie_director_source
  select
    a.id, a.name, birthdate, description, c.name as country_name
  from [db2_source].Movies.Directors a
    inner join [db2_source].dbo.Countries c on c.id = a.countryId

  insert into tmp.dimension_movie_director_final
  select
    isnull(o.id, n.id), isnull(o.name, n.name), isnull(o.birthdate, n.birthdate),
    isnull(o.description, n.description), isnull(o.country_name, n.country_name)
  from tmp.dimension_movie_director_source as n
    full outer join movie.dimension_director as o on o.id = n.id

  truncate table movie.dimension_director;

  insert into movie.dimension_director
  select
    id, name, birthdate, description, country_name
  from tmp.dimension_movie_director_final;
end

CREATE OR ALTER PROCEDURE "fact_movie_transactional_update"
as
begin
  declare @factCount int;
  declare @tempCount int;
  declare @currdate date;

  set @factCount = (select count(*)
  from movie.fact_movie);
  set @tempCount = (select count(*)
  from tmp.fact_movie_final);

  if (@factCount = 0 and @tempCount > 0)
        return 0;

  if(@factCount = 0)
		set @currdate = CAST('2010-01-01' as date);
	else
		set @currdate = (select CAST(max(f.purchase_date) as date)
  from movie.fact_movie as f)

  truncate table tmp.fact_movie_source;
  truncate table tmp.fact_movie_source_join;
  truncate table tmp.fact_movie_final;


  while @currdate <= CAST(GETDATE() as date) begin
  	truncate table tmp.fact_movie_source;
  	truncate table tmp.fact_movie_source_join;
    insert into tmp.fact_movie_source
    select t.id, t.customerId, t.movieId, t.date, t.time, t.price
    from [db2_source].Movies.Transactions as t
    where t.date = DATEADD(day, 1, @currdate)

    insert into tmp.fact_movie_source_join
    select b.seq_id, t.date, t.time, t.customerId, t.price
    from tmp.fact_movie_source as t
      inner join movie.dimension_movie as b on b.movie_id = t.movieId
    where b.flag = 1

    insert into tmp.fact_movie_final
    select movie_seq_id, purchase_date, purchase_time, customer_id, total_price
    from tmp.fact_movie_source_join

    set @currdate = DATEADD(day, 1, @currdate);
  end

  truncate table movie.fact_movie;

  insert into movie.fact_movie
  select
    movie_seq_id, purchase_date, purchase_time, customer_id, total_price
  from tmp.fact_movie_final;
end

CREATE OR ALTER PROCEDURE "fact_movie_rating_update"
as
begin
  declare @factCount int;
  declare @tempCount int;
  declare @currdate date;

  set @factCount = (select count(*)
  from movie.fact_rating);
  set @tempCount = (select count(*)
  from tmp.fact_movie_rating_tmp);

  if (@factCount = 0 and @tempCount > 0)
        return 0;

  if(@factCount = 0)
        set @currdate = CAST('2010-01-01' as date);
    else
        set @currdate = (select CAST(max(f.purchase_date) as date)
  from movie.fact_movie as f)

  truncate table tmp.fact_movie_rating_tmp;
  truncate table tmp.fact_movie_rating_source;
  truncate table tmp.fact_movie_rating_source_join;
  truncate table tmp.fact_movie_rating_avg;
  truncate table tmp.fact_movie_rating_final;


  insert into tmp.fact_movie_rating_tmp
  select movie_seq_id, avg_rating, rating_count, last_rate_date
  from movie.fact_rating
  while @currdate <= CAST(GETDATE() as date) begin
  	truncate table tmp.fact_movie_rating_source;
  	truncate table tmp.fact_movie_rating_source_join;
  	truncate table tmp.fact_movie_rating_avg;
  	truncate table tmp.fact_movie_rating_final;
    
    insert into tmp.fact_movie_rating_source
    select r.id, r.customerId, r.movieId, r.rating, r.description, r.date
    from [db2_source].Movies.Ratings as r
    where r.date = DATEADD(day, 1, @currdate)

    insert into tmp.fact_movie_rating_source_join
    select b.seq_id, r.customerId, r.rating, r.date
    from tmp.fact_movie_rating_source as r
      inner join movie.dimension_movie as b on b.movie_id = r.movieId
    where b.flag = 1

    insert into tmp.fact_movie_rating_avg
    select r.seq_id, avg(r.rating), count(*), max(r.date)
    from tmp.fact_movie_rating_source_join as r
    group by r.seq_id

    insert into tmp.fact_movie_rating_final
    select isnull(r.movie_seq_id, f.movie_seq_id),
      (isnull(r.avg_rating, 0) * isnull(r.rating_count, 0) + isnull(f.avg_rating, 0) * isnull(f.rating_count, 0)) / (isnull(r.rating_count, 0) + isnull(f.rating_count, 0)),
      isnull(r.rating_count, 0) + isnull(f.rating_count, 0),
      isnull(r.last_rate_date, f.last_rate_date)
    from tmp.fact_movie_rating_avg as r
      full outer join tmp.fact_movie_rating_tmp as f on f.movie_seq_id = r.movie_seq_id

    truncate table tmp.fact_movie_rating_tmp;

    insert into tmp.fact_movie_rating_tmp
    select movie_seq_id, avg_rating, rating_count, last_rate_date
    from tmp.fact_movie_rating_final

    truncate table tmp.fact_movie_rating_final;


    set @currdate = DATEADD(day, 1, @currdate);
  end

  truncate table movie.fact_rating;

  insert into movie.fact_rating
  select
    movie_seq_id, avg_rating, rating_count, last_rate_date
  from tmp.fact_movie_rating_tmp;
end

CREATE OR ALTER PROCEDURE "fact_movie_genre_update"
as
begin
  declare @factCount int;
  declare @tempCount int;

  set @factCount = (select count(*)
  from movie.fact_genre);
  set @tempCount = (select count(*)
  from tmp.fact_movie_genre_final);

  if (@factCount = 0 and @tempCount > 0)
        return 0;


  truncate table tmp.fact_movie_genre_source;
  truncate table tmp.fact_movie_genre_join;
  truncate table tmp.fact_movie_genre_final;

  
    insert into tmp.fact_movie_genre_source
    select movieId, genreId
    from [db2_source].Movies.MoviesGenres as g

    insert into tmp.fact_movie_genre_join
    select b.seq_id, g.movieId, g.genreId
    from tmp.fact_movie_genre_source as g
      inner join movie.dimension_movie as b on b.movie_id = g.movieId
    where b.flag = 1

    insert into tmp.fact_movie_genre_final
    select isnull(o.movie_seq_id, g.movie_seq_id), isnull(o.genre_id, g.genre_id)
    from tmp.fact_movie_genre_join as g
      full outer join movie.fact_genre as o on o.movie_seq_id = g.movie_seq_id

    

  truncate table movie.fact_genre;

  insert into movie.fact_genre
  select movie_seq_id, genre_id
  from tmp.fact_movie_genre_final;
end