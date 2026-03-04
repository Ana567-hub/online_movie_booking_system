import psycopg
import os
from dotenv import load_dotenv, dotenv_values

load_dotenv()

DB_NAME=os.getenv("DB_NAME")
DB_USER=os.getenv("DB_USER")
DB_PASSWORD=os.getenv("DB_PASSWORD")
DB_HOST=os.getenv("DB_HOST")
DB_PORT=os.getenv("DB_PORT") 

print(DB_PORT)

def get_connection():
    return psycopg.connect(
        dbname="recovery",
        user="postgres",
        password="abcd1234",
        host="localhost",
        port="5432"
    )