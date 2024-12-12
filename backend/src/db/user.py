from .connection import get_db
from datetime import datetime
from bson import ObjectId
import logging
from fastapi.encoders import jsonable_encoder
from utils.conversions import convert_objectid

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


async def get_all_workers_with_workshop_id(workshop_id: str):
    db = await get_db()

    print(workshop_id)
    try:
        workers_cursor = db.user.find({"role": "worker", "workshop_id": ObjectId(workshop_id)})
        workers = await workers_cursor.to_list(length=100)
        print(workers)
        if workers:
            for worker in workers:
                for field in ["password", "createdAt", "session_nonce"]:
                    worker.pop(field, None)

            assistance_requests = jsonable_encoder(convert_objectid(workers))
            return {"status": "success", "data": assistance_requests}
        else:
            return {"status": "error", "message": "Request not found."}
    except Exception as e:
        logger.error(f"Error retrieving assistance requests for workshop {workshop_id}: {str(e)}")
        return {"status": "error", "message": str(e)}

