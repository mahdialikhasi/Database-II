declare @JSON varchar(max)

select @JSON = BulkColumn
from openrowset 
  (BULK '/home/mahdialikhasi/Downloads/Series/Series.Series.json', single_clob) 
as j;

insert into Series.Series
select *
from openjson (@JSON)
with (
  id int,
  title varchar(50),
  description varchar(max)
);
