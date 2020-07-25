declare @JSON varchar(max)

select @JSON = BulkColumn
from openrowset 
  (BULK '/home/mahdialikhasi/Downloads/Songs/Songs.Ratings.json', single_clob) 
as j;

insert into Songs.Ratings
select id, trackId, rating, description, customerId, convert(date, date, 103)
from openjson (@JSON)
with (
  id int,
  trackId int,
  rating tinyint,
  description varchar(100),
  customerId int,
  date varchar(100)
);
