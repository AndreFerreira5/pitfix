from .connection import get_db
from bson import ObjectId
from models.workshop import WorkshopCreate
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


# TODO get, update and delete workshops
