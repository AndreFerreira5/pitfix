from pydantic import BaseModel, Field
from typing import Optional


class LoginRequest(BaseModel):
    username: str
    password: str


class RegisterRequest(BaseModel):
    name: Optional[str] = None
    username: str
    password: str
    email: str
    role: str
    address: Optional[str] = None
    billing_address: Optional[str] = Field(None, alias='billing_address')
    phone: Optional[str] = None
    workshop_id: Optional[str] = Field(None, alias='workshop_id')

    class Config:
        allow_population_by_field_name = True


class RefreshRequest(BaseModel):
    access_token: str
    refresh_token: str

