from pydantic import BaseModel

class Customer(BaseModel):
    id: str
    first_name: str
    last_name: str
    email: str
    street_address: str
    city: str
    country: str