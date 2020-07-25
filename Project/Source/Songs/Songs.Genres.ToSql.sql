declare @JSON varchar(max)

select @JSON = BulkColumn
from openrowset 
  (BULK '/home/mahdialikhasi/Downloads/Songs/Songs.Genres.json', single_clob) 
as j;

insert into Songs.Genres
select *
from openjson (@JSON)
with (
  id int,
  name varchar(50)
);
