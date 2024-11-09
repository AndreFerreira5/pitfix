from datetime import datetime, timedelta
import pyseto
import json
import os


async def generate_refresh_token(private_key, user, nonce: str) -> bytes:
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


async def generate_access_token(private_key, user, nonce: str) -> bytes:
    token_expiration_time = datetime.now() + timedelta(minutes=15)
    payload_dict = {
        "exp": token_expiration_time.isoformat() + 'Z',
        "user_id": str(user["_id"]),
        "user_role": str(user.get("role", "")),
        "nonce": nonce
    }
    return pyseto.encode(
        private_key,
        json.dumps(payload_dict).encode('utf-8')
    )


async def generate_tokens_nonce() -> str:
    return os.urandom(32).hex()
