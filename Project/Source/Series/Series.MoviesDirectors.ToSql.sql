declare @JSON varchar(max)

select @JSON = BulkColumn
from openrowset 
  (BULK '/home/mahdialikhasi/Downloads/Series/Series.MoviesDirectors.json', single_clob) 
as j;

insert into Series.MoviesDirectors
select *
from openjson (@JSON)
with (
  id int,
  movieId int,
  directorId int
);
