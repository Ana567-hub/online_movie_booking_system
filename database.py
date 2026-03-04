import psycopg

def get_connection():
    return psycopg.connect(
        dbname="recovery",
        user="postgres",
        password="abcd1234",
        host="localhost",
        port="5432"
    )