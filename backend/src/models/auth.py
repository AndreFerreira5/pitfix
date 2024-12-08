from pydantic import BaseModel


class LoginRequest(BaseModel):
    username: str
    password: str


class RegisterRequest(BaseModel):
    username: str
    password: str
    email: str
    role: str


class RefreshRequest(BaseModel):
    access_token: str
    refresh_token: str


class User(BaseModel):
    name: str
    email: str
    phone: str
    address: str
    billingAddress: Optional[str] = None
    # Exclude password in response
