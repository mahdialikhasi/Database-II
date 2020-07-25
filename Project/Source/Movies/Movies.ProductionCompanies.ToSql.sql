declare @JSON varchar(max)

select @JSON = BulkColumn
from openrowset 
  (BULK '/home/mahdialikhasi/Downloads/Movies/Movies.ProductionCompanies.json', single_clob) 
as j;

insert into Movies.ProductionCompanies
select *
from openjson (@JSON)
with (
  id int,
  name varchar(50),
  description varchar(max),
  website varchar(50),
  phone varchar(50),
  city varchar(50),
  street varchar(50),
  countryId int
);
