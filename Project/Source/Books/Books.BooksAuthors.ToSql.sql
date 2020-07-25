declare @JSON varchar(max)

select @JSON = BulkColumn
from openrowset 
  (BULK '/home/mahdialikhasi/Downloads/Books/Books.BooksAuthors.json', single_clob) 
as j;

insert into Books.BooksAuthors
select *
from openjson (@JSON)
with (
  id int,
  bookId int,
  authorId int
);
