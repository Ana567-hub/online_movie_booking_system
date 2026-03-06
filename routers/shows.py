from fastapi import APIRouter
from database import get_connection
from datetime import date

router = APIRouter()

@router.get("/shows/")
def get_shows(
    movie_id: int,
    city_id: int,
    show_date: date
):
    with get_connection() as conn:
        with conn.cursor() as cur:

            cur.execute("""
                    SELECT 
                         s.show_id,
                         s.start_time,
                         s.end_time,
                         t.theatre_id,
                         t.name AS theatre_name,
                         sc.screen_id,
                         sc.name AS screen_name
            FROM booking.show s
            JOIN booking.screen sc ON s.screen_id = sc.screen_id
            JOIN booking.theatre t ON sc.theatre_id = t.theatre_id
            WHERE s.movie_id = %s
            AND t.city_id = %s
            AND s.start_time::date = %s
            ORDER BY s.start_time
        """, (movie_id, city_id, show_date))

            rows = cur.fetchall()

    result = []
    for row in rows:
        result.append({
            "show_id": row[0],
            "start_time": row[1],
            "end_time": row[2],
            "theatre_id": row[3],
            "theatre_name": row[4],
            "screen_id": row[5],
            "screen_name": row[6]
            
        })

    return result