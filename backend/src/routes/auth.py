import pyseto
from pyseto import Key
import os
from dotenv import load_dotenv
from fastapi import APIRouter, HTTPException
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.backends import default_backend
import json
from datetime import datetime, timedelta, timezone
from db.auth import get_user_by_username, get_user_by_id, insert_user, verify_password, update_user_session_nonce
from pydantic import BaseModel
import logging


class LoginRequest(BaseModel):
    username: str
    password: str


class RegisterRequest(BaseModel):
    username: str
    password: str
    email: str


class RefreshRequest(BaseModel):
    access_token: str
    refresh_token: str


load_dotenv()
passphrase = os.getenv("PRIVATE_KEY_PASSPHRASE").encode()

# load encrypted private key from the disk
with open("config/private_key.pem", "rb") as private_key_file:
    # decrypt private key with configured passphrase
    private_key_decrypted = serialization.load_pem_private_key(
        private_key_file.read(),
        password=passphrase,
        backend=default_backend()
    )

    # convert decrypted private key to bytes
    private_key_bytes = private_key_decrypted.private_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PrivateFormat.PKCS8,
        encryption_algorithm=serialization.NoEncryption()
    )

    # get paseto private key
    private_key = Key.new(4, "public", private_key_bytes)

# load public key from the disk
with open("config/public_key.pem", "rb") as public_key_file:
    public_key = Key.new(4, "public", public_key_file.read())

router = APIRouter()


#########
# UTILS #
#########

async def generate_refresh_token(user, nonce: str) -> bytes:
    token_expiration_time = datetime.now() + timedelta(days=30)
    payload_dict = {
        "exp": token_expiration_time.isoformat() + 'Z',
        "user_id": str(user["_id"]),
        "nonce": nonce
    }
    return pyseto.encode(
        private_key,
        json.dumps(payload_dict).encode('utf-8')
    )


async def generate_access_token(user, nonce: str) -> bytes:
    token_expiration_time = datetime.now() + timedelta(minutes=15)
    payload_dict = {
        "exp": token_expiration_time.isoformat() + 'Z',
        "user_id": str(user["_id"]),
        "nonce": nonce
    }
    return pyseto.encode(
        private_key,
        json.dumps(payload_dict).encode('utf-8')
    )


async def generate_tokens_nonce() -> str:
    return os.urandom(32).hex()


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
        access_token = await generate_access_token(existing_user, tokens_nonce)
        refresh_token = await generate_refresh_token(existing_user, tokens_nonce)
        nonce_update_result = await update_user_session_nonce(existing_user["_id"], tokens_nonce)
        if nonce_update_result["status"] == "fail":
            raise HTTPException(status_code=500, detail="Error updating user")
        elif nonce_update_result["status"] == "error":
            raise HTTPException(status_code=500, detail="Internal Server Error")

        return {'access_token': access_token, "refresh_token": refresh_token}, 200
    # if there was no match, return invalid login message 401
    elif password_matching_result["status"] == "fail":
        raise HTTPException(status_code=401, detail="Invalid username or password")
    # if there was an error, return a 500 message
    elif password_matching_result["status"] == "error":
        raise HTTPException(status_code=500, detail="Internal Server Error")


@router.post("/register")
async def register(request: RegisterRequest):
    # TODO user and password should never be the same
    # TODO password should be secure and longer than 8 characters
    user_insertion_result = await insert_user(request.username, request.password, request.email)

    # if there was no user with the same username, return 201 code
    if user_insertion_result["status"] == "success":
        return {'message': "User created successfully."}, 201
    # if there was a user with the same username, return fail code
    elif user_insertion_result["status"] == "fail":
        raise HTTPException(status_code=409, detail="Username already exists")
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
        logging.error(f"Token decoding failed: {e}")
        raise HTTPException(status_code=400, detail="Invalid token")

    # get payload from each token
    try:
        decoded_access_token_payload = json.loads(decoded_access_token.payload.decode('utf-8'))
        decoded_refresh_token_payload = json.loads(decoded_refresh_token.payload.decode('utf-8'))
    except (json.JSONDecodeError, UnicodeDecodeError) as e:
        logging.error(f"Payload decoding failed: {e}")
        raise HTTPException(status_code=400, detail="Invalid token payload")

    # ensure user_id in both tokens match
    if decoded_access_token_payload.get("user_id") != decoded_refresh_token_payload.get("user_id"):
        logging.warning("Token mismatch: User ID in access and refresh tokens do not match")
        raise HTTPException(status_code=401, detail="Tokens mismatch")

    # ensure both tokens nonce match
    if decoded_access_token_payload.get("nonce") != decoded_refresh_token_payload.get("nonce"):
        logging.warning("Token mismatch: session nonce does not match")
        raise HTTPException(status_code=401, detail="Tokens mismatch")

    # validate refresh token expiration date
    try:
        refresh_token_expiration_date = datetime.fromisoformat(
            decoded_refresh_token_payload["exp"].replace("Z", "+00:00"))
    except ValueError as e:
        logging.error(f"Invalid expiration date format: {e}")
        raise HTTPException(status_code=400, detail="Invalid expiration date format")

    if refresh_token_expiration_date < datetime.now().replace(tzinfo=timezone.utc):
        logging.warning("Refresh token expired")
        raise HTTPException(status_code=401, detail="Refresh token expired")

    # fetch the user from the database using the user_id
    user = await get_user_by_id(decoded_access_token_payload["user_id"])
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    if user["session_nonce"] != decoded_access_token_payload.get("nonce"):
        logging.warning("Nonce mismatch: The provided nonce doesn't match with the one in the user's document")
        raise HTTPException(status_code=401, detail="Tokens mismatch")

    # generate new tokens
    try:
        tokens_nonce = await generate_tokens_nonce()
        access_token = await generate_access_token(user, tokens_nonce)
        refresh_token = await generate_refresh_token(user, tokens_nonce)
        nonce_update_result = await update_user_session_nonce(user["_id"], tokens_nonce)
        if nonce_update_result["status"] == "fail":
            raise HTTPException(status_code=500, detail="Error updating user")
        elif nonce_update_result["status"] == "error":
            raise HTTPException(status_code=500, detail="Internal Server Error")

    except Exception as e:
        logging.error(f"Token generation failed: {e}")
        raise HTTPException(status_code=500, detail="Token generation failed")

    return {"access_token": access_token, "refresh_token": refresh_token}


@router.get("/public-key")
async def public_key():
    return {"public-key": public_key}, 200
