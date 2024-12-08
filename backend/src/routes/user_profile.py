from fastapi import APIRouter, HTTPException
from db.auth import get_user_by_username, get_user_by_id, update_user_profile  # Assuming these are the DB functions for user profile
from models.auth import User, UserUpdate  # Assuming you have a User model and UserUpdate for update
from fastapi.encoders import jsonable_encoder
from fastapi.responses import JSONResponse
from bson import ObjectId
import logging

logger = logging.getLogger(__name__)

# Helper function to handle ObjectId conversion to string
def convert_objectid(data):
    if isinstance(data, dict):
        return {k: convert_objectid(v) for k, v in data.items()}
    elif isinstance(data, list):
        return [convert_objectid(i) for i in data]
    elif isinstance(data, ObjectId):
        return str(data)
    else:
        return data


# User profile fetching route
@router.get("/profile", response_model=User)
async def get_user_profile(authorization: str):
    """
    Fetch the user's profile by username extracted from the JWT token.
    """
    token = authorization.split(" ")[1]  # Token sent as "Bearer <token>"

    # Decode the JWT token to get the username
    decoded_token = decode_jwt(token)
    username = decoded_token.get("username")

    if not username:
        raise HTTPException(status_code=404, detail="Username not found in token")

    # Fetch the user by username
    user_result = await get_user_by_username(username)

    if user_result["status"] == "error":
        raise HTTPException(status_code=404, detail="User not found")

    user_data = user_result["data"]
    user_data = jsonable_encoder(convert_objectid(user_data))  # Convert MongoDB ObjectId to string
    return JSONResponse(content=user_data)


# User profile update route
@router.put("/profile", response_model=User)
async def update_user_profile_route(user_update: UserUpdate, authorization: str):
    """
    Update the user's profile using the username (extracted from JWT token).
    """
    token = authorization.split(" ")[1]  # Token sent as "Bearer <token>"

    # Decode the JWT token to get the username
    decoded_token = decode_jwt(token)
    username = decoded_token.get("username")

    if not username:
        raise HTTPException(status_code=404, detail="Username not found in token")

    # Ensure the user exists before attempting to update
    user_result = await get_user_by_username(username)
    if user_result["status"] == "error":
        raise HTTPException(status_code=404, detail="User not found")

    # Perform the update operation
    update_result = await update_user_profile(username, user_update.dict())

    if update_result["status"] == "error":
        raise HTTPException(status_code=400, detail="Failed to update user profile")

    updated_user_data = update_result["data"]
    updated_user_data = jsonable_encoder(convert_objectid(updated_user_data))  # Convert MongoDB ObjectId to string
    return JSONResponse(content=updated_user_data)
