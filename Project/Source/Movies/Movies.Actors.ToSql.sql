declare @JSON varchar(max)

select @JSON = BulkColumn
from openrowset 
  (BULK '/home/mahdialikhasi/Downloads/Movies/Movies.Actors.json', single_clob) 
as j;

insert into Movies.Actors
select id, name, convert(date, birthdate, 103), description, country
from openjson (@JSON)
with (
  id int,
  name varchar(50),
  birthdate varchar(100),
  description varchar(max),
  country int
);
