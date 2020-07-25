Create SCHEMA Books;
create table Books.Authors (
  id int,
  name varchar(50),
  birthdate date,
  description text,
  countryId int
);

create table Books.Books(
  id int,
  isbn varchar(50),
  title varchar(50),
  publicationDate date,
  edition int,
  description text,
  publisher int,
  salesInfoId int
);

create table Books.BooksAuthors (
  id int,
  bookId int,
  authorId int
);

create table Books.BooksGenres (
  id int,
  bookId int,
  genreId int
);

create table Books.Genres (
  id int,
  name varchar(50)
);

create table Books.Publishers (
  id int,
  name varchar(50),
  description text,
  website varchar(50),
  phone varchar(50),
  city varchar(50),
  street varchar(50),
  countryId int
);

create table Books.Ratings (
  id int,
  rating tinyint,
  description text,
  bookId int,
  customerId int
);

create table Books.Transactions (
  id int,
  date date,
  time time(0),
  price float,
  bookId int,
  customerId int
);

create table SalesInfo (
  id int,
  basePrice float,
  discount smallint
);

create table Customers(
  id int,
  firstName varchar(50),
  lastName varchar(50),
  gender varchar(10),
  email varchar(50),
  phone varchar(50),
  dateJoined date,
  countryId int
);
create table Countries(
  id int IDENTITY(1,1),
  name varchar(100),
  region varchar(100),
  subregion varchar(100),
);
create table Books.Ratings (
  id int,
  date date,
  rating tinyint,
  description text,
  bookId int,
  customerId int
);
create schema Movies;
create table Movies.Ratings(
  id int,
  date date,
  rating tinyint,
  description text,
  movieId int,
  customerId int
);
create table Movies.Transactions (
  id int,
  date date,
  time time(0),
  price float,
  customerId int,
  movieId int
);
create table Movies.ProductionCompanies (
  id int,
  name varchar(50),
  description text,
  website varchar(50),
  phone varchar(50),
  city varchar(50),
  street varchar(50),
  countryId int
);
create table Movies.MoviesGenres(
  id int,
  movieId int,
  genreId int
);
create table Movies.MoviesDirectors(
  id int,
  movieId int,
  directorId int
);
create table Movies.MoviesActors (
  id int,
  movieId int,
  actorId int
);

create table Movies.Movies(
  id int,
  title varchar(50),
  releaseDate date,
  description text,
  productionCompanyId int,
  salesInfoId int
);
create table Movies.Genres(
  id int,
  name varchar(50)
);

create table Movies.Directors (
  id int,
  name varchar(50),
  birthdate date,
  description text,
  countryId int
);
create table Movies.Actors (
  id int,
  name varchar(50),
  birthdate date,
  description text,
  countryId int
);
create schema Series;
create table Series.Series (
  id int,
  title varchar(50),
  description text
);
create table Series.MoviesGenres (
  id int,
  movieId int,
  genreId int
);
create table Series.MoviesDirectors (
  id int,
  movieId int,
  directorId int
);
create table Series.MoviesActors (
  id int,
  actorId int,
  movieId int
);
create table Series.Movies (
  id int,
  title varchar(50),
  releaseDate date,
  description text,
  productionCompanyId int,
  salesInfoId int,
  season smallint,
  serieId int
);
create table Series.Transactions (
  id int,
  date date,
  time time(0),
  price float,
  customerId int,
  movieId int
);
create schema Songs;
create table Songs.Albums (
  id int,
  title varchar(50),
  releaseDate date,
  description text
);
create table Songs.AlbumsArtists (
  id int,
  albumId int,
  artistId int
);
create table Songs.AlbumsGenres (
  id int,
  albumId int,
  genreId int
);
create table Songs.Artists(
  id int,
  name varchar(50),
  birthdate date,
  description text,
  countryId int
);
create table Songs.Genres (
  id int,
  name varchar(50)
);
create table Songs.Ratings (
  id int,
  trackId int,
  rating tinyint,
  description text,
  customerId int,
  date date,
);
create table Songs.Transactions (
  id int,
  date date,
  time time(0),
  price float,
  customerId int,
  trackId int
);
create table Songs.Tracks(
  id int,
  title varchar(50),
  album int,
  salesInfoId int,
  length int
);

