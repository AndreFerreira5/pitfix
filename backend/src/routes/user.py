from fastapi import APIRouter, HTTPException
from db.auth import get_user_by_username, get_user_by_id, \
    update_user_profile  # Assuming these are the DB functions for user profile
from models.auth import User, UserUpdate  # Assuming you have a User model and UserUpdate for update
from fastapi.encoders import jsonable_encoder
from fastapi.responses import JSONResponse
from utils.conversions import convert_objectid
import logging

logger = logging.getLogger(__name__)

router = APIRouter()


@router.get("/{username}", response_model=User)
async def get_user_by_username_route(username: str):
    result = await get_user_by_username(username)
    if result["status"] == "error":
        raise HTTPException(status_code=404, detail="User not found")

    user_data = result["data"]

    return User(
        name=user_data['name'],
        email=user_data['email'],
        phone=user_data['phone'],
        address=user_data['address']
    )


@router.put("/{username}", response_model=User)
async def update_user_by_username(username: str, user_update: UserUpdate):
    # Ensure the user exists before attempting to update
    result = await get_user_by_username(username)
    if result["status"] == "error":
        raise HTTPException(status_code=404, detail="User not found")

    # Update the user's profile (handle password separately in real-world scenarios)
    update_result = await update_user_profile(username, user_update)

    if update_result["status"] == "error":
        raise HTTPException(status_code=400, detail="Failed to update user profile")

    updated_user_data = update_result["data"]

    # Return updated user profile without password
    return User(
        name=updated_user_data['name'],
        email=updated_user_data['email'],
        phone=updated_user_data['phone'],
        address=updated_user_data['address']
    )
