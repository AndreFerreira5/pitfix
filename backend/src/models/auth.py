from pydantic import BaseModel


class LoginRequest(BaseModel):
    username: str
    password: str


class RegisterRequest(BaseModel):
    name: str
    username: str
    password: str
    email: str
    role: str
    address: str
    billing_address: str
    phone: str
    workshop_id: str


class RefreshRequest(BaseModel):
    access_token: str
    refresh_token: str

