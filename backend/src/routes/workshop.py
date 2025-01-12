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
    delete_requests_from_users,
    delete_workshop_from_users,
)

from db.assistance_request import (
    delete_all_requests_from_workshop_by_workshop_id,
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
    # delete the workshop
    result = await delete_workshop_by_id(workshop_id)
    if result["status"] == "error":
        raise HTTPException(status_code=404 if "not found" in result["message"].lower() else 500,
                            detail=result["message"])

    # delete the requests associated with the provided workshop id
    workshop_requests_deletion_result = await delete_all_requests_from_workshop_by_workshop_id(workshop_id)
    if workshop_requests_deletion_result["status"] == "error":
        raise HTTPException(status_code=500, detail=result["message"])

    #if not workshop_requests_deletion_result["deleted_ids"]:
    #    raise HTTPException(status_code=500, detail="Error deleting assistance requests with workshop id")

    deleted_request_ids = workshop_requests_deletion_result["deleted_ids"]

    # delete the requests associated with the provided workshop id from users documents
    if len(deleted_request_ids) > 0:
        requests_deletion_from_users_result = await delete_requests_from_users(deleted_request_ids)
        if requests_deletion_from_users_result["status"] == "error":
            raise HTTPException(status_code=500, detail=result["message"])

    # delete workshop id from workers and managers documents
    workshop_deletion_from_users_result = await delete_workshop_from_users(workshop_id)
    if workshop_deletion_from_users_result["status"] == "error":
        raise HTTPException(status_code=500, detail=result["message"])

    return {"message": "Workshop deleted successfully"}, 200


@router.delete("/delete/name/{workshop_name}")
async def delete_workshop_by_name_route(workshop_name: str):
    # get the workshop info
    workshop_result = await get_workshop_by_name(workshop_name)
    if workshop_result["status"] == "error":
        raise HTTPException(status_code=404 if "not found" in workshop_result["message"].lower() else 500,
                            detail=workshop_result["message"])

    # get workshop id
    if not workshop_result["data"] or not workshop_result["data"]["_id"]:
        raise HTTPException(status_code=500, detail="Error deleting workshop from db")
    workshop_id = workshop_result["data"]["_id"]

    # delete workshop document
    result = await delete_workshop_by_name(workshop_name)
    if result["status"] == "error":
        raise HTTPException(status_code=404 if "not found" in result["message"].lower() else 500,
                            detail=result["message"])

    # delete the requests associated with the provided workshop id
    workshop_requests_deletion_result = await delete_all_requests_from_workshop_by_workshop_id(workshop_id)
    if workshop_requests_deletion_result["status"] == "error":
        raise HTTPException(status_code=500, detail=result["message"])

    #if not workshop_requests_deletion_result["deleted_ids"]:
    #    raise HTTPException(status_code=500, detail="Error deleting assistance requests with workshop id")

    deleted_request_ids = workshop_requests_deletion_result["deleted_ids"]

    # delete the requests associated with the provided workshop id from users documents
    if deleted_request_ids and len(deleted_request_ids) > 0:
        requests_deletion_from_users_result = await delete_requests_from_users(deleted_request_ids)
        if requests_deletion_from_users_result["status"] == "error":
            raise HTTPException(status_code=500, detail=result["message"])

    # delete workshop id from workers and managers documents
    workshop_deletion_from_users_result = await delete_workshop_from_users(workshop_id)
    if workshop_deletion_from_users_result["status"] == "error":
        raise HTTPException(status_code=500, detail=result["message"])

    return {"message": "Workshop deleted successfully"}, 200


@router.put("/edit/{workshop_id}")
async def edit_workshop_route(workshop_id: str, updated_data: WorkshopCreate):
    result = await edit_workshop(workshop_id, updated_data)
    if result["status"] == "error":
        raise HTTPException(status_code=404 if "not found" in result["message"].lower() else 500,
                            detail=result["message"])
    return {"message": result["message"]}, 200
