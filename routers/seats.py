from fastapi import APIRouter
from database import get_connection

router = APIRouter()

@router.get("/seats/{show_id}")
def get_seats(show_id: int):
    with get_connection() as conn:
        with conn.cursor() as cur:

            cur.execute("""
    SELECT 
        s.seat_id,
        s.row_label,
        s.seat_no,
        sc.name AS seat_category,
        sp.price,
        CASE 
            WHEN bs.seat_id IS NULL THEN 'available'
            ELSE 'booked'
        END AS availability
    FROM booking.seat s
    JOIN booking.shows sh 
        ON sh.screen_id = s.screen_id
    JOIN booking.seat_category sc
        ON sc.seat_category_id = s.seat_category_id
    LEFT JOIN booking.booked_seat bs 
        ON bs.seat_id = s.seat_id 
        AND bs.show_id = %s
    LEFT JOIN booking.show_seat_pricing sp
        ON sp.show_id = %s
        AND sp.seat_category_id = s.seat_category_id
    WHERE sh.show_id = %s
    ORDER BY s.row_label, s.seat_no
""", (show_id, show_id, show_id))

            rows = cur.fetchall()

    result = []
    for row in rows:
        result.append({
            "seat_id": row[0],
            "row": row[1],
            "number": row[2],
            "seat_category": row[3],
            "price": row[4],
            "availability": row[5]
        })

    return result