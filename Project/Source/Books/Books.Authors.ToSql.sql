declare @JSON varchar(max)

select @JSON = BulkColumn
from openrowset 
  (BULK '/home/mahdialikhasi/Downloads/Books/Books.Authors.json', single_clob) 
as j;

insert into Books.Authors
select id, name, convert(date, birthdate, 103), description, country
from openjson (@JSON)
with (
  id int,
  name varchar(50),
  birthdate nvarchar(MAX),
  description nvarchar(MAX),
  country int
);
