from fastapi import APIRouter, HTTPException, Depends
from database import get_connection
from pydantic import BaseModel
from datetime import datetime
from typing import Optional, Annotated
from routers import auth
from .auth import get_current_admin

router = APIRouter(prefix="/admin", tags=["Admin"])

@router.get("/dashboard")
async def admin_dashboard(admin: Annotated[dict, Depends(get_current_admin)]):
    #only runs if user.role == 'Admin'
    return {"message": f"Welcome back, Admin {admin.get('sub')}"}

# ---------------------------
# 🎬 ADD MOVIE
# ---------------------------

class MovieRequest(BaseModel):
    title: str
    language: str
    duration_minutes: int
    certification: str
    release_date: datetime
    imdb_rating: Optional[float] = None


@router.post("/movie")
def add_movie(request: MovieRequest):

    with get_connection() as conn:
        with conn.cursor() as cur:

            cur.execute("""
                INSERT INTO booking.movie
                (title, language, duration_minutes, certification,
                 release_date, imdb_rating, is_active)
                VALUES (%s, %s, %s, %s, %s, %s, TRUE)
                RETURNING movie_id
            """, (
                request.title,
                request.language,
                request.duration_minutes,
                request.certification,
                request.release_date,
                request.imdb_rating
            ))

            movie_id = cur.fetchone()[0]
            conn.commit()

    return {"movie_id": movie_id}


# ---------------------------
# 🎥 ADD SHOW (WITH CONFLICT CHECK)
# ---------------------------

class ShowRequest(BaseModel):
    movie_id: int
    screen_id: int
    start_time: datetime
    end_time: datetime


@router.post("/show")
def add_show(request: ShowRequest):

    if request.start_time >= request.end_time:
        raise HTTPException(status_code=400, detail="Invalid show time range")

    with get_connection() as conn:
        with conn.cursor() as cur:

            # 🔒 Screen time conflict validation
            cur.execute("""
                SELECT 1
                FROM booking.shows
                WHERE screen_id = %s
                  AND is_active = TRUE
                  AND start_time < %s
                  AND end_time > %s
            """, (
                request.screen_id,
                request.end_time,
                request.start_time
            ))

            conflict = cur.fetchone()

            if conflict:
                raise HTTPException(
                    status_code=400,
                    detail="Screen already has a show scheduled in this time range"
                )

            # ✅ Insert show
            cur.execute("""
                INSERT INTO booking.shows
                (movie_id, screen_id, start_time, end_time, is_active)
                VALUES (%s, %s, %s, %s, TRUE)
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


# ---------------------------
# 💰 SET / UPDATE SEAT PRICING
# ---------------------------

class SeatPricingRequest(BaseModel):
    show_id: int
    seat_category_id: int
    price: float


@router.post("/show-pricing")
def set_seat_pricing(request: SeatPricingRequest):

    with get_connection() as conn:
        with conn.cursor() as cur:

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

    return {
        "show_id": request.show_id,
        "seat_category_id": request.seat_category_id,
        "price": request.price,
        "status": "UPDATED"
    }


# ---------------------------
# 🧹 CLEANUP EXPIRED BOOKINGS
# ---------------------------

@router.post("/cleanup-expired-bookings")
def cleanup_expired_bookings():

    with get_connection() as conn:
        with conn.cursor() as cur:

            cur.execute("""
                UPDATE booking.booking
                SET status = 'CANCELLED'
                WHERE status = 'PENDING'
                  AND expires_at < NOW()
                RETURNING booking_id
            """)

            expired = cur.fetchall()
            conn.commit()

    return {
        "expired_bookings": [row[0] for row in expired],
        "count": len(expired)
    }


# ---------------------------
# 🎭 ADD THEATRE
# ---------------------------

class TheatreRequest(BaseModel):
    city_id: int
    name: str
    address: str


@router.post("/theatre")
def add_theatre(request: TheatreRequest):

    with get_connection() as conn:
        with conn.cursor() as cur:

            cur.execute("""
                INSERT INTO booking.theatre
                (city_id, name, address, is_active)
                VALUES (%s, %s, %s, TRUE)
                RETURNING theatre_id
            """, (
                request.city_id,
                request.name,
                request.address
            ))

            theatre_id = cur.fetchone()[0]
            conn.commit()

    return {"theatre_id": theatre_id}


# ---------------------------
# 🎬 ADD SCREEN
# ---------------------------

class ScreenRequest(BaseModel):
    theatre_id: int
    screen_no: int
    capacity: int


@router.post("/screen")
def add_screen(request: ScreenRequest):

    with get_connection() as conn:
        with conn.cursor() as cur:

            cur.execute("""
                INSERT INTO booking.screen
                (theatre_id, screen_no, capacity, is_active)
                VALUES (%s, %s, %s, TRUE)
                RETURNING screen_id
            """, (
                request.theatre_id,
                request.screen_no,
                request.capacity
            ))

            screen_id = cur.fetchone()[0]
            conn.commit()

    return {"screen_id": screen_id}

@router.put("/movie/{movie_id}/deactivate")
def deactivate_movie(movie_id: int):

    with get_connection() as conn:
        with conn.cursor() as cur:

            cur.execute("""
                UPDATE booking.movie
                SET is_active = FALSE
                WHERE movie_id = %s
                RETURNING movie_id
            """, (movie_id,))

            result = cur.fetchone()
            conn.commit()

    if not result:
        raise HTTPException(status_code=404, detail="Movie not found")

    return {
        "movie_id": movie_id,
        "status": "DEACTIVATED"
    }
@router.put("/show/{show_id}/deactivate")
def deactivate_show(show_id: int):

    with get_connection() as conn:
        with conn.cursor() as cur:

            cur.execute("""
                UPDATE booking.shows
                SET is_active = FALSE
                WHERE show_id = %s
                RETURNING show_id
            """, (show_id,))

            result = cur.fetchone()
            conn.commit()

    if not result:
        raise HTTPException(status_code=404, detail="Show not found")

    return {
        "show_id": show_id,
        "status": "DEACTIVATED"
    }
@router.put("/theatre/{theatre_id}/deactivate")
def deactivate_theatre(theatre_id: int):

    with get_connection() as conn:
        with conn.cursor() as cur:

            cur.execute("""
                UPDATE booking.theatre
                SET is_active = FALSE
                WHERE theatre_id = %s
                RETURNING theatre_id
            """, (theatre_id,))

            result = cur.fetchone()
            conn.commit()

    if not result:
        raise HTTPException(status_code=404, detail="Theatre not found")

    return {
        "theatre_id": theatre_id,
        "status": "DEACTIVATED"
    }
@router.put("/screen/{screen_id}/deactivate")
def deactivate_screen(screen_id: int):

    with get_connection() as conn:
        with conn.cursor() as cur:

            cur.execute("""
                UPDATE booking.screen
                SET is_active = FALSE
                WHERE screen_id = %s
                RETURNING screen_id
            """, (screen_id,))

            result = cur.fetchone()
            conn.commit()

    if not result:
        raise HTTPException(status_code=404, detail="Screen not found")

    return {
        "screen_id": screen_id,
        "status": "DEACTIVATED"
    }