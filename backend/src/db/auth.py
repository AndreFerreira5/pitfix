from .connection import get_db
from datetime import datetime
from argon2 import PasswordHasher
from argon2.exceptions import VerifyMismatchError
from bson import ObjectId
import logging

password_hasher = PasswordHasher()
logger = logging.getLogger(__name__)


async def get_user_by_username(username: str):
    db = await get_db()
    return await db.user.find_one({"username": username})


async def get_user_by_id(id: str):
    db = await get_db()
    return await db.user.find_one({"_id": ObjectId(id)})


async def get_user_by_email(email: str):
    db = await get_db()
    return await db.user.find_one({"email": email})


async def insert_user(username: str, password: str, email: str):
    db = await get_db()

    existing_user = await get_user_by_username(username)
    if existing_user:
        return {"status": "fail", "message": "Username already exists."}

    existing_user = await get_user_by_email(email)
    if existing_user:
        return {"status": "fail", "message": "Email already registered."}

    try:
        hashed_password = password_hasher.hash(password)
        await db.user.insert_one({
            "username": username,
            "password": hashed_password,
            "email": email,
            "createdAt": datetime.now()
        })
        return {"status": "success", "message": "User created successfully."}

    except Exception as e:
        logger.error(str(e))
        return {"status": "error", "message": str(e)}


async def verify_password(hashed_password: str, provided_password: str):
    try:
        password_hasher.verify(hashed_password, provided_password)
        return {"status": "success"}

    except VerifyMismatchError:
        return {"status": "fail", "message": "Invalid username or password."}

    except Exception as e:
        return {"status": "error", "message": str(e)}


async def update_user_session_nonce(user_id: ObjectId, session_nonce: str):
    db = await get_db()

    try:
        update_result = await db.user.update_one({"_id": user_id}, {"$set": {"session_nonce": session_nonce}})

        if update_result.modified_count == 1:
            return {"status": "success"}
        else:
            return {"status": "fail"}

    except Exception as e:
        logger.error(str(e))
        return {"status": "error", "message": str(e)}
