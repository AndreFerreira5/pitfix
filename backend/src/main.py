from fastapi import FastAPI, Depends
from routes import auth, workshop, assistance_request
from db.connection import db_connect, db_disconnect
import uvicorn
from contextlib import asynccontextmanager
from logging_config import configure_logging

# configure logging globally
configure_logging()


@asynccontextmanager
async def lifespan(app: FastAPI):
    await db_connect()  # connect to db during startup
    yield
    await db_disconnect()  # disconnect from db during shutdown


app = FastAPI(lifespan=lifespan)

app.include_router(auth.router, prefix="/auth", tags=["auth"])
app.include_router(workshop.router, prefix="/workshop", tags=["workshop"])
app.include_router(assistance_request.router, prefix="/assistance_request", tags=["assistance_request"])


@app.get("/ping")
async def ping():
    return {"message": "pong"}


if __name__ == '__main__':
    uvicorn.run("main:app", host="127.0.0.1", port=8000, reload=True)
