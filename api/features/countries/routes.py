import os
from typing import List
from fastapi import APIRouter
from api.common.utils import read_from_json
from api.features.countries.schema import Country

country_router = APIRouter()

async def read_countries_from_json() -> List[Country]:
    file_path = os.path.join(os.path.dirname(__file__), 'countries.json')
    data = await read_from_json(file_path) 
    return [Country(**item) for item in data]

@country_router.get("/", response_model=List[Country])
async def get_all_countries():
    countries = await read_countries_from_json()
    return countries