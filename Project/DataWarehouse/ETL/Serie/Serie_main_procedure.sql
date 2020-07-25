CREATE OR ALTER PROCEDURE "serie_mart" as 
begin
	exec dimension_episode_update;
	exec dimension_serie_genre_update;
	exec dimension_serie_director_update;
	exec fact_serie_genre_update;
	exec fact_serie_rating_update;
	exec fact_serie_transactional_update;
end;