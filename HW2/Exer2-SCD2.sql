CREATE OR ALTER PROCEDURE "DimCustomerUpdate" as 
begin
    declare @dimCount int;
    declare @tempCount int;
    declare @updatedCount int;
    declare @finalCount int;
    
    set @dimCount = (select count(*) from DimCustomer);
    set @tempCount = (select count(*) from DimCustomerUpdateTemp);
    set @updatedCount = (select count(*) from DimCustomerUpdateUpdatedJobs);
    set @finalCount = (select count(*) from DimCustomerUpdateFinal);
    
    if (@dimCount = 0 and (@tempCount > 0 or @updatedCount > 0 or @finalCount > 0))
        return 0;
    
    truncate table DimCustomerUpdateTemp;
    truncate table DimCustomerUpdateUpdatedJobs;
    truncate table DimCustomerUpdateFinal;
    
    insert into DimCustomerUpdateTemp
        select
            CustCode,
            CustName,
            CustBranch,
            Customer.CustType,
            CustTypeDesc,
            CustNatCode,
            CustJob,
            getdate() as CustJobStartDate,
            null as CustJobEndDate,
            1 as CustJobIsActive,
            CustPhoneNum
        from Customer
        join CustomerType
        on Customer.CustType = CustomerType.CustType ;
    
    
    insert into DimCustomerUpdateUpdatedJobs
        select
            isnull(dc.CustCode, c.CustCode),
            isnull(dc.CustName, c.CustName),
            isnull(dc.CustBranch, c.CustBranch),
            isnull(dc.CustType, c.CustType),
            isnull(dc.CustTypeDesc, c.CustTypeDesc),
            isnull(dc.CustNatCode, c.CustNatCode),
            isnull(c.CustJob, dc.CustJob),
            getdate() as CustJobStartDate,
            null as CustJobEndDate,
            1 as CustJobIsActive,
            isnull(dc.CustPhoneNum, c.CustPhoneNum)
        from DimCustomerUpdateTemp as c
        left join DimCustomer as dc
        on c.CustCode = dc.CustCode
        where dc.CustCode is null or (c.CustJob <> dc.CustJob
        and dc.CustJobEndDate is null);
        
    insert into DimCustomerUpdateFinal
        select
            dc.CustCode,
            dc.CustName,
            dc.CustBranch,
            dc.CustType,
            dc.CustTypeDesc,
            dc.CustNatCode,
            dc.CustJob,
            dc.CustJobStartDate,
            isnull(dc.CustJobEndDate, uj.CustJobStartDate) as CustJobEndDate,
            case when uj.CustJobIsActive is not null
                then 0
                else dc.CustJobIsActive
            end
            as CustJobIsActive,
            dc.CustPhoneNum
        from DimCustomer as dc
        left join DimCustomerUpdateUpdatedJobs as uj
        on dc.CustCode = uj.CustCode;
        
    insert into DimCustomerUpdateFinal
        select
            CustCode,
            CustName,
            CustBranch,
            CustType,
            CustTypeDesc,
            CustNatCode,
            CustJob,
            CustJobStartDate,
            CustJobEndDate,
            CustJobIsActive,
            CustPhoneNum
        from DimCustomerUpdateUpdatedJobs;
        
        truncate table DimCustomer;
        
    insert into DimCustomer
        select
            NULL,
            CustCode,
            CustName,
            CustBranch,
            CustType,
            CustTypeDesc,
            CustNatCode,
            CustJob,
            CustJobStartDate,
            CustJobEndDate,
            CustJobIsActive,
            CustPhoneNum
        from DimCustomerUpdateFinal;
end
