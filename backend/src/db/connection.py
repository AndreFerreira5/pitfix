import os
import logging
from dotenv import load_dotenv
from motor.motor_asyncio import AsyncIOMotorClient
from pymongo.errors import PyMongoError

load_dotenv()
logger = logging.getLogger(__name__)


class MongoDB:
    def __init__(self):
        self._client = None
        self._db = None

    async def connect(self):
        if self._client is None:
            try:
                mongo_uri = None

                is_env_dev = os.getenv('IS_ENV_DEV')
                if is_env_dev is not None:
                    mongo_uri = os.getenv('MONGO_URI')
                    mongo_uri = mongo_uri.replace("{username}", os.getenv('MONGO_USERNAME'))
                    mongo_uri = mongo_uri.replace("{password}", os.getenv('MONGO_PASSWORD'))
                    mongo_uri = mongo_uri.replace("{host}", os.getenv('MONGO_HOST'))
                    mongo_uri = mongo_uri.replace("{port}", os.getenv('MONGO_PORT'))
                    mongo_uri = mongo_uri.replace("{db_name}", os.getenv('MONGO_DB_NAME'))

                else:
                    mongo_uri = os.getenv('MONGO_PROD_URI')

                self._client = AsyncIOMotorClient(mongo_uri)
                self._db = self._client[os.getenv('MONGO_DB_NAME')]

                await self._db.command('ping')
                logger.info("Successfully connected to MongoDB.")
            except PyMongoError as e:
                logger.error(f"Failed to connect to MongoDB: {str(e)}")
                raise e

    async def disconnect(self):
        if self._client:
            self._client.close()
            self._client = None
            self._db = None
            logger.info("MongoDB connection closed.")

    @property
    def client(self):
        return self._client

    @property
    def db(self):
        return self._db


mongodb = MongoDB()


async def db_connect():
    await mongodb.connect()


async def db_disconnect():
    await mongodb.disconnect()


async def get_db():
    return mongodb.db
