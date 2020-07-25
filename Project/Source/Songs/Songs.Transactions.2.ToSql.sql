declare @JSON varchar(max)

select @JSON = BulkColumn
from openrowset 
  (BULK '/home/mahdialikhasi/Downloads/Songs/Songs.Transactions.2.json', single_clob) 
as j;

insert into Songs.Transactions
select id, convert(date, date, 103), time, price, customerId, trackId
from openjson (@JSON)
with (
  id int,
  date varchar(100),
  time time(0),
  price float,
  customerId int,
  trackId int
);
