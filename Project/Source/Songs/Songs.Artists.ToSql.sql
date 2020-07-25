declare @JSON varchar(max)

select @JSON = BulkColumn
from openrowset 
  (BULK '/home/mahdialikhasi/Downloads/Songs/Songs.Artists.json', single_clob) 
as j;

insert into Songs.Artists
select id, name, convert(date, birthdate, 103), description, countryId
from openjson (@JSON)
with (
  id int,
  name varchar(50),
  birthdate varchar(100),
  description varchar(max),
  countryId int
);
