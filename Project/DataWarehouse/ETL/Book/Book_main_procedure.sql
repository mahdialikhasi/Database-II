CREATE OR ALTER PROCEDURE "book_mart" as 
begin
	exec dimension_customer_update;
	exec dimension_book_update;
	exec dimension_book_genre_update;
	exec dimension_book_author_update;
	exec fact_book_genre_update;
	exec fact_book_author_update;
	exec fact_book_rating_update;
	exec fact_book_transactional_update;
end;