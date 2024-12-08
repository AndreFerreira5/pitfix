from datetime import datetime
from bson import ObjectId
from .connection import get_db

# Get user by ID
async def get_user_by_id(user_id: str):
    db = await get_db()
    user = await db.user.find_one({"_id": ObjectId(user_id)})

    if not user:
        return {"status": "error", "message": "User not found"}

    return {"status": "success", "data": user}

# Update user profile
async def update_user_profile(user_id: str, user_update: dict):
    db = await get_db()

    update_data = {
        "name": user_update['name'],
        "email": user_update['email'],
        "phone": user_update['phone'],
        "address": user_update.get('address', ''),
        "billingAddress": user_update.get('billingAddress', ''),
        "updatedAt": datetime.now()  # Optionally track when the profile was updated
    }

    result = await db.user.update_one({"_id": ObjectId(user_id)}, {"$set": update_data})

    if result.modified_count == 1:
        # Successfully updated
        updated_user = await db.user.find_one({"_id": ObjectId(user_id)})
        return {"status": "success", "data": updated_user}

    return {"status": "error", "message": "Failed to update user profile"}
