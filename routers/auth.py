from fastapi import Depends,APIRouter, FastAPI, HTTPException, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from pydantic import BaseModel
from datetime import datetime, timedelta
from jose import JWTError, jwt
from passlib.context import CryptContext
from database import get_connection
from typing import List, Annotated

SECRET_KEY = "c96a1f867fc9cce62fc7d863cf4adc46abc884bb7f465e483887d93ada9b8c8f"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

router = APIRouter(prefix="/auth", tags=["auth"])

bcrypt_context = CryptContext(schemes =['bcrypt'],deprecated = 'auto')
oauth2_bearer = OAuth2PasswordBearer(tokenUrl = 'auth/token')

class CreateUserRequest(BaseModel):
    # user_id: int
    full_name: str
    email: str
    phone: str
    password: str

#fastapi behind the scenes tokens
class Token(BaseModel):
    access_token:str
    token_type: str

@router.post("/", status_code=status.HTTP_201_CREATED)
async def create_user(create_user_request: CreateUserRequest):
    try:
        hashed_password = bcrypt_context.hash(create_user_request.password)
        with get_connection() as conn:
            with conn.cursor() as cur:
                cur.execute("""
                    INSERT INTO booking.users 
                    (full_name, email, phone, password_hash)
                    VALUES (%s, %s, %s, %s)
                """, (
                    # create_user_request.user_id, 
                    create_user_request.full_name, 
                    create_user_request.email, 
                    create_user_request.phone, 
                    hashed_password
                ))
                conn.commit()

        return {"message": "User created successfully"}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
    
@router.post("/token", response_model = Token)
async def login_for_access_token(form_data: Annotated[OAuth2PasswordRequestForm, Depends()]):
    user = authenticate_user(form_data.username, form_data.password)#(email/username, userid)
    if not user:
        raise HTTPException(status_code = status.HTTP_401_UNAUTHORIZED,
                            detail = 'cant validate user qwq')
    token = create_access_token(user[2], user[0], user[5], timedelta(minutes = 20))

    return{'access_token': token, 'token_type': 'bearer'}


def authenticate_user(email: str, password: str):
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute("""
                SELECT user_id, full_name, email, phone, password_hash, role
                FROM booking.users
                WHERE email = %s
            """, (email,))
            user = cur.fetchone()

            if not user:
                return False

            if not bcrypt_context.verify(password, user[4]):
                return False

            return user


def create_access_token(username: str, user_id: int, role: str ,expires_delta: timedelta):
    encode = {'sub': username, 'id': user_id, 'role': role}
    expires = datetime.utcnow() + expires_delta
    encode.update({'exp': expires})
    return jwt.encode(encode, SECRET_KEY, algorithm=ALGORITHM)


async def get_current_user(token: Annotated[str,Depends(oauth2_bearer)]):
    try:
        payload = jwt.decode(token,SECRET_KEY,algorithms = [ALGORITHM])
        username:str = payload.get('sub')
        user_id: int = payload.get('id')
        if username is None or user_id  is None:
            raise HTTPException(status_code = status.HTTP_401_UNAUTHORIZED,
                                detail='couldnt validate user')
        return{'username': username, 'user_id': user_id}
    except JWTError:
        raise HTTPException(status_code = status.HTTP_401_UNAUTHORIZED,
                            detail='couldnt validate the user')

async def get_current_admin(token: Annotated[str, Depends(oauth2_bearer)]):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        role: str = payload.get("role")
        print(role)
        if role != "Admin":
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Admin access required")
        return role
    except JWTError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")
