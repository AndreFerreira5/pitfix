from fastapi import APIRouter, HTTPException
from db.workshop import get_all_workshops, insert_workshop
from models.workshop import WorkshopCreate

router = APIRouter()

# TODO add error checking in these endpoints, right now the code works by expecting the databse to always work as expected


@router.get("/all")
async def get_workshops():
    return await get_all_workshops(), 200


@router.post("/add")
async def add_workshop(workshop_data: WorkshopCreate):
    result = await insert_workshop(workshop_data)
    if result["status"] == "error":
        raise HTTPException(status_code=500, detail="Internal Server Error")
    elif result["status"] == "success":
        return result["message"], 200