CREATE OR ALTER PROCEDURE "dimension_customer_update" as 
begin
    declare @dimCount int;
    declare @tempCount int;
    
    set @dimCount = (select count(*) from customer.dimension_customer);
    set @tempCount = (select count(*) from tmp.dimension_customer_final);
    
    if (@dimCount = 0 and @tempCount > 0)
        return 0;
    
    truncate table tmp.dimension_customer_source_join;
    truncate table tmp.dimension_customer_final;
    
    insert into tmp.dimension_customer_source_join
        select 
            p.id, firstName, lastName, gender, email, phone, dateJoined, c.name, c.region, c.subregion
        from [db2_source].dbo.Customers p
        inner join country c on c.id = p.countryId    
    

    insert into tmp.dimension_customer_final
        select
            isnull(o.customer_id,n.customer_id), isnull(o.firstName,n.firstName), isnull(o.lastName,n.lastName),
            isnull(o.gender,n.gender), isnull(n.email,o.email), isnull(o.phone,n.phone),
            isnull(o.dateJoined,n.dateJoined), isnull(n.country_name,o.country_name), isnull(n.country_region,o.country_region), isnull(n.country_subregion,o.country_subregion)
        from tmp.dimension_customer_source_join as n
            full outer join customer.dimension_customer as o on o.customer_id = n.customer_id
        
    truncate table customer.dimension_customer;
        
    insert into customer.dimension_customer
        select
            customer_id, firstName, lastName, gender, email, phone, dateJoined, country_name
        from tmp.dimension_customer_final;
end

CREATE OR ALTER PROCEDURE "fact_customer_transactional_update"
as
begin
    declare @factCount int;
    declare @tempCount int;
    declare @currdate date;

    set @factCount = (select count(*)
    from customer.fact_customer);
    set @tempCount = (select count(*)
    from tmp.fact_customer_final);

    if (@factCount = 0 and @tempCount > 0)
        return 0;

    if(@factCount = 0)
		set @currdate = CAST('2010-01-01' as date);
	else
		set @currdate = (select CAST(max(f.purchase_date) as date)
    from customer.fact_customer as f)

    truncate table tmp.fact_customer_final;


    -- Type for Book is 1
    -- Type for Movie is 2
    -- Type for Episode is 3
    -- Type for Song is 4

    while @currdate <= CAST(GETDATE() as date) begin
        insert into tmp.fact_customer_final
        select customer_id, 1, book_seq_id, -1, -1, -1, purchase_date, purchase_time, total_price
        from book.fact_book as t
        where t.purchase_date = DATEADD(day, 1, @currdate)

        insert into tmp.fact_customer_final
        select customer_id, 2, -1, movie_seq_id, -1, -1, purchase_date, purchase_time, total_price
        from movie.fact_movie as t
        where t.purchase_date = DATEADD(day, 1, @currdate)

        insert into tmp.fact_customer_final
        select customer_id, 3, -1, -1, episode_seq_id, -1, purchase_date, purchase_time, total_price
        from serie.fact_serie as t
        where t.purchase_date = DATEADD(day, 1, @currdate)

        insert into tmp.fact_customer_final
        select customer_id, 4, -1, -1, -1, song_seq_id, purchase_date, purchase_time, total_price
        from song.fact_song as t
        where t.purchase_date = DATEADD(day, 1, @currdate)

        set @currdate = DATEADD(day, 1, @currdate);
    end

    truncate table customer.fact_customer;

    insert into customer.fact_customer
    select
        customer_id, type, book_seq_id, movie_seq_id, episode_seq_id, song_seq_id, purchase_date, purchase_time, total_price
    from tmp.fact_customer_final;
end

create or alter procedure "fact_customer_acc_update" as begin
    declare @factCount int;
    declare @tempCount int;
    declare @currdate date;

    set @factCount = (select count(*)
    from customer.fact_acc_customer);
    set @tempCount = (select count(*)
    from tmp.fact_acc_customer_final);

    if (@factCount = 0 and @tempCount > 0)
        return 0;

    if(@factCount = 0)
		set @currdate = CAST('2010-01-01' as date);
	else
		set @currdate = (select CAST(max(f.last_purchase_date) as date)
    from customer.fact_acc_customer as f)

    truncate table tmp.fact_acc_customer_final;

    while @currdate <= CAST(GETDATE() as date) begin
        insert into tmp.fact_acc_customer_final
            select isnull(a.customer_id, t.customer_id), isnull(a.purchase_total_price, 0) + isnull(t.total_price, 0),
                case when t.total_price is not null then a.purchase_total_count + 1 else isnull(a.purchase_total_count, 0) end,
                isnull(t.total_price, 0), t.purchase_date, t.purchase_time, 
                case when t.total_price is not null and a.max_purchase_total_price > t.total_price then a.max_purchase_total_price else isnull(t.total_price, 0) end,
                case when t.total_price is not null and a.max_purchase_total_price > t.total_price then a.max_purchase_date else t.purchase_date end,
                case when t.total_price is not null and a.max_purchase_total_price > t.total_price then a.max_purchase_time else t.purchase_time end,
                case when t.total_price is not null then 0 else a.days_without_purchase + 1 end
            from customer.fact_customer as t
            full outer join customer.fact_acc_customer as a on t.customer_id = a.customer_id
            where t.purchase_date = DATEADD(day, 1, @currdate)

    	set @currdate = DATEADD(day, 1, @currdate);
    end
    
    truncate table customer.fact_acc_customer;

    insert into customer.fact_acc_customer
        select
            customer_id,
            purchase_total_price,
            purchase_total_count,
            last_purchase_total_price,
            last_purchase_date,
            last_purchase_time,
            max_purchase_total_price,
            max_purchase_date,
            max_purchase_time,
            days_without_purchase
        from tmp.fact_acc_customer_final

end