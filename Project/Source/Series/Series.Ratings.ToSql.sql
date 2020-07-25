declare @JSON varchar(max)

select @JSON = BulkColumn
from openrowset 
  (BULK '/home/mahdialikhasi/Downloads/Series/Series.Ratings.json', single_clob) 
as j;

insert into Series.Ratings
select id, convert(date, date, 103), rating, description, customerId, seriesMovieId
from openjson (@JSON)
with (
  id int,
  date varchar(100),
  rating tinyint,
  description varchar(max),
  customerId int,
  seriesMovieId int
);
