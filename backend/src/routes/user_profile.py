from fastapi import APIRouter, HTTPException
from models.user import User, UserUpdate
from db.user import get_user_by_id, update_user_profile  # Assuming these functions are implemented in the db layer
from bson import ObjectId

router = APIRouter()

# Fetch user profile by user ID
@router.get("/profile/{user_id}", response_model=User)
async def get_user_profile(user_id: str):
    """
    Fetch the user's profile by their user ID.
    """
    result = await get_user_by_id(user_id)
    if result["status"] == "error":
        raise HTTPException(status_code=404, detail="User not found")

    user_data = result["data"]

    # Return the user profile data
    return User(
        name=user_data['name'],
        email=user_data['email'],
        phone=user_data['phone'],
        address=user_data.get('address', ''),
        billingAddress=user_data.get('billingAddress', ''),
        role=user_data['role']
    )

# Update user profile
@router.put("/profile/{user_id}", response_model=User)
async def update_user_profile(user_id: str, user_update: UserUpdate):
    """
    Update the user's profile with new information.
    """
    # Ensure the user exists before attempting to update
    result = await get_user_by_id(user_id)
    if result["status"] == "error":
        raise HTTPException(status_code=404, detail="User not found")

    # Update the user's profile
    update_result = await update_user_profile(user_id, user_update)

    if update_result["status"] == "error":
        raise HTTPException(status_code=400, detail="Failed to update user profile")

    # Return the updated user profile
    updated_user_data = update_result["data"]
    return User(
        name=updated_user_data['name'],
        email=updated_user_data['email'],
        phone=updated_user_data['phone'],
        address=updated_user_data.get('address', ''),
        billingAddress=updated_user_data.get('billingAddress', ''),
        role=updated_user_data['role']
    )
