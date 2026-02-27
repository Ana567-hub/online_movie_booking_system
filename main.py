from fastapi import FastAPI
from routers import cities, movies

app = FastAPI()

# Include routers
app.include_router(cities.router)
app.include_router(movies.router)

@app.get("/")
def root():
    return {"message": "Movie Booking Backend Running 🚀"}

