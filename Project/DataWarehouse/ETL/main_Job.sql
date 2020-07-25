CREATE OR ALTER PROCEDURE "job" as 
begin
	exec book_mart;
	exec customer_mart;
	exec movie_mart;
	exec serie_mart;
	exec song_mart;
end;