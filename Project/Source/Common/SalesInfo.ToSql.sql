declare @JSON varchar(max)

select @JSON = BulkColumn
from openrowset 
  (BULK '/home/mahdialikhasi/Downloads/Common/SalesInfo.json', single_clob) 
as j;

insert into SalesInfo
select *
from openjson (@JSON)
with (
  id int,
  basePrice float,
  discount smallint
);
