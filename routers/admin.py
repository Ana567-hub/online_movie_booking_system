from fastapi import APIRouter, HTTPException
from database import get_connection
from pydantic import BaseModel
from datetime import datetime

router = APIRouter(prefix="/admin", tags=["Admin"])


# -------------------------------
# 🎬 CREATE MOVIE
# -------------------------------

class MovieCreate(BaseModel):
    title: str
    duration: int


@router.post("/movie")
def add_movie(request: MovieCreate):

    with get_connection() as conn:
        with conn.cursor() as cur:

            cur.execute("""
                INSERT INTO booking.movie (title, duration_minutes, is_active)
                VALUES (%s, %s, TRUE)
                RETURNING movie_id
            """, (request.title, request.duration))

            movie_id = cur.fetchone()[0]
            conn.commit()

            return {"movie_id": movie_id}


# -------------------------------
# 🎭 CREATE SHOW (WITH VALIDATION)
# -------------------------------

class ShowCreate(BaseModel):
    movie_id: int
    theatre_id: int
    screen_id: int
    start_time: datetime
    end_time: datetime
    base_price: float


@router.post("/show")
def add_show(request: ShowCreate):

    if request.end_time <= request.start_time:
        raise HTTPException(status_code=400, detail="End time must be after start time")

    with get_connection() as conn:
        with conn.cursor() as cur:

            # Check movie exists
            cur.execute("SELECT 1 FROM booking.movie WHERE movie_id = %s",
                        (request.movie_id,))
            if not cur.fetchone():
                raise HTTPException(status_code=404, detail="Movie not found")

            # Check screen exists and belongs to theatre
            cur.execute("""
                SELECT theatre_id 
                FROM booking.screen 
                WHERE screen_id = %s
            """, (request.screen_id,))
            result = cur.fetchone()

            if not result:
                raise HTTPException(status_code=404, detail="Screen not found")

            if result[0] != request.theatre_id:
                raise HTTPException(
                    status_code=400,
                    detail="Screen does not belong to this theatre"
                )

            # Insert show
            cur.execute("""
                INSERT INTO booking.shows
                (movie_id, screen_id, start_time, end_time, base_price, status, is_active)
                VALUES (%s, %s, %s, %s, %s, 'Scheduled', TRUE)
                RETURNING show_id
            """, (
                request.movie_id,
                request.screen_id,
                request.start_time,
                request.end_time,
                request.base_price
            ))

            show_id = cur.fetchone()[0]
            conn.commit()

            return {"show_id": show_id}


# -------------------------------
# 💺 SET SEAT PRICING
# -------------------------------

class SeatPricingCreate(BaseModel):
    show_id: int
    seat_category_id: int
    price: float


@router.post("/seat-pricing")
def set_seat_pricing(request: SeatPricingCreate):

    if request.price <= 0:
        raise HTTPException(status_code=400, detail="Price must be positive")

    with get_connection() as conn:
        with conn.cursor() as cur:

            # Check show exists
            cur.execute("SELECT 1 FROM booking.shows WHERE show_id = %s",
                        (request.show_id,))
            if not cur.fetchone():
                raise HTTPException(status_code=404, detail="Show not found")

            # Check seat category exists
            cur.execute("""
                SELECT 1 FROM booking.seat_category
                WHERE seat_category_id = %s
            """, (request.seat_category_id,))
            if not cur.fetchone():
                raise HTTPException(status_code=404, detail="Seat category not found")

            # Insert pricing
            cur.execute("""
                INSERT INTO booking.show_seat_pricing
                (show_id, seat_category_id, price)
                VALUES (%s, %s, %s)
                ON CONFLICT (show_id, seat_category_id)
                DO UPDATE SET price = EXCLUDED.price
            """, (
                request.show_id,
                request.seat_category_id,
                request.price
            ))

            conn.commit()

            return {"message": "Seat pricing added successfully"}