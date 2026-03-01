from fastapi import APIRouter, HTTPException
from database import get_connection
from pydantic import BaseModel

router = APIRouter()


class ReviewRequest(BaseModel):
    user_id: int
    movie_id: int
    rating: int
    comment: str | None = None


# ⭐ Add Review
@router.post("/review")
def add_review(request: ReviewRequest):

    if request.rating < 1 or request.rating > 5:
        raise HTTPException(status_code=400, detail="Rating must be between 1 and 5")

    with get_connection() as conn:
        try:
            with conn.cursor() as cur:

                cur.execute("""
                    INSERT INTO booking.review (movie_id, user_id, rating, comment)
                    VALUES (%s, %s, %s, %s)
                """, (
                    request.movie_id,
                    request.user_id,
                    request.rating,
                    request.comment
                ))

                conn.commit()

                return {"message": "Review added successfully"}

        except Exception as e:
            conn.rollback()
            raise HTTPException(status_code=400, detail=str(e))


# ⭐ Get Reviews for Movie
@router.get("/reviews/{movie_id}")
def get_reviews(movie_id: int):

    with get_connection() as conn:
        with conn.cursor() as cur:

            cur.execute("""
                SELECT u.full_name, r.rating, r.comment
                FROM booking.review r
                JOIN booking.users u ON r.user_id = u.user_id
                WHERE r.movie_id = %s
            """, (movie_id,))

            rows = cur.fetchall()

            result = []
            for row in rows:
                result.append({
                    "user": row[0],
                    "rating": row[1],
                    "comment": row[2]
                })

            return result