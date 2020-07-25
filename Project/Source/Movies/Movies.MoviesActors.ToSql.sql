declare @JSON varchar(max)

select @JSON = BulkColumn
from openrowset 
  (BULK '/home/mahdialikhasi/Downloads/Movies/Movies.MoviesActors.json', single_clob) 
as j;

insert into Movies.MoviesActors
select *
from openjson (@JSON)
with (
  id int,
  movieId int,
  actorId int
);
