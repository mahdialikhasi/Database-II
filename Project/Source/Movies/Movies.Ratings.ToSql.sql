declare @JSON varchar(max)

select @JSON = BulkColumn
from openrowset 
  (BULK '/home/mahdialikhasi/Downloads/Movies/Movies.Ratings.json', single_clob) 
as j;

insert into Movies.Ratings
select id, convert(date, date, 103), rating, description, movieId, customerId
from openjson (@JSON)
with (
  id int,
  date varchar(100),
  rating tinyint,
  description varchar(max),
  movieId int,
  customerId int
);
