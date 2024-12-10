import pyseto
from pyseto import Key
import os
from dotenv import load_dotenv
from fastapi import APIRouter, HTTPException
import json
from datetime import datetime, timedelta, timezone
from db.auth import get_user_by_email, get_user_by_username, get_user_by_id, insert_user, verify_password, \
    update_user_session_nonce
from models.auth import LoginRequest, RegisterRequest, RefreshRequest
from utils.auth import generate_refresh_token, generate_access_token, generate_tokens_nonce, load_private_key, \
    load_public_key, decode_token
import logging
from models.user import User

load_dotenv()
passphrase = os.getenv("PRIVATE_KEY_PASSPHRASE").encode()
logger = logging.getLogger(__name__)

private_key = load_private_key(passphrase)
public_key_pem, public_key = load_public_key()

router = APIRouter()


@router.post("/login")
async def login(request: LoginRequest):
    existing_user = await get_user_by_username(request.username)  # retrieve user
    if existing_user is None:  # if the user is not found, return invalid login message
        return {"message": "Invalid username or password"}, 200

    # if the user exists, try to match the hashed user password and the provided one
    password_matching_result = await verify_password(existing_user["password"], request.password)

    # if there was a match, generate and return a token 200
    if password_matching_result["status"] == "success":
        tokens_nonce = await generate_tokens_nonce()
        access_token = await generate_access_token(private_key, existing_user, tokens_nonce)
        access_token_exp = await decode_token(private_key, access_token)["exp"]
        refresh_token = await generate_refresh_token(private_key, existing_user, tokens_nonce)
        refresh_token_exp = await decode_token(private_key, refresh_token)["exp"]
        nonce_update_result = await update_user_session_nonce(existing_user["_id"], tokens_nonce)
        if nonce_update_result["status"] == "fail":
            raise HTTPException(status_code=500, detail="Error updating user")
        elif nonce_update_result["status"] == "error":
            raise HTTPException(status_code=500, detail="Internal Server Error")

        return {
            'access_token': access_token,
            'access_token_exp': access_token_exp,
            'refresh_token': refresh_token,
            'refresh_token_exp': refresh_token_exp
        }, 200
    # if there was no match, return invalid login message 200
    elif password_matching_result["status"] == "fail":
        raise HTTPException(status_code=200, detail="Invalid username or password")
    # if there was an error, return a 500 message
    elif password_matching_result["status"] == "error":
        raise HTTPException(status_code=500, detail="Internal Server Error")


@router.post("/register")
async def register(request: RegisterRequest):
    # TODO user and password should never be the same
    # TODO password should be secure and longer than 8 characters
    user_insertion_result = await insert_user(request.username, request.password, request.email, request.role)

    # if there was no user with the same username, return 201 code
    if user_insertion_result["status"] == "success":
        return {'message': user_insertion_result["message"]}, 201
    # if there was a user with the same username or email, return fail code
    elif user_insertion_result["status"] == "fail":
        raise HTTPException(status_code=409, detail=user_insertion_result["message"])
    # if there was an error, return a 500 message
    elif user_insertion_result["status"] == "error":
        raise HTTPException(status_code=500, detail="Internal Server Error")


@router.post("/refresh")
async def refresh(request: RefreshRequest):
    try:
        # decode both tokens
        decoded_access_token = pyseto.decode(public_key, request.access_token)
        decoded_refresh_token = pyseto.decode(public_key, request.refresh_token)
    except Exception as e:
        logger.error(f"Token decoding failed: {e}")
        raise HTTPException(status_code=400, detail="Invalid token")

    # get payload from each token
    try:
        decoded_access_token_payload = json.loads(decoded_access_token.payload.decode('utf-8'))
        decoded_refresh_token_payload = json.loads(decoded_refresh_token.payload.decode('utf-8'))
    except (json.JSONDecodeError, UnicodeDecodeError) as e:
        logger.error(f"Payload decoding failed: {e}")
        raise HTTPException(status_code=400, detail="Invalid token payload")

    # ensure user_id in both tokens match
    if decoded_access_token_payload.get("user_id") != decoded_refresh_token_payload.get("user_id"):
        logger.warning("Token mismatch: User ID in access and refresh tokens do not match")
        raise HTTPException(status_code=401, detail="Tokens mismatch")

    # ensure both tokens nonce match
    if decoded_access_token_payload.get("nonce") != decoded_refresh_token_payload.get("nonce"):
        logger.warning("Token mismatch: session nonce does not match")
        raise HTTPException(status_code=401, detail="Tokens mismatch")

    # validate refresh token expiration date
    try:
        refresh_token_expiration_date = datetime.fromisoformat(
            decoded_refresh_token_payload["exp"].replace("Z", "+00:00"))
    except ValueError as e:
        logger.error(f"Invalid expiration date format: {e}")
        raise HTTPException(status_code=400, detail="Invalid expiration date format")

    if refresh_token_expiration_date < datetime.now().replace(tzinfo=timezone.utc):
        logger.warning("Refresh token expired")
        raise HTTPException(status_code=401, detail="Refresh token expired")

    # fetch the user from the database using the user_id
    user = await get_user_by_id(decoded_access_token_payload["user_id"])
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    if user["session_nonce"] != decoded_access_token_payload.get("nonce"):
        logger.warning("Nonce mismatch: The provided nonce doesn't match with the one in the user's document")
        raise HTTPException(status_code=401, detail="Tokens mismatch")

    # generate new tokens
    try:
        tokens_nonce = await generate_tokens_nonce()
        access_token = await generate_access_token(private_key, user, tokens_nonce)
        refresh_token = await generate_refresh_token(private_key, user, tokens_nonce)
        nonce_update_result = await update_user_session_nonce(user["_id"], tokens_nonce)
        if nonce_update_result["status"] == "fail":
            raise HTTPException(status_code=500, detail="Error updating user")
        elif nonce_update_result["status"] == "error":
            raise HTTPException(status_code=500, detail="Internal Server Error")

    except Exception as e:
        logger.error(f"Token generation failed: {e}")
        raise HTTPException(status_code=500, detail="Token generation failed")

    return {"access_token": access_token, "refresh_token": refresh_token}


@router.get("/public-key")
async def get_public_key():
    try:
        return {"public_key": public_key_pem.decode("utf-8")}, 200
    except Exception as e:
        logger.error(f"Failed to encode public key: {e}")
        raise HTTPException(status_code=500, detail="Unable to retrieve public key")


# Fetch user profile by username
@router.get("/profile/{username}", response_model=User)
async def get_user_profile(username: str):
    """
    Fetch the user's profile by username.
    """
    result = await get_user_by_username(username)
    if result["status"] == "error":
        raise HTTPException(status_code=404, detail="User not found")
    user_data = result["data"]
    return User(
        name=user_data['name'],
        email=user_data['email'],
        phone=user_data['phone'],
        address=user_data['address'],
        billingAddress=user_data.get('billingAddress', ''),
        password=user_data['password'],
    )
