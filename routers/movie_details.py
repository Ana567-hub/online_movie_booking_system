from fastapi import APIRouter, HTTPException
from database import get_connection

router = APIRouter()

@router.get("/movies/{movie_id}")
def get_movie_details(movie_id: int):
    with get_connection() as conn:
        with conn.cursor() as cur:

            # Get movie basic details
            cur.execute("""
                SELECT movie_id, title, language, duration_minutes,
                       certification, release_date
                FROM movie
                WHERE movie_id = %s
            """, (movie_id,))
            movie = cur.fetchone()

            if not movie:
                raise HTTPException(status_code=404, detail="Movie not found")

            # Get genres
            cur.execute("""
                SELECT g.name
                FROM genre g
                JOIN movie_genre mg ON g.genre_id = mg.genre_id
                WHERE mg.movie_id = %s
            """, (movie_id,))
            genres = [row[0] for row in cur.fetchall()]

    return {
        "movie_id": movie[0],
        "title": movie[1],
        "language": movie[2],
        "duration_minutes": movie[3],
        "certification": movie[4],
        "release_date": movie[5],
        "genres": genres
    }