from fastapi import APIRouter, Depends, HTTPException
from database import get_connection
from pydantic import BaseModel
from typing import List, Annotated
from datetime import datetime, timedelta
from .auth import get_current_user

router = APIRouter()

# -------- Request Model --------
class BookingRequest(BaseModel):
    # user_id: int
    show_id: int
    seat_ids: List[int]

# -------- Booking Endpoint -------
@router.post("/booking")
def create_booking(request: BookingRequest, user: Annotated[dict, Depends(get_current_user)]):
    
    user_id = user.get('id')
    show_id = request.show_id
    seat_ids = request.seat_ids

    if not seat_ids:
        raise HTTPException(status_code=400, detail="No seats selected")

    with get_connection() as conn:
        try:
            with conn.cursor() as cur:

                # 🔒 Check if seats already booked
                cur.execute("""
                            SELECT bs.seat_id
                            FROM booking.booked_seat bs
                            JOIN booking.booking b 
                            ON b.booking_id = bs.booking_id
                            WHERE bs.show_id = %s
                            AND bs.seat_id = ANY(%s)
                            AND b.status IN ('PENDING', 'CONFIRMED')
                            FOR UPDATE
                            """, (show_id, seat_ids))

                already_booked = cur.fetchall()

                if already_booked:
                    raise HTTPException(
                        status_code=400,
                        detail="One or more seats already booked"
                    )

                # 💰 Calculate total price
                cur.execute("""
                    SELECT SUM(sp.price)
                    FROM booking.seat s
                    JOIN booking.show_seat_pricing sp
                        ON sp.show_id = %s
                        AND sp.seat_category_id = s.seat_category_id
                    WHERE s.seat_id = ANY(%s)
                """, (show_id, seat_ids))

                total_amount = cur.fetchone()[0]

                if total_amount is None:
                    raise HTTPException(
                        status_code=400,
                        detail="Invalid seat selection"
                    )

                # 📝 Insert booking
                cur.execute("""
                    INSERT INTO booking.booking
                        (user_id, show_id, booked_date, status, total_amount,expires_at)
                    VALUES (%s, %s, %s, %s, %s,%s)
                    RETURNING booking_id
                """, (
                    user_id,
                    show_id,
                    datetime.now(),
                    "PENDING",
                    total_amount,
                    datetime.now() + timedelta(minutes=10)  # Booking expires in 15 mins
                ))

                booking_id = cur.fetchone()[0]

                # 🎟 Insert booked seats
                for seat_id in seat_ids:
                    cur.execute("""
                        INSERT INTO booking.booked_seat
                            (booking_id, seat_id, show_id, price_at_booking)
                        VALUES (
                            %s,
                            %s,
                            %s,
                            (
                                SELECT sp.price
                                FROM booking.show_seat_pricing sp
                                JOIN booking.seat s
                                    ON s.seat_category_id = sp.seat_category_id
                                WHERE sp.show_id = %s
                                AND s.seat_id = %s
                            )
                        )
                    """, (
                        booking_id,
                        seat_id,
                        show_id,
                        show_id,
                        seat_id
                    ))

                conn.commit()

                return {
                    "booking_id": booking_id,
                    "total_amount": total_amount,
                    "status": "PENDING"
                }

        except HTTPException:
            conn.rollback()
            raise
        except Exception as e:
            conn.rollback()
            raise HTTPException(status_code=500, detail=str(e))



@router.post("/cancel/{booking_id}")
def cancel_booking(booking_id: int, user: Annotated[dict, Depends(get_current_user)]):
    user_id = user.get('id')
    with get_connection() as conn:
        try:
            with conn.cursor() as cur:

                # 1️⃣ Get booking info
                cur.execute("""
                    SELECT status, show_id,user_id
                    FROM booking.booking
                    WHERE booking_id = %s
                """, (booking_id,))

                booking = cur.fetchone()

                if not booking:
                    raise HTTPException(status_code=404, detail="Booking not found")

                status, show_id, owner_id = booking

                #person who books can only cancel no one else
                if owner_id != user_id:
                    raise HTTPException(status_code=403, detail="You don't have permission to cancel this booking")
                if status == "CANCELLED":
                    raise HTTPException(status_code=400, detail="Already cancelled")

                # 2️⃣ Check show start time
                cur.execute("""
                    SELECT start_time
                    FROM booking.shows
                    WHERE show_id = %s
                """, (show_id,))

                show_time = cur.fetchone()[0]

                if show_time <= datetime.now():
                    raise HTTPException(
                        status_code=400,
                        detail="Cannot cancel after show has started"
                    )

                # 3️⃣ If CONFIRMED → mark payment refunded
                if status == "CONFIRMED":
                        cur.execute("""
                             UPDATE booking.payment
                                SET status = 'REFUNDED'
                                WHERE booking_id = %s
                                AND status = 'SUCCESS'
                                """, (booking_id,))

                # 4️⃣ Cancel booking
                cur.execute("""
                    UPDATE booking.booking
                    SET status = 'CANCELLED'
                    WHERE booking_id = %s
                """, (booking_id,))

                conn.commit()

                return {
                    "booking_id": booking_id,
                    "status": "CANCELLED",
                    "refund": "YES" if status == "CONFIRMED" else "NO"
                }

        except HTTPException:
            conn.rollback()
            raise
        except Exception as e:
            conn.rollback()
            raise HTTPException(status_code=500, detail=str(e))