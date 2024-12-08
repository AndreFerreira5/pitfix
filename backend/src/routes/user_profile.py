from fastapi import FastAPI, HTTPException, Depends
from pydantic import BaseModel
from typing import Optional
import jwt
from datetime import datetime
from bson import ObjectId
from .connection import get_db

# Secret key for JWT decoding
SECRET_KEY = "your_secret_key"

# Function to decode the JWT token and get the username
def decode_jwt(token: str) -> dict:
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=["HS256"])
        return payload
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token has expired")
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Invalid token")

# User model
class User(BaseModel):
    name: str
    email: str
    phone: str
    address: str
    billingAddress: Optional[str] = None
    password: str

    class Config:
        orm_mode = True  # To support MongoDB ObjectId mapping

# Fetch user by username from database
async def get_user_by_username(username: str):
    db = await get_db()
    user = await db.user.find_one({"username": username})

    if not user:
        return {"status": "error", "message": "User not found"}

    return {"status": "success", "data": user}

# Route to fetch user profile by username (extracted from JWT token)
@router.get("/profile", response_model=User)
async def get_user_profile(authorization: str = Depends(oauth2_scheme)):
    """
    Fetch the user's profile by username (extracted from the JWT token).
    """
    token = authorization.split(" ")[1]  # Token sent as "Bearer <token>"
    decoded_token = decode_jwt(token)
    username = decoded_token.get("username")

    if not username:
        raise HTTPException(status_code=404, detail="Username not found in token")

    result = await get_user_by_username(username)  # Fetch user by username from DB
    if result["status"] == "error":
        raise HTTPException(status_code=404, detail="User not found")

    user_data = result["data"]
    return User(
        name=user_data['name'],
        email=user_data['email'],
        phone=user_data['phone'],
        address=user_data['address'],
        billingAddress=user_data.get('billingAddress', ''),
        password=user_data['password'],
    )

# Route to update user profile by username (using the token)
@router.put("/profile", response_model=User)
async def update_user_profile(user_update: UserUpdate, authorization: str = Depends(oauth2_scheme)):
    """
    Update the user's profile using the username (from token).
    """
    token = authorization.split(" ")[1]
    decoded_token = decode_jwt(token)
    username = decoded_token.get("username")

    if not username:
        raise HTTPException(status_code=404, detail="Username not found in token")

    # Ensure the user exists before attempting to update
    result = await get_user_by_username(username)
    if result["status"] == "error":
        raise HTTPException(status_code=404, detail="User not found")

    # Update the user's profile
    update_result = await update_user_profile(username, user_update)

    if update_result["status"] == "error":
        raise HTTPException(status_code=400, detail="Failed to update user profile")

    updated_user_data = update_result["data"]
    return User(
        name=updated_user_data['name'],
        email=updated_user_data['email'],
        phone=updated_user_data['phone'],
        address=updated_user_data['address'],
        billingAddress=updated_user_data.get('billingAddress', ''),
        password=updated_user_data['password'],
    )
