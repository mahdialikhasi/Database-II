CREATE OR ALTER PROCEDURE "song_mart" as 
begin
	exec dimension_track_update;
	exec dimension_album_genre_update;
	exec dimension_track_artist_update;
	exec fact_album_genre_update;
	exec fact_track_rating_update;
	exec fact_track_transactional_update;
end;