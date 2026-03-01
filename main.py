from fastapi import FastAPI
from routers import cities, movies

app = FastAPI()

# Include routers
app.include_router(cities.router)
app.include_router(movies.router)
from routers import movie_details

app.include_router(movie_details.router)
from routers import shows
app.include_router(shows.router)

from routers import seats
app.include_router(seats.router)

from routers import booking
app.include_router(booking.router)

from routers import payment
app.include_router(payment.router)

from routers import history
app.include_router(history.router)

from routers import review
app.include_router(review.router)

@app.get("/")
def root():
    return {"message": "Movie Booking Backend Running 🚀"}

