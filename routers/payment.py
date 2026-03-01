from fastapi import APIRouter, HTTPException
from database import get_connection
from pydantic import BaseModel
from datetime import datetime

router = APIRouter()


class PaymentRequest(BaseModel):
    booking_id: int
    payment_method_id: int


@router.post("/payment")
def make_payment(request: PaymentRequest):

    booking_id = request.booking_id
    payment_method_id = request.payment_method_id

    with get_connection() as conn:
        try:
            with conn.cursor() as cur:

                # 🔎 Check booking exists
                cur.execute("""
                    SELECT total_amount, status, expires_at
                    FROM booking.booking
                    WHERE booking_id = %s
                """, (booking_id,))

                booking = cur.fetchone()

                if not booking:
                    raise HTTPException(status_code=404, detail="Booking not found")

                total_amount, status, expires_at = booking

                # 🔥 EXPIRY CHECK (FIXED INDENTATION)
                if status == "PENDING" and expires_at and expires_at < datetime.now():
                    cur.execute("""
                        UPDATE booking.booking
                        SET status = 'CANCELLED'
                        WHERE booking_id = %s
                    """, (booking_id,))
                    conn.commit()
                    raise HTTPException(status_code=400, detail="Booking expired")

                # 🚫 If already processed
                if status != "PENDING":
                    raise HTTPException(
                        status_code=400,
                        detail="Booking already processed"
                    )

                # 💳 Insert payment record
                cur.execute("""
                    INSERT INTO booking.payment
                        (booking_id, payment_method_id, amount, status, paid_at)
                    VALUES (%s, %s, %s, %s, %s)
                """, (
                    booking_id,
                    payment_method_id,
                    total_amount,
                    "SUCCESS",
                    datetime.now()
                ))

                # ✅ Update booking status
                cur.execute("""
                    UPDATE booking.booking
                    SET status = %s
                    WHERE booking_id = %s
                """, ("CONFIRMED", booking_id))

                conn.commit()

                return {
                    "booking_id": booking_id,
                    "payment_status": "SUCCESS",
                    "booking_status": "CONFIRMED"
                }

        except HTTPException:
            conn.rollback()
            raise
        except Exception as e:
            conn.rollback()
            raise HTTPException(status_code=500, detail=str(e))