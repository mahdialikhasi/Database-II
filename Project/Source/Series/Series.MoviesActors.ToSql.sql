declare @JSON varchar(max)

select @JSON = BulkColumn
from openrowset 
  (BULK '/home/mahdialikhasi/Downloads/Series/Series.MoviesActors.json', single_clob) 
as j;

insert into Series.MoviesActors
select *
from openjson (@JSON)
with (
  id int,
  actorId int,
  movieId int
);
