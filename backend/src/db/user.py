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
            {"$pull": {"requests": ObjectId(request_id)}}
        )

        if update_result.modified_count == 1:
            return {"status": "success", "message": "Request removed successfully."}
        else:
            return {"status": "fail", "message": "Request ID not found in user's requests."}

    except Exception as e:
        logger.error(str(e))
        return {"status": "error", "message": str(e)}


async def delete_requests_from_users(request_ids):
    db = await get_db()

    try:
        # Ensure all request_ids are converted to ObjectId
        request_ids_obj = [ObjectId(request_id) for request_id in request_ids]

        # Update all users, removing any of the request IDs from their 'requests' array
        update_result = await db.user.update_many(
            {"requests": {"$in": request_ids_obj}},  # Match users with any of the request IDs
            {"$pull": {"requests": {"$in": request_ids_obj}}}  # Remove the request IDs
        )

        return {
            "status": "success",
            "message": f"Requests removed from {update_result.modified_count} user(s).",
            "modified_count": update_result.modified_count
        }
    except Exception as e:
        logger.error(f"Error removing requests from users: {str(e)}")
        return {"status": "error", "message": str(e)}


async def delete_workshop_from_users(workshop_id):
    db = await get_db()

    try:
        # Update all users who have the specified workshop_id
        update_result = await db.user.update_many(
            {"workshop_id": ObjectId(workshop_id)},  # Match users with this workshop_id
            {"$set": {"workshop_id": None}}  # Set workshop_id to None
        )

        return {
            "status": "success",
            "message": f"Workshop ID removed from {update_result.modified_count} user(s).",
            "modified_count": update_result.modified_count
        }

    except Exception as e:
        logger.error(f"Error removing workshop ID from users: {str(e)}")
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


