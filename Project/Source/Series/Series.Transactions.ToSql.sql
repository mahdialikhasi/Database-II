declare @JSON varchar(max)

select @JSON = BulkColumn
from openrowset 
  (BULK '/home/mahdialikhasi/Downloads/Series/Series.Transactions.json', single_clob) 
as j;

insert into Series.Transactions
select id, convert(date, date, 103), time, price, customerId, seriesMovieId
from openjson (@JSON)
with (
  id int,
  date varchar(100),
  time time(0),
  price float,
  customerId int,
  seriesMovieId int
);
