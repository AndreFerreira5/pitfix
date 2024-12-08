from .connection import get_db
from bson import ObjectId
from models.assistance_request import AssistanceRequest, AssistanceRequestCreate
import logging
from fastapi.encoders import jsonable_encoder
from fastapi.responses import JSONResponse

logger = logging.getLogger(__name__)


def convert_objectid(data):
    if isinstance(data, dict):
        return {k: convert_objectid(v) for k, v in data.items()}
    elif isinstance(data, list):
        return [convert_objectid(i) for i in data]
    elif isinstance(data, ObjectId):
        return str(data)
    else:
        return data


async def get_all_assistance_requests():
    db = await get_db()
    try:
        assistance_requests = await db.assistance_request.find().to_list(length=None)
        encoded_requests = jsonable_encoder(convert_objectid(assistance_requests))
        return JSONResponse(content=encoded_requests)
    except Exception as e:
        logger.error(f"Error retrieving assistance requests: {str(e)}")
        return JSONResponse(
            content={"status": "error", "message": str(e)},
            status_code=500
        )


async def insert_assistance_request(request_data: AssistanceRequestCreate):
    db = await get_db()
    request_dict = {k: v for k, v in request_data.dict().items() if v is not None}

    try:
        await db.assistance_request.insert_one(request_dict)
        return {"status": "success", "message": "Assistance request created successfully."}

    except Exception as e:
        logger.error(f"Error creating assistance request: {str(e)}")
        return {"status": "error", "message": str(e)}


async def delete_assistance_request(request_id: str):
    db = await get_db()
    try:
        result = await db.assistance_request.delete_one({"_id": ObjectId(request_id)})
        if result.deleted_count == 1:
            return {"status": "success", "message": "Assistance request deleted successfully."}
        else:
            return {"status": "error", "message": "Assistance request not found."}

    except Exception as e:
        logger.error(f"Error deleting assistance request: {str(e)}")
        return {"status": "error", "message": str(e)}


async def edit_assistance_request(request_id: str, updated_data: AssistanceRequestCreate):
    db = await get_db()
    updated_dict = {k: v for k, v in updated_data.dict().items() if v is not None}

    try:
        result = await db.assistance_request.update_one(
            {"_id": ObjectId(request_id)}, {"$set": updated_dict}
        )
        if result.matched_count == 1:
            return {"status": "success", "message": "Assistance request updated successfully."}
        else:
            return {"status": "error", "message": "Assistance request not found."}

    except Exception as e:
        logger.error(f"Error updating assistance request: {str(e)}")
        return {"status": "error", "message": str(e)}


async def get_assistance_request_by_id(request_id: str):
    db = await get_db()

    try:
        assistance_request = await db.assistance_request.find_one({"_id": ObjectId(request_id)})
        if assistance_request:
            assistance_request = jsonable_encoder(convert_objectid(assistance_request))
            return {"status": "success", "data": assistance_request}
        else:
            return {"status": "error", "message": "Assistance request not found."}

    except Exception as e:
        logger.error(f"Error retrieving assistance request: {str(e)}")
        return {"status": "error", "message": str(e)}


async def get_assistance_requests_by_workshop(workshop_id: str):
    db = await get_db()
    try:
        assistance_requests = await db.assistance_request.find_one({"workshop_id": ObjectId(workshop_id)})
        if assistance_requests:
            assistance_requests = sonable_encoder(convert_objectid(assistance_requests))
            return {"status": "success", "data": assistance_requests}
        else:
            return {"status": "error", "message": "Request not found."}
    except Exception as e:
        logger.error(f"Error retrieving assistance requests for workshop {workshop_id}: {str(e)}")
        return {"status": "error", "message": str(e)}


async def get_assistance_requests_by_worker(worker_id: str):
    db = await get_db()
    try:
        assistance_requests = await db.assistance_request.find_one({"workers_ids": ObjectId(worker_id)})
        if assistance_requests:
            assistance_requests = sonable_encoder(convert_objectid(assistance_requests))
            return {"status": "success", "data": assistance_requests}
        else:
            return {"status": "error", "message": "Request not found."}

    except Exception as e:
        logger.error(f"Error retrieving assistance requests for worker {worker_id}: {str(e)}")
        return {"status": "error", "message": str(e)}
