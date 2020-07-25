CREATE OR ALTER PROCEDURE "DimCustomer_ETL_SCD3" as
begin
	declare @count;
	set @count = select count(*) from Final;
	declare @count2;
	set @count2 = select count(*) from temp1;
	IF(@count > 0 or @count2 > 0)
		return 0;
	
	insert into DimCustomer_ETL_SCD3_JoinFromSource
		select c.code, c.name, c.branch, c.type, c2.description, c.nationalCode, c.job, c.phone
		from Source.Customer as c inner join Source.Customer_type as c2 on c2.type = c.type;
	
	insert into DimCustomer_ETL_SCD3_Final
        select
            isnull(dc.CustCode, c.CustCode),
            isnull(dc.CustName, c.CustName),
            isnull(dc.CustBranch, c.CustBranch),
            isnull(dc.CustType, c.CustType),
            isnull(dc.CustTypeDesc, c.CustTypeDesc),
            isnull(dc.CustNatCode, c.custNatCode),
            isnull(dc.CustFirstJob, c.CustJob),
            isnull(dc.CustFirstJobDate, getdate()),
            case 
            	when dc.CustFirstJob is not null and dc.CustSecondJob is null and dc.CustFirstJob != c.CustJob then c.CustJob
            	when dc.CustSecondJob is not null then dc.CustSecondJob
            end,
            case 
            	when dc.CustFirstJob is not null and dc.CustSecondJob is null and dc.CustFirstJob != c.CustJob then getdate()
            	when dc.CustSecondJobDate is not null then dc.CustSecondJobDate 
            end,

			case 
            	when dc.CustSecondJob is not null and dc.CustThirdJob is null and dc.CustSecondJob != c.CustJob then c.CustJob
            	when dc.CustThirdJob is not null then dc.CustThirdJob
            end,
            case 
            	when dc.CustSecondJob is not null and dc.CustThirdJob is null and dc.CustSecondJob != c.CustJob then getdate()
            	when dc.CustThirdJobDate is not null then dc.CustThirdJobDate 
            end,

            case 
            	when dc.CustThirdJob is not null and dc.CustFourthJob is null and dc.CustThirdJob != c.CustJob then c.CustJob
            	when dc.CustFourthJob is not null then dc.CustFourthJob
            end,
            case 
            	when dc.CustThirdJob is not null and dc.CustFourthJob is null and dc.CustThirdJob != c.CustJob then getdate()
            	when dc.CustFourthJobDate is not null then dc.CustFourthJobDate 
            end,

            isnull(dc.CustPhoneNum, c.CustPhoneNums)
        from DimCustomer_ETL_SCD3_JoinFromSource as c
        left outer join DimCustomer as dc on CustCode
		
	

	
		truncate TABLE DimCustomer;
		insert into DimCustomer
			select c.CustCode, c.CustName, c.CustBranch, c.CustType, c.CustTypeDesc, c.CustNatCode, c.CustFirstJob, c.CustFirstJobDate, 
				c.CustSecondJob, c.CustSecondJobDate, c.CustThirdJob, c.CustThirdJobDate, c.CustFourthJob, c.CustFourthJobDate, c.CustPhoneNum
			from DimCustomer_ETL_SCD3_Final as c
	

	
		truncate TABLE DimCustomer_ETL_SCD3_Final
		truncate TABLE DimCustomer_ETL_SCD3_JoinFromSource
	
end