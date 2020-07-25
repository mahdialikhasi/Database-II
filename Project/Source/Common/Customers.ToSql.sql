declare @JSON varchar(max)

select @JSON = BulkColumn
from openrowset 
  (BULK '/home/mahdialikhasi/Downloads/Common/Customers.json', single_clob) 
as j;

insert into Customers
select id, firstName, lastName, gender, email, phone, convert(date, dateJoined, 103), country
from openjson (@JSON)
with (
  id int,
  firstName varchar(50),
  lastName varchar(50),
  gender varchar(10),
  email varchar(50),
  phone varchar(50),
  dateJoined varchar(max),
  country int
);
