CREATE OR ALTER PROCEDURE "PROC1" as
begin
	declare @currdate date;
	drop table IF EXISTS Final;
	drop table IF EXISTS temp1;
	
	BEGIN TRAN
	CREATE TABLE Final(
		[VoucherId] [varchar](21) NULL,
		[TrnDate] [date] NULL,
		[TrnTime] [varchar](6) NULL,
		[Amount] [bigint] NULL,
		[SourceDep] [int] NULL,
		[DesDep] [int] NULL
	)

	
	CREATE TABLE temp1(
		[VoucherId] [varchar](21) NULL,
		[TrnDate] [date] NULL,
		[TrnTime] [varchar](6) NULL,
		[Amount] [bigint] NULL,
		[SourceDep] [int] NULL,
		[DesDep] [int] NULL
	)

	set @currdate = CAST('2010-01-01' as date);

	delete from temp1;
	delete from Final;
	commit TRAN;
	
	while @currdate <= CAST(GETDATE() as date) begin
		BEGIN TRAN
		insert into temp1
			select f.VoucherId, f.TrnDate, f.TrnTime, f.Amount, f.SourceDep, f.DesDep
			from Trn_Src_Des f where f.TrnDate = @currdate;
		commit TRAN;
		
		BEGIN TRAN
		insert into Final
			select 
				case 
					when t2.VoucherId is not null then concat(t1.VoucherId, concat('|', t2.VoucherId))
					else t1.VoucherId
				end, t1.TrnDate, t1.TrnTime, t1.Amount, t1.SourceDep, t1.DesDep
			from temp1 as t1
			left outer join temp1 as t2 on t1.TrnDate = t2.TrnDate and t1.TrnTime = t2.TrnTime and t1.Amount = t2.Amount and t1.SourceDep = t2.SourceDep and t1.DesDep = t2.DesDep and t1.VoucherId != t2.VoucherId
			where t1.VoucherId < t2.VoucherId or t2.VoucherId is null
		commit TRAN;

		BEGIN TRAN
		delete from temp1;
		commit TRAN;
		
		BEGIN TRAN
		delete from Trn_Src_Des where TrnDate = @currdate;
		insert into Trn_Src_Des
			select f.VoucherId, f.TrnDate, f.TrnTime, f.Amount, f.SourceDep, f.DesDep
			from Final as f

		delete from Final;
		commit TRAN;

		set @currdate = DATEADD(day, 1, @currdate);
	end

	BEGIN TRAN
	drop table Final;
	drop table temp1;
	commit TRAN;
end