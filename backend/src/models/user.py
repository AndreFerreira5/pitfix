from pydantic import BaseModel
from typing import Optional

class User(BaseModel):
    name: str
    email: str
    phone: str
    address: str
