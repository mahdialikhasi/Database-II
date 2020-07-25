declare @JSON varchar(max)

select @JSON = BulkColumn
from openrowset 
  (BULK '/home/mahdialikhasi/Downloads/Books/Books.Books.json', single_clob) 
as j;

insert into Books.Books
select id, isbn, title, convert(date, publicationDate, 103), edition, description, publisher, salesInfo
from openjson (@JSON)
with (
  id int,
  isbn varchar(50),
  title varchar(50),
  publicationDate varchar(max),
  edition int,
  description varchar(max),
  publisher int,
  salesInfo int
);
