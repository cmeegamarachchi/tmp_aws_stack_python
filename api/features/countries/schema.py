from pydantic import BaseModel

class Country(BaseModel):
    name: str
    code: str