declare @JSON varchar(max)

select @JSON = BulkColumn
from openrowset 
  (BULK '/home/mahdialikhasi/Downloads/Books/Books.Transactions.json', single_clob) 
as j;

insert into Books.Transactions
select id, convert(date, date, 103), time, price, bookId, customerId
from openjson (@JSON)
with (
  id int,
  date varchar(max),
  time time(0),
  price float,
  bookId int,
  customerId int
);
