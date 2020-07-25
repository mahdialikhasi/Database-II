CREATE TABLE [dbo].[Turn_Over](
	[Dep_Id] [int] NULL,
	[Trn_Time] [datetime] NULL,
	[Trn_over] [int]
)
CREATE TABLE [dbo].[FactdeptrnTemp1](
	[Dep_Id] [int] NULL,
	[Trn_Time] [datetime] NULL,
	[Trn_over] [int]
)

CREATE TABLE [dbo].[Factdeptrn](
	[Dep_Id] [int] NULL,
	[Trn_Time] [datetime] NULL,
	[Trn_over] [int],
	[Balance] [int]
)
CREATE TABLE [dbo].[FactdeptrnTemp2](
	[Dep_Id] [int] NULL,
	[Trn_Time] [datetime] NULL,
	[Trn_over] [int],
	[s] [int]
)


INSERT [dbo].[Turn_Over] VALUES (1022, CAST('2018-06-15 14:00' AS datetime), 100)
INSERT [dbo].[Turn_Over] VALUES (1022, CAST('2018-06-15 14:28' AS datetime), -50)
INSERT [dbo].[Turn_Over] VALUES (1022, CAST('2018-06-16 14:58' AS datetime), 25)
INSERT [dbo].[Turn_Over] VALUES (1067, CAST('2019-07-18 23:32' AS datetime), 300)


CREATE OR ALTER PROCEDURE "Factdeptrn_daily" as
begin
	declare @currdate date;
	declare @factCount int;
    declare @tempCount int;
    declare @temp2Count int;

	set @factCount = (select count(*) from Factdeptrn);
    set @tempCount = (select count(*) from FactdeptrnTemp1);
    set @temp2Count = (select count(*) from FactdeptrnTemp2);

    if (@factCount = 0 and (@tempCount > 0 or @temp2Count > 0))
        return 0;
    if(@factCount = 0)
		set @currdate = CAST('2010-01-01' as date);
	else
		set @currdate = (select CAST(max(Trn_Time) as date) from Factdeptrn)


	truncate table FactdeptrnTemp1;
	truncate table FactdeptrnTemp2;
	
	while @currdate <= CAST(GETDATE() as date) begin
		insert into FactdeptrnTemp1
			select f.Dep_Id, f.Trn_Time, f.Trn_over
			from Turn_Over f where f.Trn_Time > DATEADD(day, 1, @currdate) and f.Trn_Time <= DATEADD(day, 2, @currdate);
		
		insert into FactdeptrnTemp2
			select f.Dep_Id, f.Trn_Time, f.Trn_over, sum(Trn_over) over(PARTITION by f.Dep_Id ORDER BY Trn_Time ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as s
			from FactdeptrnTemp1 f;
		
		-- insert into FactdeptrnTemp3
		-- 	select f.Dep_Id, f.Trn_Time, f.Trn_over, f.Balance
		-- 	from Factdeptrn f where f.Trn_Time > @currdate and f.Trn_Time <= DATEADD(day, 1, @currdate);
		
		-- insert into FactdeptrnTemp4
		-- 	select isnull(f1.Dep_Id, f2.Dep_Id), isnull(f)
		-- 	from FactdeptrnTemp2 as f1 full outer join FactdeptrnTemp3 as f2 on f1.Dep_Id = f2.Dep_Id 

		insert into Factdeptrn
			select f.Dep_Id, f.Trn_Time, f.Trn_over, f.s
			from FactdeptrnTemp2 f;

		truncate table FactdeptrnTemp1;
		truncate table FactdeptrnTemp2;
		
		set @currdate = DATEADD(day, 1, @currdate);
	end

end