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


@router.get("/all", response_model=List[AssistanceRequest])
async def route_get_all_assistance_requests():
    return await get_all_assistance_requests(), 200
    if result["status"] == "error":
        raise HTTPException(status_code=500, detail=result["message"])
    return result


@router.get("/{request_id}", response_model=AssistanceRequest)
async def route_get_assistance_request_by_id(request_id: str):
    result = await get_assistance_request_by_id(request_id)
    if result["status"] == "error":
        raise HTTPException(status_code=404, detail=result["message"])
    return result["data"]


@router.get("/workshop/{workshop_id}", response_model=List[AssistanceRequest])
async def route_get_requests_by_workshop(workshop_id: str):
    result = await get_assistance_requests_by_workshop(workshop_id)
    if result["status"] == "error":
        raise HTTPException(status_code=404, detail=result["message"])
    return result


@router.get("/worker/{worker_id}", response_model=List[AssistanceRequest])
async def route_get_requests_by_worker(worker_id: str):
    result = await get_assistance_requests_by_worker(worker_id)
    if result["status"] == "error":
        raise HTTPException(status_code=404, detail=result["message"])
    return result


@router.post("", response_model=dict)
async def route_create_assistance_request(request_data: AssistanceRequestCreate):
    result = await insert_assistance_request(request_data)
    if result["status"] == "error":
        raise HTTPException(status_code=500, detail=result["message"])
    return result


@router.put("/{request_id}", response_model=dict)
async def route_edit_assistance_request(request_id: str, updated_data: AssistanceRequestCreate):
    result = await edit_assistance_request(request_id, updated_data)
    if result["status"] == "error":
        raise HTTPException(status_code=404, detail=result["message"])
    return result


@router.delete("/{request_id}", response_model=dict)
async def route_delete_assistance_request(request_id: str):
    result = await delete_assistance_request(request_id)
    if result["status"] == "error":
        raise HTTPException(status_code=404, detail=result["message"])
    return result
