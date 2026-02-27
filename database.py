import psycopg

def get_connection():
    return psycopg.connect(
        dbname="online_movie_booking",
        user="postgres",
        password="OOPSProj@2025",
        host="localhost",
        port="5432"
    )