declare @JSON varchar(max)

select @JSON = BulkColumn
from openrowset 
  (BULK '/home/mahdialikhasi/Downloads/Songs/Songs.Albums.json', single_clob) 
as j;

insert into Songs.Albums
select id, title, convert(date, releaseDate, 103), description
from openjson (@JSON)
with (
  id int,
  title varchar(50),
  releaseDate varchar(100),
  description varchar(max)
);
