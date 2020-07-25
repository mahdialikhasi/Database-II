declare @JSON varchar(max)

select @JSON = BulkColumn
from openrowset 
  (BULK '/home/mahdialikhasi/Downloads/Common/Countries.json', single_clob) 
as j;

insert into Countries
select *
from openjson (@JSON)
with (
  name varchar(100),
  region varchar(100),
  subregion varchar(100),
);
