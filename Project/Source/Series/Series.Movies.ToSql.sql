declare @JSON varchar(max)

select @JSON = BulkColumn
from openrowset 
  (BULK '/home/mahdialikhasi/Downloads/Series/Series.Movies.json', single_clob) 
as j;

insert into Series.Movies
select id, title, convert(date, releaseDate, 103), description, productionCompany, salesInfo, season, serie 
from openjson (@JSON)
with (
  id int,
  title varchar(50),
  releaseDate varchar(100),
  description varchar(max),
  productionCompany int,
  salesInfo int,
  season smallint,
  serie int
);
