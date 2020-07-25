declare @JSON varchar(max)

select @JSON = BulkColumn
from openrowset 
  (BULK '/home/mahdialikhasi/Downloads/Books/Books.Ratings.json', single_clob) 
as j;

insert into Books.Ratings
select id, convert(date, date, 103), rating, description, bookId, customerId
from openjson (@JSON)
with (
  id int,
  date date,
  rating tinyint,
  description varchar(max),
  bookId int,
  customerId int
);
