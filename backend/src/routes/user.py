from fastapi import APIRouter, HTTPException
from db.auth import get_user_by_username, get_user_by_id, update_user_by_username
from models.user import User, UserUpdate
from fastapi.encoders import jsonable_encoder
from fastapi.responses import JSONResponse
from utils.conversions import convert_objectid
import logging

logger = logging.getLogger(__name__)

router = APIRouter()


@router.get("/{username}", response_model=User)
async def get_user_by_username_route(username: str):
    user = await get_user_by_username(username)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # user.pop("_id", None)
    user.pop("password", None)
    user.pop("createdAt", None)
    user.pop("session_nonce", None)
    user["_id"] = convert_objectid(user["_id"])
    if "requests" in user:
        user["requests"] = convert_objectid(user["requests"])

    logger.info("Returned user %s", user["username"])
    return User.parse_obj(user)


@router.get("/{username}/role")
async def get_user_role_by_username_route(username: str):
    user = await get_user_by_username(username)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    logger.info("Returned role from user %s", user["username"])
    if user["role"]:
        return {"role": user["role"]}, 200


@router.get("/{username}/requests")
async def get_user_requests_by_username_route(username: str):
    user = await get_user_by_username(username)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    logger.info("Returned requests from user %s", user["username"])
    if "requests" in user:
        user["requests"] = convert_objectid(user["requests"])
        print(user["requests"])
        return {"requests": user["requests"]}, 200
    else:
        return {"requests": []}, 200


@router.get("/{username}/workshop-id")
async def get_manager_workshop_by_username_route(username: str):
    user = await get_user_by_username(username)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    if "role" in user and user["role"] != "manager":
        raise HTTPException(status_code=400, detail="User is not a manager")

    if "workshop_id" not in user or not user["workshop_id"]:
        raise HTTPException(status_code=404, detail="Manager does not have a workshop ID assigned")

    # Log the request and return the workshopId
    logger.info("Returned workshop ID for manager %s", user["username"])
    return {"workshop_id": convert_objectid(user["workshop_id"])}, 200


@router.put("/update/{username}")
async def update_user_by_username_route(username: str, request: UserUpdate):
    """
    Update user information by username.
    """
    # Fetch the user from the database using username
    user = await get_user_by_username(username)
    print(user)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # Prepare the update data
    update_data = request.dict(exclude_unset=True)

    if not update_data:
        raise HTTPException(status_code=400, detail="No fields provided for update")

    # Perform the update in the database
    update_result = await update_user_by_username(username, update_data)  # Update by MongoDB `_id`

    if update_result["status"] == "fail":
        raise HTTPException(status_code=400, detail=update_result["message"])
    elif update_result["status"] == "error":
        raise HTTPException(status_code=500, detail="Failed to update user")

    # Return a success message
    return {"status": "success", "message": "User updated successfully"}
