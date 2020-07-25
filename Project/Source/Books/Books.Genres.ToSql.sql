declare @JSON varchar(max)

select @JSON = BulkColumn
from openrowset 
  (BULK '/home/mahdialikhasi/Downloads/Books/Books.Genres.json', single_clob) 
as j;

insert into Books.Genres
select *
from openjson (@JSON)
with (
  id int,
  name varchar(50)
);
