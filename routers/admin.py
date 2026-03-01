from fastapi import APIRouter, HTTPException
from database import get_connection
from pydantic import BaseModel

router = APIRouter(prefix="/admin", tags=["Admin"])


class MovieCreate(BaseModel):
    title: str
    duration: int


@router.post("/movie")
def add_movie(request: MovieCreate):

    with get_connection() as conn:
        with conn.cursor() as cur:

            cur.execute("""
                INSERT INTO booking.movie (title, duration)
                VALUES (%s, %s)
                RETURNING movie_id
            """, (request.title, request.duration))

            movie_id = cur.fetchone()[0]
            conn.commit()

            return {"movie_id": movie_id}
        
class ShowCreate(BaseModel):
    movie_id: int
    screen_id: int
    start_time: str
    end_time: str


@router.post("/show")
def add_show(request: ShowCreate):

    with get_connection() as conn:
        with conn.cursor() as cur:

            cur.execute("""
                INSERT INTO booking.shows
                (movie_id, screen_id, start_time, end_time)
                VALUES (%s, %s, %s, %s)
                RETURNING show_id
            """, (
                request.movie_id,
                request.screen_id,
                request.start_time,
                request.end_time
            ))

            show_id = cur.fetchone()[0]
            conn.commit()

            return {"show_id": show_id}