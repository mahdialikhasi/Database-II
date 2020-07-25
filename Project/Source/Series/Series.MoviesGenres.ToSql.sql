declare @JSON varchar(max)

select @JSON = BulkColumn
from openrowset 
  (BULK '/home/mahdialikhasi/Downloads/Series/Series.MoviesGenres.json', single_clob) 
as j;

insert into Series.MoviesGenres
select *
from openjson (@JSON)
with (
  id int,
  movieId int,
  genreId int
);
