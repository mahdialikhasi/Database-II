declare @JSON varchar(max)

select @JSON = BulkColumn
from openrowset 
  (BULK '/home/mahdialikhasi/Downloads/Movies/Movies.Movies.json', single_clob) 
as j;

insert into Movies.Movies
select id, title, convert(date, releaseDate, 103), description, productionCompany, salesInfo
from openjson (@JSON)
with (
  id int,
  title varchar(50),
  releaseDate varchar(100),
  description varchar(max),
  productionCompany int,
  salesInfo int
);
