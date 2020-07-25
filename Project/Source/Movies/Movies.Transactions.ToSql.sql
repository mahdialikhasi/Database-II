declare @JSON varchar(max)

select @JSON = BulkColumn
from openrowset 
  (BULK '/home/mahdialikhasi/Downloads/Movies/Movies.Transactions.json', single_clob) 
as j;

insert into Movies.Transactions
select id, convert(date, date, 103), time, price, customerId, movieId
from openjson (@JSON)
with (
  id int,
  date varchar(100),
  time time(0),
  price float,
  customerId int,
  movieId int
);
