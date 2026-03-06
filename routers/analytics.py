from fastapi import APIRouter
from database import get_connection

router = APIRouter(prefix="/analytics", tags=["Analytics"])


@router.get("/top-rated")
def top_rated_movies():

    with get_connection() as conn:
        with conn.cursor() as cur:

            cur.execute("""
                SELECT m.movie_id, m.title, AVG(r.rating) AS avg_rating
                FROM booking.movie m
                JOIN booking.review r ON m.movie_id = r.movie_id
                GROUP BY m.movie_id
                ORDER BY avg_rating DESC
                LIMIT 5
            """)

            rows = cur.fetchall()

            return [
                {
                    "movie_id": row[0],
                    "title": row[1],
                    "avg_rating": float(row[2])
                }
                for row in rows
            ]

@router.get("/revenue")
def revenue_per_movie():

    with get_connection() as conn:
        with conn.cursor() as cur:

            cur.execute("""
                SELECT m.title, SUM(p.amount) AS total_revenue
                FROM booking.payment p
                JOIN booking.booking b ON p.booking_id = b.booking_id
                JOIN booking.show s ON b.show_id = s.show_id
                JOIN booking.movie m ON s.movie_id = m.movie_id
                WHERE p.status = 'SUCCESS'
                GROUP BY m.title
                ORDER BY total_revenue DESC
            """)

            rows = cur.fetchall()

            return [
                {
                    "movie": row[0],
                    "revenue": float(row[1])
                }
                for row in rows
            ]
@router.get("/bookings")
def bookings_per_show():

    with get_connection() as conn:
        with conn.cursor() as cur:

            cur.execute("""
                SELECT s.show_id, m.title, COUNT(b.booking_id)
                FROM booking.show s
                JOIN booking.booking b ON s.show_id = b.show_id
                JOIN booking.movie m ON s.movie_id = m.movie_id
                GROUP BY s.show_id, m.title
                ORDER BY COUNT(b.booking_id) DESC
            """)

            rows = cur.fetchall()

            return [
                {
                    "show_id": row[0],
                    "movie": row[1],
                    "total_bookings": row[2]
                }
                for row in rows
            ]