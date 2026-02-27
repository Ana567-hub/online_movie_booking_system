from fastapi import APIRouter, Query
from database import get_connection
from typing import Optional

router = APIRouter(prefix="/movies", tags=["Movies"])


@router.get("/")
def get_movies(
    city_id: Optional[int] = Query(None),
    genre_id: Optional[int] = Query(None)
):
    with get_connection() as conn:
        with conn.cursor() as cur:

            base_query = """
                SELECT DISTINCT m.movie_id, m.title, m.language, m.imdb_rating
                FROM booking.movie m
                JOIN booking.show s ON s.movie_id = m.movie_id
                JOIN booking.screen sc ON sc.screen_id = s.screen_id
                JOIN booking.theatre t ON t.theatre_id = sc.theatre_id
                WHERE m.is_active = TRUE
                  AND s.is_active = TRUE
                  AND sc.is_active = TRUE
                  AND t.is_active = TRUE
            """

            params = []

            if city_id is not None:
                base_query += " AND t.city_id = %s"
                params.append(city_id)

            if genre_id is not None:
                base_query += """
                    AND m.movie_id IN (
                        SELECT movie_id
                        FROM booking.movie_genre
                        WHERE genre_id = %s
                    )
                """
                params.append(genre_id)

            base_query += " ORDER BY m.movie_id"

            cur.execute(base_query, tuple(params))
            rows = cur.fetchall()

    movies = []
    for row in rows:
        movies.append({
            "movie_id": row[0],
            "title": row[1],
            "language": row[2],
            "imdb_rating": float(row[3]) if row[3] else None
        })

    return {"movies": movies}
@router.get("/{movie_id}")
def get_movie_details(movie_id: int):
    with get_connection() as conn:
        with conn.cursor() as cur:

            # 1️⃣ Basic movie info
            cur.execute("""
                SELECT movie_id, title, language, duration_minutes,
                       certification, release_date, imdb_rating
                FROM booking.movie
                WHERE movie_id = %s
                AND is_active = TRUE
            """, (movie_id,))
            movie = cur.fetchone()

            if not movie:
                return {"error": "Movie not found"}

            # 2️⃣ Genres
            cur.execute("""
                SELECT g.name
                FROM booking.genre g
                JOIN booking.movie_genre mg
                ON g.genre_id = mg.genre_id
                WHERE mg.movie_id = %s
            """, (movie_id,))
            genres = [row[0] for row in cur.fetchall()]

            # 3️⃣ Cast
            cur.execute("""
                SELECT p.full_name, mp.role
                FROM booking.person p
                JOIN booking.movie_person mp
                ON p.person_id = mp.person_id
                WHERE mp.movie_id = %s
            """, (movie_id,))
            cast = [
                {"name": row[0], "role": row[1]}
                for row in cur.fetchall()
            ]

            # 4️⃣ Average rating
            cur.execute("""
                SELECT AVG(rating), COUNT(*)
                FROM booking.review
                WHERE movie_id = %s
            """, (movie_id,))
            rating_data = cur.fetchone()

    return {
        "movie_id": movie[0],
        "title": movie[1],
        "language": movie[2],
        "duration_minutes": movie[3],
        "certification": movie[4],
        "release_date": movie[5],
        "imdb_rating": float(movie[6]) if movie[6] else None,
        "genres": genres,
        "cast": cast,
        "average_rating": float(rating_data[0]) if rating_data[0] else None,
        "total_reviews": rating_data[1]
    }