CREATE OR ALTER PROCEDURE "movie_mart" as 
begin
	exec dimension_movie_update;
	exec dimension_movie_genre_update;
	exec dimension_movie_director_update;
	exec fact_movie_genre_update;
	exec fact_movie_rating_update;
	exec fact_movie_transactional_update;
	exec fact_movie_daily_update;
end;