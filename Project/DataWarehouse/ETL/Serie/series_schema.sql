CREATE OR ALTER PROCEDURE "dimension_episode_update"
as
begin
  declare @dimCount int;
  declare @tempCount int;

  set @dimCount = (select count(*)
  from serie.dimension_episode);
  set @tempCount = (select count(*)
  from tmp.dimension_serie_final);

  if (@dimCount = 0 and @tempCount > 0)
        return 0;

  truncate table tmp.dimension_serie_source_join;
  truncate table tmp.dimension_serie_active;
  truncate table tmp.dimension_serie_final;

  SET IDENTITY_INSERT tmp.dimension_serie_final ON;

  insert into tmp.dimension_serie_source_join
  select
    s.id, s.title as series_title, b.releaseDate, b.id as episodeId, b.title,
    p.name as productionCompany_name, p.description as productionCompany_description, p.website as productionCompany_website,
    p.phone as productionCompany_phone, p.city as productionCompany_city, p.street as productionCompany_street,
    c.name as productionCompany_country_name, c.region as productionCompany_country_region, c.subregion as productionCompany_country_subregion,
    sa.basePrice as salesInfo_basePrice, sa.discount as salesInfo_discount

  from [db2_source].Series.Movies as b
    inner join [db2_source].Series.Series as s on b.serieId = s.id
    inner join [db2_source].Movies.ProductionCompanies as p on b.productionCompanyId = p.id
    inner join [db2_source].dbo.SalesInfo as sa on b.salesInfoId = sa.id
    inner join [db2_source].dbo.Countries c on c.id = p.countryId

  insert into tmp.dimension_serie_active
  select
    seqId, serieId, series_title, releaseDate, episodeId, title,
    productionCompany_name, productionCompany_description, productionCompany_website,
    productionCompany_phone, productionCompany_city, productionCompany_street,
    productionCompany_country_name, productionCompany_country_region, productionCompany_country_subregion,
    salesInfo_basePrice, salesInfo_discount,
    start_date, end_date, flag
  from serie.dimension_episode
  where flag = 1;

  insert into tmp.dimension_serie_final
    (seq_id, serie_id, title, releaseDate, episodeId, series_title,
    productionCompany_name, productionCompany_description, productionCompany_website,
    productionCompany_phone, productionCompany_city, productionCompany_street,
    productionCompany_country_name, productionCompany_country_region, productionCompany_country_subregion,
    salesInfo_basePrice, salesInfo_discount,
    start_date, end_date, flag)
  select
    seqId, serieId, series_title, releaseDate, episodeId, title,
    productionCompany_name, productionCompany_description, productionCompany_website,
    productionCompany_phone, productionCompany_city, productionCompany_street,
    productionCompany_country_name, productionCompany_country_region, productionCompany_country_subregion,
    salesInfo_basePrice, salesInfo_discount,
    start_date, end_date, flag
  from serie.dimension_episode
  where flag = 0;

  insert into tmp.dimension_serie_final
    (seq_id, serie_id, title, releaseDate, episodeId, series_title,
    productionCompany_name, productionCompany_description, productionCompany_website,
    productionCompany_phone, productionCompany_city, productionCompany_street,
    productionCompany_country_name, productionCompany_country_region, productionCompany_country_subregion,
    salesInfo_basePrice, salesInfo_discount,
    start_date, end_date, flag)
  select
    o.seq_id, o.serie_id, o.series_title, o.releaseDate, o.episodeId, o.title,
    isnull(n.productionCompany_name, o.productionCompany_name), o.productionCompany_description, o.productionCompany_website,
    o.productionCompany_phone, o.productionCompany_city, o.productionCompany_street,
    o.productionCompany_country_name, o.productionCompany_country_region, o.productionCompany_country_subregion,
    o.salesInfo_basePrice, o.salesInfo_discount,
    o.start_date, o.end_date, o.flag
  from tmp.dimension_serie_source_join as n
    full outer join tmp.dimension_serie_active as o on o.episodeId = n.episodeId
  where (o.episodeId is not null and n.episodeId is null)
    or (o.salesInfo_basePrice = n.salesInfo_basePrice and o.salesInfo_discount = n.salesInfo_discount)

  insert into tmp.dimension_serie_final
    (seq_id, serie_id, title, releaseDate, episodeId, series_title,
    productionCompany_name, productionCompany_description, productionCompany_website,
    productionCompany_phone, productionCompany_city, productionCompany_street,
    productionCompany_country_name, productionCompany_country_region, productionCompany_country_subregion,
    salesInfo_basePrice, salesInfo_discount,
    start_date, end_date, flag)
  select
    o.seq_id, o.serie_id, o.series_title, o.releaseDate, o.episodeId, o.title,
    o.productionCompany_name, o.productionCompany_description, o.productionCompany_website,
    o.productionCompany_phone, o.productionCompany_city, o.productionCompany_street,
    o.productionCompany_country_name, o.productionCompany_country_region, o.productionCompany_country_subregion,
    o.salesInfo_basePrice, o.salesInfo_discount,
    o.start_date, getdate(), 0
  from tmp.dimension_serie_source_join as n
    inner join tmp.dimension_serie_active as o on o.episodeId = n.episodeId
  where (o.salesInfo_basePrice != n.salesInfo_basePrice or o.salesInfo_discount != n.salesInfo_discount)


  SET IDENTITY_INSERT tmp.dimension_serie_final OFF;
  insert into tmp.dimension_serie_final
  select
    n.serie_id, n.series_title, n.releaseDate, n.episodeId, n.title,
    n.productionCompany_name, n.productionCompany_description, n.productionCompany_website,
    n.productionCompany_phone, n.productionCompany_city, n.productionCompany_street,
    n.productionCompany_country_name, n.productionCompany_country_region, n.productionCompany_country_subregion,
    n.salesInfo_basePrice, n.salesInfo_discount,
    getdate(), null, 1
  from tmp.dimension_serie_source_join as n
    full outer join tmp.dimension_serie_active as o on o.episodeId = n.episodeId
  where (n.episodeId is not null and o.episodeId is null)
    or (o.salesInfo_basePrice != n.salesInfo_basePrice or o.salesInfo_discount != n.salesInfo_discount)


  truncate table serie.dimension_episode;

  insert into serie.dimension_episode
  select
    seq_id, serie_id, series_title, releaseDate, episodeId, title,
    productionCompany_name, productionCompany_description, productionCompany_website,
    productionCompany_phone, productionCompany_city, productionCompany_street,
    productionCompany_country_name, productionCompany_country_region, productionCompany_country_subregion,
    salesInfo_basePrice, salesInfo_discount,
    start_date, end_date, flag
  from tmp.dimension_serie_final;
end

CREATE OR ALTER PROCEDURE "dimension_serie_genre_update"
as
begin
  declare @dimCount int;
  declare @tempCount int;

  set @dimCount = (select count(*)
  from serie.dimension_genre);
  set @tempCount = (select count(*)
  from tmp.dimension_serie_genre_final);

  if (@dimCount = 0 and @tempCount > 0)
        return 0;

  truncate table tmp.dimension_serie_genre_source;
  truncate table tmp.dimension_serie_genre_final;

  insert into tmp.dimension_serie_genre_source
  select
    id, name
  from [db2_source].Movies.Genres

  insert into tmp.dimension_serie_genre_final
  select
    isnull(o.id, n.id), isnull(o.name, n.name)
  from tmp.dimension_serie_genre_source as n
    full outer join serie.dimension_genre as o on o.id = n.id

  truncate table serie.dimension_genre;

  insert into serie.dimension_genre
  select
    id, name
  from tmp.dimension_serie_genre_final;
end

CREATE OR ALTER PROCEDURE "dimension_serie_director_update"
as
begin
  declare @dimCount int;
  declare @tempCount int;

  set @dimCount = (select count(*)
  from serie.dimension_director);
  set @tempCount = (select count(*)
  from tmp.dimension_serie_director_final);

  if (@dimCount = 0 and @tempCount > 0)
        return 0;

  truncate table tmp.dimension_serie_director_source;
  truncate table tmp.dimension_serie_director_final;

  insert into tmp.dimension_serie_director_source
  select
    a.id, a.name, birthdate, description, c.name as country_name
  from [db2_source].Movies.Directors a
    inner join [db2_source].dbo.Countries c on c.id = a.countryId

  insert into tmp.dimension_serie_director_final
  select
    isnull(o.id, n.id), isnull(o.name, n.name), isnull(o.birthdate, n.birthdate),
    isnull(o.description, n.description), isnull(o.country_name, n.country_name)
  from tmp.dimension_serie_director_source as n
    full outer join serie.dimension_director as o on o.id = n.id

  truncate table serie.dimension_director;

  insert into serie.dimension_director
  select
    id, name, birthdate, description, country_name
  from tmp.dimension_serie_director_final;
end

CREATE OR ALTER PROCEDURE "fact_serie_transactional_update"
as
begin
  declare @factCount int;
  declare @tempCount int;
  declare @currdate date;

  set @factCount = (select count(*)
  from serie.fact_serie);
  set @tempCount = (select count(*)
  from tmp.fact_serie_final);

  if (@factCount = 0 and @tempCount > 0)
        return 0;

  if(@factCount = 0)
		set @currdate = CAST('2010-01-01' as date);
	else
		set @currdate = (select CAST(max(f.purchase_date) as date)
  from serie.fact_serie as f)

  truncate table tmp.fact_serie_source;
  truncate table tmp.fact_serie_source_join;
  truncate table tmp.fact_serie_final;


  while @currdate <= CAST(GETDATE() as date) begin
    truncate table tmp.fact_serie_source;
  	truncate table tmp.fact_serie_source_join;
    insert into tmp.fact_serie_source
    select t.id, t.customerId, t.movieId, t.date, t.time, t.price
    from [db2_source].Series.Transactions as t
    where t.date = DATEADD(day, 1, @currdate)

    insert into tmp.fact_serie_source_join
    select b.seqId, t.date, t.time, t.customerId, t.price
    from tmp.fact_serie_source as t
      inner join serie.dimension_episode as b on b.episodeId = t.serieId
    where b.flag = 1

    insert into tmp.fact_serie_final
    select serie_seq_id, purchase_date, purchase_time, customer_id, total_price
    from tmp.fact_serie_source_join

    set @currdate = DATEADD(day, 1, @currdate);
  end

  truncate table serie.fact_serie;

  insert into serie.fact_serie
  select
    serie_seq_id, purchase_date, purchase_time, customer_id, total_price
  from tmp.fact_serie_final;
end

CREATE OR ALTER PROCEDURE "fact_serie_rating_update"
as
begin
  declare @factCount int;
  declare @tempCount int;
  declare @currdate date;

  set @factCount = (select count(*)
  from serie.fact_rating);
  set @tempCount = (select count(*)
  from tmp.fact_serie_rating_tmp);

  if (@factCount = 0 and @tempCount > 0)
        return 0;

  if(@factCount = 0)
        set @currdate = CAST('2010-01-01' as date);
    else
        set @currdate = (select CAST(max(f.purchase_date) as date)
  from serie.fact_serie as f)

  truncate table tmp.fact_serie_rating_tmp;
  truncate table tmp.fact_serie_rating_source;
  truncate table tmp.fact_serie_rating_source_join;
  truncate table tmp.fact_serie_rating_avg;
  truncate table tmp.fact_serie_rating_final;


  insert into tmp.fact_serie_rating_tmp
  select serie_seq_id, avg_rating, rating_count, last_rate_date
  from serie.fact_rating
  while @currdate <= CAST(GETDATE() as date) begin
  	truncate table tmp.fact_serie_rating_source;
  	truncate table tmp.fact_serie_rating_source_join;
  	truncate table tmp.fact_serie_rating_avg;
  	truncate table tmp.fact_serie_rating_final;
    insert into tmp.fact_serie_rating_source
    select r.id, r.customerId, r.movieId, r.rating, r.description, r.date
    from [db2_source].Series.Ratings as r
    where r.date = DATEADD(day, 1, @currdate)

    insert into tmp.fact_serie_rating_source_join
    select b.seqId, r.customerId, r.rating, r.date
    from tmp.fact_serie_rating_source as r
      inner join serie.dimension_episode as b on b.episodeId = r.serieId
    where b.flag = 1

    insert into tmp.fact_serie_rating_avg
    select r.seq_id, avg(r.rating), count(*), max(r.date)
    from tmp.fact_serie_rating_source_join as r
    group by r.seq_id

    insert into tmp.fact_serie_rating_final
    select isnull(r.serie_seq_id, f.serie_seq_id),
      (isnull(r.avg_rating, 0) * isnull(r.rating_count, 0) + isnull(f.avg_rating, 0) * isnull(f.rating_count, 0)) / (isnull(r.rating_count, 0) + isnull(f.rating_count, 0)),
      isnull(r.rating_count, 0) + isnull(f.rating_count, 0),
      isnull(r.last_rate_date, f.last_rate_date)
    from tmp.fact_serie_rating_avg as r
      full outer join tmp.fact_serie_rating_tmp as f on f.serie_seq_id = r.serie_seq_id

    truncate table tmp.fact_serie_rating_tmp;

    insert into tmp.fact_serie_rating_tmp
    select serie_seq_id, avg_rating, rating_count, last_rate_date
    from tmp.fact_serie_rating_final

    truncate table tmp.fact_serie_rating_final;


    set @currdate = DATEADD(day, 1, @currdate);
  end

  truncate table serie.fact_rating;

  insert into serie.fact_rating
  select
    serie_seq_id, avg_rating, rating_count, last_rate_date
  from tmp.fact_serie_rating_tmp;
end

CREATE OR ALTER PROCEDURE "fact_serie_genre_update"
as
begin
  declare @factCount int;
  declare @tempCount int;

  set @factCount = (select count(*)
  from serie.fact_genre);
  set @tempCount = (select count(*)
  from tmp.fact_serie_genre_final);

  if (@factCount = 0 and @tempCount > 0)
        return 0;



  truncate table tmp.fact_serie_genre_source;
  truncate table tmp.fact_serie_genre_join;
  truncate table tmp.fact_serie_genre_final;

  
    insert into tmp.fact_serie_genre_source
    select movieId, genreId
    from [db2_source].Series.MoviesGenres as g

    insert into tmp.fact_serie_genre_join
    select b.seqId, g.serieId, g.genreId
    from tmp.fact_serie_genre_source as g
      inner join serie.dimension_episode as b on b.episodeId = g.serieId
    where b.flag = 1

    insert into tmp.fact_serie_genre_final
    select isnull(o.serie_seq_id, g.serie_seq_id), isnull(o.genre_id, g.genre_id)
    from tmp.fact_serie_genre_join as g
      full outer join serie.fact_genre as o on o.serie_seq_id = g.serie_seq_id

  

  truncate table serie.fact_genre;

  insert into serie.fact_genre
  select serie_seq_id, genre_id
  from tmp.fact_serie_genre_final;
end