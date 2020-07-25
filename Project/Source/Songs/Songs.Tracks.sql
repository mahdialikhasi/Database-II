declare @JSON varchar(max)

select @JSON = BulkColumn
from openrowset 
  (BULK '/home/mahdialikhasi/Downloads/Songs/Songs.Tracks.json', single_clob) 
as j;

insert into Songs.Tracks
select *
from openjson (@JSON)
with (
  id int,
  title varchar(50),
  album int,
  salesInfo int,
  length int
);
