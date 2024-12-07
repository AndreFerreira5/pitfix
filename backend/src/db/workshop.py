from .connection import get_db
from bson import ObjectId
from models.workshop import Workshop, WorkshopCreate
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


async def get_all_workshops():
    db = await get_db()
    workshops = await db.workshop.find().to_list(length=None)
    encoded_workshops = jsonable_encoder(convert_objectid(workshops))
    return JSONResponse(content=encoded_workshops)


async def insert_workshop(workshop_data: WorkshopCreate):
    db = await get_db()
    workshop_dict = {k: v for k, v in workshop_data.dict().items() if v is not None}

    try:
        await db.workshop.insert_one(workshop_dict)
        return {"status": "success", "message": "Workshops created successfully."}

    except Exception as e:
        logger.error(str(e))
        return {"status": "error", "message": str(e)}


async def delete_workshop(workshop_id: str):
    db = await get_db()
    try:
        result = await db.workshop.delete_one({"_id": ObjectId(workshop_id)})
        if result.deleted_count == 1:
            return {"status": "success", "message": "Workshop deleted successfully."}
        else:
            return {"status": "error", "message": "Workshop not found."}

    except Exception as e:
        logger.error(str(e))
        return {"status": "error", "message": str(e)}


async def edit_workshop(workshop_id: str, updated_data: WorkshopCreate):
    db = await get_db()
    updated_dict = {k: v for k, v in updated_data.dict().items() if v is not None}

    try:
        result = await db.workshop.update_one(
            {"_id": ObjectId(workshop_id)}, {"$set": updated_dict}
        )
        if result.matched_count == 1:
            return {"status": "success", "message": "Workshop updated successfully."}
        else:
            return {"status": "error", "message": "Workshop not found."}

    except Exception as e:
        logger.error(f"Error updating workshop: {str(e)}")
        return {"status": "error", "message": str(e)}


async def get_workshop_by_id(workshop_id: str):
    db = await get_db()

    try:
        workshop = await db.workshop.find_one({"_id": ObjectId(workshop_id)})
        if workshop:
            workshop = jsonable_encoder(convert_objectid(workshop))
            return {"status": "success", "data": workshop}
        else:
            return {"status": "error", "message": "Workshop not found."}

    except Exception as e:
        logger.error(f"Error retrieving workshop: {str(e)}")
        return {"status": "error", "message": str(e)}

