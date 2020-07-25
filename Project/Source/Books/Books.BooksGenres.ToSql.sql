declare @JSON varchar(max)

select @JSON = BulkColumn
from openrowset 
  (BULK '/home/mahdialikhasi/Downloads/Books/Books.BooksGenres.json', single_clob) 
as j;

insert into Books.BooksGenres
select *
from openjson (@JSON)
with (
  id int,
  bookId int,
  genreId int
);
