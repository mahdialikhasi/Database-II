declare @JSON varchar(max)

select @JSON = BulkColumn
from openrowset 
  (BULK '/home/mahdialikhasi/Downloads/Movies/Movies.MoviesDirectors.json', single_clob) 
as j;

insert into Movies.MoviesDirectors
select *
from openjson (@JSON)
with (
  id int,
  movieId int,
  directorId int
);
