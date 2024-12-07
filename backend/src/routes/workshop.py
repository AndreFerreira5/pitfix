from fastapi import APIRouter, HTTPException
from db.workshop import get_all_workshops, get_workshop_by_id, insert_workshop, delete_workshop, edit_workshop
from models.workshop import Workshop, WorkshopCreate

router = APIRouter()


# TODO add error checking in these endpoints, right now the code works by expecting the databse to always work as expected


@router.get("/all")
async def get_workshops():
    return await get_all_workshops(), 200


@router.get("/{workshop_id}")
async def get_workshop_route(workshop_id: str):
    result = await get_workshop_by_id(workshop_id)
    if result["status"] == "error":
        raise HTTPException(status_code=404 if "not found" in result["message"].lower() else 500, detail=result["message"])
    return result["data"], 200



@router.post("/add")
async def add_workshop(workshop_data: WorkshopCreate):
    result = await insert_workshop(workshop_data)
    if result["status"] == "error":
        raise HTTPException(status_code=500, detail="Internal Server Error")
    elif result["status"] == "success":
        return result["message"], 201


@router.delete("/delete/{workshop_id}")
async def delete_workshop_route(workshop_id: str):
    result = await delete_workshop(workshop_id)
    if result["status"] == "error":
        raise HTTPException(status_code=404 if "not found" in result["message"].lower() else 500, detail=result["message"])
    return {"message": result["message"]}, 200


@router.put("/edit/{workshop_id}")
async def edit_workshop_route(workshop_id: str, updated_data: WorkshopCreate):
    result = await edit_workshop(workshop_id, updated_data)
    if result["status"] == "error":
        raise HTTPException(status_code=404 if "not found" in result["message"].lower() else 500, detail=result["message"])
    return {"message": result["message"]}, 200
