declare @JSON varchar(max)

select @JSON = BulkColumn
from openrowset 
  (BULK '/home/mahdialikhasi/Downloads/Songs/Songs.AlbumsArtists.json', single_clob) 
as j;

insert into Songs.AlbumsArtists
select *
from openjson (@JSON)
with (
  id int,
  albumId int,
  artistId int
);
