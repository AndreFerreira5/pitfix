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
    billingAddress: str
    phone: str


class RefreshRequest(BaseModel):
    access_token: str
    refresh_token: str

