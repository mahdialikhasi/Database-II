declare @JSON varchar(max)

select @JSON = BulkColumn
from openrowset 
  (BULK '/home/mahdialikhasi/Downloads/Books/Books.Publishers.json', single_clob) 
as j;

insert into Books.Publishers
select *
from openjson (@JSON)
with (
  id int,
  name varchar(50),
  description varchar(max),
  website varchar(50),
  phone varchar(50),
  city varchar(50),
  street varchar(50),
  country int
);
