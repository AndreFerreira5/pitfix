from fastapi import APIRouter, HTTPException
from typing import List
from models.assistance_request import AssistanceRequest, AssistanceRequestCreate
from bson import ObjectId

from db.assistance_request import (
    get_all_assistance_requests,
    insert_assistance_request,
    delete_assistance_request,
    edit_assistance_request,
    get_assistance_request_by_id,
    get_assistance_requests_by_workshop,
    get_assistance_requests_by_worker
)

router = APIRouter()


@router.get("/all")
async def route_get_all_assistance_requests():
    return await get_all_assistance_requests(), 200


@router.get("/{request_id}")
async def route_get_assistance_request_by_id(request_id: str):
    result = await get_assistance_request_by_id(request_id)
    if result["status"] == "error":
        raise HTTPException(status_code=404 if "not found" in result["message"].lower() else 500, detail=result["message"])
    return result["data"], 200


@router.get("/workshop/{workshop_id}")
async def route_get_requests_by_workshop(workshop_id: str):
    result = await get_assistance_requests_by_workshop(workshop_id)
    if result["status"] == "error":
        raise HTTPException(status_code=404 if "not found" in result["message"].lower() else 500, detail=result["message"])
    return result["data"], 200


@router.get("/worker/{worker_id}")
async def route_get_requests_by_worker(worker_id: str):
    result = await get_assistance_requests_by_worker(worker_id)
    if result["status"] == "error":
        raise HTTPException(status_code=404 if "not found" in result["message"].lower() else 500, detail=result["message"])
    return result["data"], 200


@router.post("/add")
async def route_create_assistance_request(request_data: AssistanceRequestCreate):
    result = await insert_assistance_request(request_data)
    if result["status"] == "error":
        raise HTTPException(status_code=500, detail=result["message"])
    elif result["status"] == "success":
        return result["message"], 201


@router.put("/edit/{request_id}")
async def route_edit_assistance_request(request_id: str, updated_data: AssistanceRequestCreate):
    result = await edit_assistance_request(request_id, updated_data)
    if result["status"] == "error":
        raise HTTPException(status_code=404 if "not found" in result["message"].lower() else 500, detail=result["message"])
    return {"message": result["message"]}, 200


@router.delete("/delete/{request_id}")
async def route_delete_assistance_request(request_id: str):
    result = await delete_assistance_request(request_id)
    if result["status"] == "error":
        raise HTTPException(status_code=404 if "not found" in result["message"].lower() else 500, detail=result["message"])
    return {"message": result["message"]}, 200
