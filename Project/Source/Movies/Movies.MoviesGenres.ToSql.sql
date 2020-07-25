declare @JSON varchar(max)

select @JSON = BulkColumn
from openrowset 
  (BULK '/home/mahdialikhasi/Downloads/Movies/Movies.MoviesGenres.json', single_clob) 
as j;

insert into Movies.MoviesGenres
select *
from openjson (@JSON)
with (
  id int,
  movieId int,
  genreId int
);
