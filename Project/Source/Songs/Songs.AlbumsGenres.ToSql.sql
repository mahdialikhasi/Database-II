declare @JSON varchar(max)

select @JSON = BulkColumn
from openrowset 
  (BULK '/home/mahdialikhasi/Downloads/Songs/Songs.AlbumsGenres.json', single_clob) 
as j;

insert into Songs.AlbumsGenres
select *
from openjson (@JSON)
with (
  id int,
  albumId int,
  genreId int
);
