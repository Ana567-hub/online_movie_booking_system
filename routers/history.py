from fastapi import APIRouter, Depends, HTTPException
from database import get_connection
from .auth import get_current_user
from typing import Annotated
router = APIRouter()


@router.get("/history/{user_id}")
def get_booking_history(user: Annotated[dict, Depends(get_current_user)]):
    user_id = user.get('id')
    with get_connection() as conn:
        try:
            with conn.cursor() as cur:

                cur.execute("""
                    SELECT 
                        b.booking_id,
                        m.title,
                        t.name AS theatre_name,
                        s.start_time,
                        b.total_amount,
                        b.status,
                        b.booked_date
                    FROM booking.booking b
                    JOIN booking.shows s ON b.show_id = s.show_id
                    JOIN booking.movie m ON s.movie_id = m.movie_id
                    JOIN booking.screen sc ON s.screen_id = sc.screen_id
                    JOIN booking.theatre t ON sc.theatre_id = t.theatre_id
                    WHERE b.user_id = %s
                    ORDER BY b.booked_date DESC
                """, (user_id,))

                bookings = cur.fetchall()

                result = []

                for row in bookings:
                    result.append({
                        "booking_id": row[0],
                        "movie": row[1],
                        "theatre": row[2],
                        "show_time": row[3],
                        "amount": row[4],
                        "status": row[5],
                        "booked_at": row[6]
                    })

                return result

        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))