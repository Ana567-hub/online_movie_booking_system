from fastapi import FastAPI
import uvicorn
from routers import cities, movies,auth
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

origins = [
    "http://localhost:5173",
]


app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"]
)


app.include_router(auth.router)
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

from routers import analytics
app.include_router(analytics.router)

from routers import admin
app.include_router(admin.router)

@app.get("/")
def root():
    return {"message": "Movie Booking Backend Running 🚀"}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port = 8000)