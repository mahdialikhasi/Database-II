CREATE OR ALTER PROCEDURE "PROC_SCD1" as
begin
	declare @count;
	set @count = select count(*) from Final;
	declare @count2;
	set @count2 = select count(*) from temp1;
	IF(@count > 0 or @count2 > 0)
		return 0;
	
	BEGIN TRAN
		insert into temp1
			select c.code, c.name, c.branch, c.type, c2.description, c.nationalCode, c.job, c.phone
			from Source.Customer as c inner join Source.Customer_type as c2 on c2.type = c.type;
	commit TRAN;
		
	BEGIN TRAN
		insert into Final
			select 
				isnull(c.code, t1.code), isnull(c.name, t1.name), isnull(c.branch, t1.branch), isnull(c.type, t1.type), isnull(c.description, t1.description), isnull(c.nationalCode, t1.nationalCode), isnull(c.job, t1.job), isnull(c.phone, t1.phone)
			from temp1 as t1
			left outer join WH.Customer as c on t1.code = c.code 
			where t1.job = c.job or c.job is null
		insert into Final
			select 
				c.code, c.name, c.branch, c.type, c.description, c.nationalCode, t1.job, c.phone
			from temp1 as t1
			inner join WH.Customer as c on t1.code = c.code and t1.job != c.job
			
	commit TRAN;

	BEGIN TRAN
		truncate TABLE WH.Customer;
		insert into WH.Customer
			select c.code, c.name, c.branch, c.type, c.description, c.nationalCode, c.job, c.phone
			from Final as c
	commit TRAN;

	BEGIN TRAN
		truncate TABLE Final
		truncate TABLE temp1
	commit TRAN;
end