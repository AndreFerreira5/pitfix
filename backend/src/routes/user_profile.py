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
@router.get("/profile/{username}", response_model=User)
async def get_user_profile(username: str):
    """
    Fetch the user's profile by username.
    """
    result = await get_user_by_username(username)
    if result["status"] == "error":
        raise HTTPException(status_code=404, detail="User not found")

    user_data = result["data"]

    # Return user profile without password
    return User(
        name=user_data['name'],
        email=user_data['email'],
        phone=user_data['phone'],
        address=user_data['address'],
        billingAddress=user_data.get('billingAddress', '')  # Optional
    )



# User profile update route
@router.put("/profile/{username}", response_model=User)
async def update_user_profile(username: str, user_update: UserUpdate):
    """
    Update the user's profile using the username.
    """
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
        address=updated_user_data['address'],
        billingAddress=updated_user_data.get('billingAddress', '')  # Optional
    )

