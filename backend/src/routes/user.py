from fastapi import APIRouter, HTTPException
from db.auth import get_user_by_username, get_user_by_id
from models.auth import User
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

    return User(
        name=user['name'],
        role=user['role'],
        email=user['email'],
        phone=user['phone'],
        address=user['address']
    )


@router.get("/{username}/role")
async def get_user_role_by_username_route(username: str):
    user = await get_user_by_username(username)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    if user["role"]:
        return {"role": user["role"]}, 200

