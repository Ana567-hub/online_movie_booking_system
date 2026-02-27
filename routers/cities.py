from fastapi import APIRouter
from database import get_connection

router = APIRouter(prefix="/cities", tags=["Cities"])

@router.get("/")
def get_cities():
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute("""
                SELECT city_id, name
                FROM booking.city
                WHERE is_active = TRUE
                ORDER BY name;
            """)
            rows = cur.fetchall()

    cities = []
    for row in rows:
        cities.append({
            "city_id": row[0],
            "name": row[1]
        })

    return {"cities": cities}