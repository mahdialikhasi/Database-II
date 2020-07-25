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
        inner join [db2_source].dbo.Countries c on c.id = p.countryId    
    

    insert into tmp.dimension_customer_final
        select
            isnull(o.customer_id,n.customer_id), isnull(o.firstName,n.firstName), isnull(o.lastName,n.lastName),
            isnull(o.gender,n.gender), isnull(n.email,o.email), isnull(o.phone,n.phone),
            isnull(o.dateJoined,n.dateJoined), isnull(o.country_name,n.country_name), isnull(o.region,n.region), isnull(o.subregion, n.subregion)
        from tmp.dimension_customer_source_join as n
            full outer join customer.dimension_customer as o on o.customer_id = n.customer_id
        
    truncate table customer.dimension_customer;
        
    insert into customer.dimension_customer
        select
            customer_id, firstName, lastName, gender, email, phone, dateJoined, country_name, region, subregion
        from tmp.dimension_customer_final;
end
