declare @JSON varchar(max)

select @JSON = BulkColumn
from openrowset 
  (BULK '/home/mahdialikhasi/Downloads/Movies/Movies.Genres.json', single_clob) 
as j;

insert into Movies.Genres
select *
from openjson (@JSON)
with (
  id int,
  name varchar(50)
);
