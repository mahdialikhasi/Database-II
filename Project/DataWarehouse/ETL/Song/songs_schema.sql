CREATE OR ALTER PROCEDURE "dimension_track_update"
as
begin
  declare @dimCount int;
  declare @tempCount int;

  set @dimCount = (select count(*)
  from song.dimension_track);
  set @tempCount = (select count(*)
  from tmp.dimension_track_final);

  if (@dimCount = 0 and @tempCount > 0)
        return 0;

  truncate table tmp.dimension_track_source_join;
  truncate table tmp.dimension_track_active;
  truncate table tmp.dimension_track_final;

  SET IDENTITY_INSERT tmp.dimension_track_final ON;

  insert into tmp.dimension_track_source_join
  select
    b.id, b.title, b.length,
    p.title, p.releaseDate, p.description,
    s.basePrice, s.discount

  from [db2_source].Songs.Tracks as b
    inner join [db2_source].Songs.Albums as p on b.album = p.id
    inner join [db2_source].dbo.SalesInfo as s on b.salesInfoId = s.id

  insert into tmp.dimension_track_active
  select
    seq_id, track_id, title, 
    album_title, album_releaseDate, album_description, length,
    salesInfo_basePrice, salesInfo_discount,
    start_date, end_date, flag
  from song.dimension_track
  where flag = 1;

  insert into tmp.dimension_track_final
    (seq_id, track_id, title, length,
    album_title, album_releaseDate, album_description,
    salesInfo_basePrice, salesInfo_discount,
    start_date, end_date, flag)
  select
    seq_id, track_id, title, length,
    album_title, album_releaseDate, album_description,
    salesInfo_basePrice, salesInfo_discount,
    start_date, end_date, flag
  from song.dimension_track
  where flag = 0;

  insert into tmp.dimension_track_final
    (seq_id, track_id, title, length,
    album_title, album_releaseDate, album_description,
    salesInfo_basePrice, salesInfo_discount,
    start_date, end_date, flag)
  select
    o.seq_id, o.track_id, o.title, o.length,
    o.album_title, isnull(n.album_releaseDate, o.album_releaseDate), o.album_description,
    o.salesInfo_basePrice, o.salesInfo_discount,
    o.start_date, o.end_date, o.flag
  from tmp.dimension_track_source_join as n
    full outer join tmp.dimension_track_active as o on o.track_id = n.track_id
  where (o.track_id is not null and n.track_id is null)
    or (o.salesInfo_basePrice = n.salesInfo_basePrice and o.salesInfo_discount = n.salesInfo_discount)

  insert into tmp.dimension_track_final
    (seq_id, track_id, title, length,
    album_title, album_releaseDate, album_description,
    salesInfo_basePrice, salesInfo_discount,
    start_date, end_date, flag)
  select
    o.seq_id, o.track_id, o.title, o.length,
    o.album_title, o.album_releaseDate, o.album_description,
    o.salesInfo_basePrice, o.salesInfo_discount,
    o.start_date, getdate(), 0
  from tmp.dimension_track_source_join as n
    inner join tmp.dimension_track_active as o on o.track_id = n.track_id
  where (o.salesInfo_basePrice != n.salesInfo_basePrice or o.salesInfo_discount != n.salesInfo_discount)


  SET IDENTITY_INSERT tmp.dimension_track_final OFF;
  insert into tmp.dimension_track_final
  select
    n.track_id, n.title,
    n.album_title, n.album_releaseDate, n.album_description, n.length,
    n.salesInfo_basePrice, n.salesInfo_discount,
    getdate(), null, 1
  from tmp.dimension_track_source_join as n
    full outer join tmp.dimension_track_active as o on o.track_id = n.track_id
  where (n.track_id is not null and o.track_id is null)
    or (o.salesInfo_basePrice != n.salesInfo_basePrice or o.salesInfo_discount != n.salesInfo_discount)


  truncate table song.dimension_track;

  insert into song.dimension_track
  select
    seq_id, track_id, title,
    album_title, album_releaseDate, album_description, length,
    salesInfo_basePrice, salesInfo_discount,
    start_date, end_date, flag
  from tmp.dimension_track_final;
end

CREATE OR ALTER PROCEDURE "dimension_album_genre_update"
as
begin
  declare @dimCount int;
  declare @tempCount int;

  set @dimCount = (select count(*)
  from song.dimension_genre);
  set @tempCount = (select count(*)
  from tmp.dimension_album_genre_final);

  if (@dimCount = 0 and @tempCount > 0)
        return 0;

  truncate table tmp.dimension_album_genre_source;
  truncate table tmp.dimension_album_genre_final;

  insert into tmp.dimension_album_genre_source
  select
    id, name
  from [db2_source].Songs.Artists

  insert into tmp.dimension_album_genre_final
  select
    isnull(o.id, n.id), isnull(o.name, n.name)
  from tmp.dimension_album_genre_source as n
    full outer join song.dimension_genre as o on o.id = n.id

  truncate table song.dimension_genre;

  insert into song.dimension_genre
  select
    id, name
  from tmp.dimension_album_genre_final;
end

CREATE OR ALTER PROCEDURE "dimension_track_artist_update"
as
begin
  declare @dimCount int;
  declare @tempCount int;

  set @dimCount = (select count(*)
  from song.dimension_artist);
  set @tempCount = (select count(*)
  from tmp.dimension_track_artist_final);

  if (@dimCount = 0 and @tempCount > 0)
        return 0;

  truncate table tmp.dimension_track_artist_source;
  truncate table tmp.dimension_track_artist_final;

  insert into tmp.dimension_track_artist_source
  select
    a.id, a.name, birthdate, description, c.name, c.region, c.subregion
  from [db2_source].Songs.Artists a
    inner join [db2_source].dbo.Countries c on c.id = a.countryId

  insert into tmp.dimension_track_artist_final
  select
    isnull(o.id, n.id), isnull(o.name, n.name), isnull(o.birthdate, n.birthdate),
    isnull(o.description, n.description), isnull(o.country_name, n.country_name), isnull(o.region, n.region), isnull(o.subregion, n.subregion)
  from tmp.dimension_track_artist_source as n
    full outer join song.dimension_artist as o on o.id = n.id

  truncate table song.dimension_artist;

  insert into song.dimension_artist
  select
    id, name, birthdate, description, country_name, region, subregion
  from tmp.dimension_track_artist_final;
end

CREATE OR ALTER PROCEDURE "fact_track_transactional_update"
as
begin
  declare @factCount int;
  declare @tempCount int;
  declare @currdate date;

  set @factCount = (select count(*)
  from song.fact_song);
  set @tempCount = (select count(*)
  from tmp.fact_track_final);

  if (@factCount = 0 and @tempCount > 0)
        return 0;

  if(@factCount = 0)
		set @currdate = CAST('2010-01-01' as date);
	else
		set @currdate = (select CAST(max(f.purchase_date) as date)
  from song.fact_song as f)

  truncate table tmp.fact_track_source;
  truncate table tmp.fact_track_source_join;
  truncate table tmp.fact_track_final;


  while @currdate <= CAST(GETDATE() as date) begin
    truncate table tmp.fact_track_source;
    truncate table tmp.fact_track_source_join;
    insert into tmp.fact_track_source
    select t.id, t.customerId, t.trackId, t.date, t.time, t.price
    from [db2_source].Songs.Transactions as t
    where t.date = DATEADD(day, 1, @currdate)

    insert into tmp.fact_track_source_join
    select b.seq_id, t.date, t.time, t.customerId, t.price
    from tmp.fact_track_source as t
      inner join song.dimension_track as b on b.track_id = t.track_Id
    where b.flag = 1

    insert into tmp.fact_track_final
    select track_seq_id, purchase_date, purchase_time, customer_id, total_price
    from tmp.fact_track_source_join

    set @currdate = DATEADD(day, 1, @currdate);
  end

  insert into song.fact_song
  select
    track_seq_id, purchase_date, purchase_time, customer_id, total_price
  from tmp.fact_track_final;
end

CREATE OR ALTER PROCEDURE "fact_track_rating_update"
as
begin
  declare @factCount int;
  declare @tempCount int;
  declare @currdate date;

  set @factCount = (select count(*)
  from song.fact_rating);
  set @tempCount = (select count(*)
  from tmp.fact_track_rating_tmp);

  if (@factCount = 0 and @tempCount > 0)
        return 0;

  if(@factCount = 0)
        set @currdate = CAST('2010-01-01' as date);
    else
        set @currdate = (select CAST(max(f.purchase_date) as date)
  from song.fact_track as f)

  truncate table tmp.fact_track_rating_tmp;
  truncate table tmp.fact_track_rating_source;
  truncate table tmp.fact_track_rating_source_join;
  truncate table tmp.fact_track_rating_avg;
  truncate table tmp.fact_track_rating_final;


  insert into tmp.fact_track_rating_tmp
  select song_seq_id, avg_rating, rating_count, last_rate_date
  from song.fact_rating
  while @currdate <= CAST(GETDATE() as date) begin
    truncate table tmp.fact_track_rating_source;
    truncate table tmp.fact_track_rating_source_join;
    truncate table tmp.fact_track_rating_avg;
    truncate table tmp.fact_track_rating_final;


    insert into tmp.fact_track_rating_source
    select r.id, r.customerId, r.trackId, r.rating, r.description, r.date
    from [db2_source].Songs.Ratings as r
    where r.date = DATEADD(day, 1, @currdate)

    insert into tmp.fact_track_rating_source_join
    select b.seq_id, r.customerId, r.rating, r.date
    from tmp.fact_track_rating_source as r
      inner join song.dimension_track as b on b.track_id = r.track_Id
    where b.flag = 1

    insert into tmp.fact_track_rating_avg
    select r.seq_id, avg(r.rating), count(*), max(r.date)
    from tmp.fact_track_rating_source_join as r
    group by r.seq_id

    insert into tmp.fact_track_rating_final
    select isnull(r.track_seq_id, f.track_seq_id),
      (isnull(r.avg_rating, 0) * isnull(r.rating_count, 0) + isnull(f.avg_rating, 0) * isnull(f.rating_count, 0)) / (isnull(r.rating_count, 0) + isnull(f.rating_count, 0)),
      isnull(r.rating_count, 0) + isnull(f.rating_count, 0),
      isnull(r.last_rate_date, f.last_rate_date)
    from tmp.fact_track_rating_avg as r
      full outer join tmp.fact_track_rating_tmp as f on f.track_seq_id = r.track_seq_id

    truncate table tmp.fact_track_rating_tmp;

    insert into tmp.fact_track_rating_tmp
    select track_seq_id, avg_rating, rating_count, last_rate_date
    from tmp.fact_track_rating_final

    truncate table tmp.fact_track_rating_final;


    set @currdate = DATEADD(day, 1, @currdate);
  end

  truncate table song.fact_rating;

  insert into song.fact_rating
  select
    track_seq_id, avg_rating, rating_count, last_rate_date
  from tmp.fact_track_rating_tmp;
end

CREATE OR ALTER PROCEDURE "fact_album_genre_update"
as
begin
  declare @factCount int;
  declare @tempCount int;

  set @factCount = (select count(*)
  from song.fact_genre);
  set @tempCount = (select count(*)
  from tmp.fact_album_genre_final);

  if (@factCount = 0 and @tempCount > 0)
        return 0;


  truncate table tmp.fact_album_genre_source;
  truncate table tmp.fact_album_genre_join;
  truncate table tmp.fact_album_genre_final;


  insert into tmp.fact_album_genre_source
  select albumId, genreId
  from [db2_source].Songs.AlbumsGenres

  insert into tmp.fact_album_genre_join
  select b.seq_id, g.track_Id, g.genreId
  from tmp.fact_album_genre_source as g
    inner join song.dimension_track as b on b.track_id = g.track_Id
  where b.flag = 1

  insert into tmp.fact_album_genre_final
  select isnull(o.seq_id, g.track_seq_id), isnull(o.genre_id, g.genre_id)
  from tmp.fact_album_genre_join as g
    full outer join song.fact_genre as o on o.seq_id = g.track_seq_id



  truncate table song.fact_genre;

  insert into song.fact_genre
  select track_seq_id, genre_id
  from tmp.fact_album_genre_final;
end
