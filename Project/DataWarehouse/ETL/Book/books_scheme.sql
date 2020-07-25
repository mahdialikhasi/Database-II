CREATE OR ALTER PROCEDURE "dimension_book_update" as 
begin
    declare @dimCount int;
    declare @tempCount int;
    
    set @dimCount = (select count(*) from book.dimension_book);
    set @tempCount = (select count(*) from tmp.dimension_book_final);
    
    if (@dimCount = 0 and @tempCount > 0)
        return 0;
    
    truncate table tmp.dimension_book_source_join;
    truncate table tmp.dimension_book_active;
    truncate table tmp.dimension_book_final;
    
    SET IDENTITY_INSERT tmp.dimension_book_final ON;

    insert into tmp.dimension_book_source_join
        select 
            b.id, b.isbn, b.title, b.publicationDate, b.edition, b.description, 
            p.name, p.description, p.website, p.phone, p.city, p.street, c.name, c.region, c.subregion,
            s.basePrice, s.discount

        from [db2_source].Books.Books as b 
            inner join [db2_source].Books.Publishers as p on b.publisher = p.id
            inner join [db2_source].dbo.SalesInfo as s on b.salesInfoId = s.id
    		inner join [db2_source].dbo.Countries c on c.id = p.countryId
    
    insert into tmp.dimension_book_active
        select
            seq_id, book_id, isbn, title, publicationDate, edition, description, publisher_name, 
            publisher_description, publisher_website, publisher_phone, publisher_city, publisher_street,
            publisher_country_name, region, subregion, salesInfo_basePrice, salesInfo_discount, start_date, end_date, flag
        from book.dimension_book
        where flag = 1;

    insert into tmp.dimension_book_final
        (seq_id, book_id, isbn, title, publicationDate, edition,
            description, publisher_name ,publisher_description, publisher_website ,publisher_phone,
            publisher_city , publisher_street, publisher_country_name, region, subregion, salesInfo_basePrice,
            salesInfo_discount, start_date, end_date, flag)
        select
            seq_id, book_id, isbn, title, publicationDate, edition, description, publisher_name, 
            publisher_description, publisher_website, publisher_phone, publisher_city, publisher_street,
            publisher_country_name, region, subregion, salesInfo_basePrice, salesInfo_discount, start_date, end_date, flag
        from book.dimension_book
        where flag = 0;

    insert into tmp.dimension_book_final
        (seq_id, book_id, isbn, title, publicationDate, edition,
            description, publisher_name ,publisher_description, publisher_website ,publisher_phone,
            publisher_city , publisher_street, publisher_country_name, region, subregion, salesInfo_basePrice,
            salesInfo_discount, start_date, end_date, flag)
        select
            o.seq_id, o.book_id, o.isbn, o.title, o.publicationDate, o.edition, o.description,
            isnull(n.publisher_name, o.publisher_name), o.publisher_description,
            o.publisher_website, o.publisher_phone, o.publisher_city, o.publisher_street,
            o.publisher_country_name, o.region, o.subregion, o.salesInfo_basePrice, o.salesInfo_discount, o.start_date,
            o.end_date, o.flag
        from tmp.dimension_book_source_join as n
            full outer join tmp.dimension_book_active as o on o.book_id = n.book_id
        where (o.book_id is not null and n.book_id is null)
            or (o.salesInfo_basePrice = n.salesInfo_basePrice and o.salesInfo_discount = n.salesInfo_discount)

    insert into tmp.dimension_book_final
        (seq_id, book_id, isbn, title, publicationDate, edition,
            description, publisher_name ,publisher_description, publisher_website ,publisher_phone,
            publisher_city , publisher_street, publisher_country_name, region, subregion , salesInfo_basePrice,
            salesInfo_discount, start_date, end_date, flag)
        select
            o.seq_id, o.book_id, o.isbn, o.title, o.publicationDate, o.edition, o.description, o.publisher_name, 
            o.publisher_description, o.publisher_website, o.publisher_phone, o.publisher_city, o.publisher_street,
            o.publisher_country_name, o.region, o.subregion, o.salesInfo_basePrice, o.salesInfo_discount, o.start_date, getdate(), 0
        from tmp.dimension_book_source_join as n
            inner join tmp.dimension_book_active as o on o.book_id = n.book_id
        where (o.salesInfo_basePrice != n.salesInfo_basePrice or o.salesInfo_discount != n.salesInfo_discount)


    SET IDENTITY_INSERT tmp.dimension_book_final OFF;
    insert into tmp.dimension_book_final
        select
            n.book_id, n.isbn, n.title, n.publicationDate, n.edition, n.description,
            n.publisher_name, n.publisher_description, n.publisher_website, n.publisher_phone,
            n.publisher_city, n.publisher_street, n.publisher_country_name, n.region, n.subregion, n.salesInfo_basePrice,
            n.salesInfo_discount, getdate(), null, 1
        from tmp.dimension_book_source_join as n
            full outer join tmp.dimension_book_active as o on o.book_id = n.book_id
        where (n.book_id is not null and o.book_id is null)
            or (o.salesInfo_basePrice != n.salesInfo_basePrice or o.salesInfo_discount != n.salesInfo_discount)
    
        
    truncate table book.dimension_book;
        
    insert into book.dimension_book
        select
            seq_id, book_id, isbn, title, publicationDate, edition, description, publisher_name,
            publisher_description, publisher_website, publisher_phone, publisher_city,
            publisher_street, publisher_country_name, region, subregion, salesInfo_basePrice, salesInfo_discount,
            start_date, end_date, flag
        from tmp.dimension_book_final;
    insert into log values(
        GETDATE(), 'book.dimension_book', 'sth', 'dimension_book_update');

end

CREATE OR ALTER PROCEDURE "dimension_book_genre_update" as 
begin
    declare @dimCount int;
    declare @tempCount int;
    
    set @dimCount = (select count(*) from book.dimension_genre);
    set @tempCount = (select count(*) from tmp.dimension_book_genre_final);
    
    if (@dimCount = 0 and @tempCount > 0)
        return 0;
    
    truncate table tmp.dimension_book_genre_source;
    truncate table tmp.dimension_book_genre_final;
    
    insert into tmp.dimension_book_genre_source
        select 
            id, name
        from [db2_source].Books.Genres
    
    insert into tmp.dimension_book_genre_final
        select
            isnull(o.id, n.id), isnull(o.name, n.name)
        from tmp.dimension_book_genre_source as n
        	full outer join book.dimension_genre as o on o.id = n.id 

    truncate table book.dimension_genre;
        
    insert into book.dimension_genre
        select
            id, name
        from tmp.dimension_book_genre_final;
        
    insert into log values(
        GETDATE(), 'book.dimension_genre', 'sth', 'dimension_book_genre_update');
end

CREATE OR ALTER PROCEDURE "dimension_book_author_update" as 
begin
    declare @dimCount int;
    declare @tempCount int;
    
    set @dimCount = (select count(*) from book.dimension_author);
    set @tempCount = (select count(*) from tmp.dimension_book_author_final);
    
    if (@dimCount = 0 and @tempCount > 0)
        return 0;
    
    truncate table tmp.dimension_book_author_source;
    truncate table tmp.dimension_book_author_final;
    
    insert into tmp.dimension_book_author_source
        select 
            a.id, a.name, birthdate, description, c.name, c.region, c.subregion
        from [db2_source].Books.Authors a
        inner join [db2_source].dbo.Countries c on c.id = a.countryId
    
    insert into tmp.dimension_book_author_final
        select
            isnull(o.id, n.id), isnull(o.name, n.name), isnull(o.birthdate, n.birthdate), 
            isnull(o.description, n.description), isnull(o.country_name, n.country_name), isnull(o.region, n.region), isnull(o.subregion, n.subregion)
        from tmp.dimension_book_author_source as n
        	full outer join book.dimension_author as o on o.id = n.id 

    truncate table book.dimension_author;
        
    insert into book.dimension_author
        select
            id, name, birthdate, description, country_name, region, subregion
        from tmp.dimension_book_author_final;
end

CREATE OR ALTER PROCEDURE "fact_book_transactional_update" as 
begin
    declare @factCount int;
    declare @tempCount int;
    declare @currdate date;
    
    set @factCount = (select count(*) from book.fact_book);
    set @tempCount = (select count(*) from tmp.fact_book_final);
    
    if (@factCount = 0 and @tempCount > 0)
        return 0;
    
    if(@factCount = 0)
		set @currdate = CAST('2001-01-01' as date);
	else
		set @currdate = (select CAST(max(f.purchase_date) as date) from book.fact_book as f)

    truncate table tmp.fact_book_source;
    truncate table tmp.fact_book_source_join;
    truncate table tmp.fact_book_final;
    

    while @currdate <= CAST(GETDATE() as date) begin
        truncate table tmp.fact_book_source;
        truncate table tmp.fact_book_source_join;
    	insert into tmp.fact_book_source
			select t.id, t.customerId, t.bookId, t.date, t.time, t.price
			from [db2_source].Books.Transactions as t
			where t.date = DATEADD(day, 1, @currdate)

		insert into tmp.fact_book_source_join
			select b.seq_id, t.date, t.time, t.customerId, t.price
			from tmp.fact_book_source as t
			inner join book.dimension_book as b on b.book_id = t.bookId
			where b.flag = 1

		insert into tmp.fact_book_final
			select book_seq_id, purchase_date, purchase_time, customer_id, total_price
			from tmp.fact_book_source_join

    	set @currdate = DATEADD(day, 1, @currdate);
	end
        
    insert into book.fact_book
        select
            book_seq_id, purchase_date, purchase_time, customer_id, total_price
        from tmp.fact_book_final;
end

CREATE OR ALTER PROCEDURE "fact_book_rating_update" as 
begin
    declare @factCount int;
    declare @tempCount int;
    declare @currdate date;
    
    set @factCount = (select count(*) from book.fact_rating);
    set @tempCount = (select count(*) from tmp.fact_book_rating_tmp);
    
    if (@factCount = 0 and @tempCount > 0)
        return 0;
    
    if(@factCount = 0)
        set @currdate = CAST('2010-01-01' as date);
    else
        set @currdate = (select CAST(max(f.purchase_date) as date) from book.fact_book as f)

    truncate table tmp.fact_book_rating_tmp;
    truncate table tmp.fact_book_rating_source;
    truncate table tmp.fact_book_rating_source_join;
    truncate table tmp.fact_book_rating_avg;
    truncate table tmp.fact_book_rating_final;
    

    insert into tmp.fact_book_rating_tmp
        select book_seq_id, avg_rating, rating_count, last_rate_date
        from book.fact_rating
    while @currdate <= CAST(GETDATE() as date) begin
        truncate table tmp.fact_book_rating_source;
        truncate table tmp.fact_book_rating_source_join;
        truncate table tmp.fact_book_rating_avg;
        truncate table tmp.fact_book_rating_final;


        insert into tmp.fact_book_rating_source
            select r.id, r.customerId, r.bookId, r.rating, r.description, r.date
            from [db2_source].Books.Ratings as r
            where r.date = DATEADD(day, 1, @currdate)

        insert into tmp.fact_book_rating_source_join
            select b.seq_id, r.customerId, r.rating, r.date
            from tmp.fact_book_rating_source as r
            inner join book.dimension_book as b on b.book_id = r.bookId
            where b.flag = 1

        insert into tmp.fact_book_rating_avg
            select r.seq_id, avg(r.rating), count(*), max(r.date)      
            from tmp.fact_book_rating_source_join as r
            group by r.seq_id

        insert into tmp.fact_book_rating_final
            select isnull(r.book_seq_id, f.book_seq_id),
            (isnull(r.avg_rating, 0) * isnull(r.rating_count, 0) + isnull(f.avg_rating, 0) * isnull(f.rating_count, 0)) / (isnull(r.rating_count, 0) + isnull(f.rating_count, 0)),
            isnull(r.rating_count, 0) + isnull(f.rating_count, 0),
            isnull(r.last_rate_date, f.last_rate_date)
            from tmp.fact_book_rating_avg as r
            full outer join tmp.fact_book_rating_tmp as f on f.book_seq_id = r.book_seq_id

        truncate table tmp.fact_book_rating_tmp;

        insert into tmp.fact_book_rating_tmp
            select book_seq_id, avg_rating, rating_count, last_rate_date
        from tmp.fact_book_rating_final

        truncate table tmp.fact_book_rating_final;        


        set @currdate = DATEADD(day, 1, @currdate);
    end

    truncate table book.fact_rating;
        
    insert into book.fact_rating
        select
            book_seq_id, avg_rating, rating_count, last_rate_date
        from tmp.fact_book_rating_tmp;
end

CREATE OR ALTER PROCEDURE "fact_book_genre_update" as 
begin
    declare @factCount int;
    declare @tempCount int;
    
    set @factCount = (select count(*) from book.fact_genre);
    set @tempCount = (select count(*) from tmp.fact_book_genre_final);
    
    if (@factCount = 0 and @tempCount > 0)
        return 0;


    truncate table tmp.fact_book_genre_source;
    truncate table tmp.fact_book_genre_join;
    truncate table tmp.fact_book_genre_final;
    
    
        insert into tmp.fact_book_genre_source
            select bookId, genreId
            from [db2_source].Books.BooksGenres as g

        insert into tmp.fact_book_genre_join
            select b.seq_id, g.bookId, g.genreId
            from tmp.fact_book_genre_source as g
            inner join book.dimension_book as b on b.book_id = g.bookId
            where b.flag = 1

        insert into tmp.fact_book_genre_final
            select isnull(o.book_seq_id, g.book_seq_id), isnull(o.genre_id, g.genre_id)     
            from tmp.fact_book_genre_join as g
            full outer join book.fact_genre as o on o.book_seq_id = g.book_seq_id

    

    truncate table book.fact_genre;
        
    insert into book.fact_genre
        select book_seq_id, genre_id
        from tmp.fact_book_genre_final;
end

CREATE OR ALTER PROCEDURE "fact_book_author_update" as 
begin
    declare @factCount int;
    declare @tempCount int;
    
    set @factCount = (select count(*) from book.fact_author);
    set @tempCount = (select count(*) from tmp.fact_book_author_final);
    
    if (@factCount = 0 and @tempCount > 0)
        return 0;


    truncate table tmp.fact_book_author_source;
    truncate table tmp.fact_book_author_join;
    truncate table tmp.fact_book_author_final;
    
    
        insert into tmp.fact_book_author_source
            select bookId, authorId
            from [db2_source].Books.BooksAuthors as g

        insert into tmp.fact_book_author_join
            select b.seq_id, g.bookId, g.authorId
            from tmp.fact_book_author_source as g
            inner join book.dimension_book as b on b.book_id = g.bookId
            where b.flag = 1

        insert into tmp.fact_book_author_final
            select isnull(o.book_seq_id, g.book_seq_id), isnull(o.author_id, g.author_id)     
            from tmp.fact_book_author_join as g
            full outer join book.fact_author as o on o.book_seq_id = g.book_seq_id

    

    truncate table book.fact_author;
        
    insert into book.fact_author
        select book_seq_id, author_id
        from tmp.fact_book_author_final;
end