from .connection import get_db
from datetime import datetime
from bson import ObjectId
import logging

logger = logging.getLogger(__name__)


async def insert_request_in_user(username: str, request_id: str):
    db = await get_db()

    try:
        user = await db.user.find_one({"username": username})

        if user and request_id not in user.get("requests", []):
            update_result = await db.user.update_one(
                {"username": username},
                {"$push": {"requests": ObjectId(request_id)}}
            )

            if update_result.modified_count == 1:
                return {"status": "success"}
            else:
                return {"status": "fail"}
        else:
            return {"status": "already_exists", "message": "Request ID already exists in the list."}

    except Exception as e:
        logger.error(str(e))
        return {"status": "error", "message": str(e)}


async def delete_request_from_user(username: str, request_id: str):
    db = await get_db()

    try:
        update_result = await db.user.update_one(
            {"username": username},
            {"$pull": {"requests": request_id}}
        )

        if update_result.modified_count == 1:
            return {"status": "success", "message": "Request removed successfully."}
        else:
            return {"status": "fail", "message": "Request ID not found in user's requests."}

    except Exception as e:
        logger.error(str(e))
        return {"status": "error", "message": str(e)}

