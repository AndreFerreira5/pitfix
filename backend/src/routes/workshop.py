from fastapi import APIRouter, HTTPException
from db.workshop import (
    get_all_workshops,
    get_workshop_by_id,
    get_workshop_by_name,
    # get_workshop_workers,
    insert_workshop,
    delete_workshop_by_id,
    delete_workshop_by_name,
    edit_workshop
)

from db.user import (
    get_all_workers_with_workshop_id,
)

from models.workshop import Workshop, WorkshopCreate

router = APIRouter()


# TODO add error checking in these endpoints, right now the code works by expecting the databse to always work as expected


@router.get("/all")
async def get_workshops():
    return await get_all_workshops(), 200


@router.get("/{workshop_id}/workers")
async def get_workshop_workers_route(workshop_id: str):
    result = await get_all_workers_with_workshop_id(workshop_id)
    if result["status"] == "error":
        raise HTTPException(status_code=404 if "not found" in result["message"].lower() else 500,
                            detail=result["message"])
    return result["data"], 200


@router.get("/id/{workshop_id}")
async def get_workshop_route(workshop_id: str):
    result = await get_workshop_by_id(workshop_id)
    if result["status"] == "error":
        raise HTTPException(status_code=404 if "not found" in result["message"].lower() else 500,
                            detail=result["message"])
    return result["data"], 200


@router.get("/name/{workshop_name}")
async def get_workshop_route(workshop_name: str):
    result = await get_workshop_by_name(workshop_name)
    if result["status"] == "error":
        raise HTTPException(status_code=404 if "not found" in result["message"].lower() else 500,
                            detail=result["message"])
    return result["data"], 200


@router.post("/add")
async def add_workshop(workshop_data: WorkshopCreate):
    existing_workshop = await get_workshop_by_name(workshop_data.name)

    if existing_workshop["status"] == "success":
        raise HTTPException(status_code=400, detail="A workshop with this name already exists.")

    result = await insert_workshop(workshop_data)
    if result["status"] == "error":
        raise HTTPException(status_code=500, detail="Internal Server Error")
    elif result["status"] == "success":
        return result["message"], 201


@router.delete("/delete/id/{workshop_id}")
async def delete_workshop_route(workshop_id: str):
    result = await delete_workshop_by_id(workshop_id)
    if result["status"] == "error":
        raise HTTPException(status_code=404 if "not found" in result["message"].lower() else 500,
                            detail=result["message"])
    return {"message": result["message"]}, 200


@router.delete("/delete/name/{workshop_name}")
async def delete_workshop_by_name_route(workshop_name: str):
    result = await delete_workshop_by_name(workshop_name)
    if result["status"] == "error":
        raise HTTPException(status_code=404 if "not found" in result["message"].lower() else 500,
                            detail=result["message"])
    return {"message": result["message"]}, 200


@router.put("/edit/{workshop_id}")
async def edit_workshop_route(workshop_id: str, updated_data: WorkshopCreate):
    result = await edit_workshop(workshop_id, updated_data)
    if result["status"] == "error":
        raise HTTPException(status_code=404 if "not found" in result["message"].lower() else 500,
                            detail=result["message"])
    return {"message": result["message"]}, 200
