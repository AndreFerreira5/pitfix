from datetime import datetime, timedelta
import json
import os
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.backends import default_backend
import pyseto
from pyseto import Key
from pathlib import Path
import logging


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


def load_private_key(passphrase: bytes):
    primary_path = Path("config/private_key.pem")
    secondary_path = Path("private_key.pem")

    pem_content = None

    # attempt primary path
    if primary_path.is_file():
        try:
            with primary_path.open("rb") as pk_file:
                pem_content = pk_file.read()
            logging.info(f"Loaded private key from {primary_path}")
        except Exception as e:
            logging.error(f"Failed to load private key from {primary_path}: {e}")
            pem_content = None

    # attempt secondary path
    if pem_content is None and secondary_path.is_file():
        try:
            with secondary_path.open("rb") as pk_file:
                pem_content = pk_file.read()
            logging.info(f"Loaded private key from {secondary_path}")
        except Exception as e:
            logging.error(f"Failed to load private key from {secondary_path}: {e}")
            pem_content = None

    # attempt environment variable
    if pem_content is None:
        pem_env = os.getenv("PRIVATE_KEY_PEM")
        if pem_env:
            try:
                pem_bytes = pem_env.encode('utf-8')

                private_key_decrypted = serialization.load_pem_private_key(
                    pem_bytes,
                    password=passphrase,
                    backend=default_backend()
                )

                private_key_bytes = private_key_decrypted.private_bytes(
                    encoding=serialization.Encoding.PEM,
                    format=serialization.PrivateFormat.PKCS8,
                    encryption_algorithm=serialization.NoEncryption()
                )

                pem_content = private_key_bytes
                logging.info("Loaded private key from environment variable.")
            except Exception as e:
                logging.error(f"Failed to load private key from environment variable: {e}")
                raise ValueError("Failed to load private key from environment variable.") from e
        else:
            logging.error("PRIVATE_KEY_PEM environment variable not set.")
            raise FileNotFoundError("Private key not found in file paths or environment variables.")

    # process the PEM content
    try:
        private_key_decrypted = serialization.load_pem_private_key(
            pem_content,
            password=passphrase,
            backend=default_backend()
        )

        private_key_bytes = private_key_decrypted.private_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PrivateFormat.PKCS8,
            encryption_algorithm=serialization.NoEncryption()
        )

        private_key = Key.new(4, "public", private_key_bytes)
        logging.info("Private key processed successfully.")
        return private_key
    except Exception as e:
        logging.error(f"Error processing private key: {e}")
        raise ValueError("Failed to process the private key.") from e
