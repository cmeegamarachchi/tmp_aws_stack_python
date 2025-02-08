import json
import aiofiles
import os
from typing import List
from fastapi import APIRouter, status, HTTPException
from api.common.utils import read_from_json
from api.features.customers.schema import Customer

customer_router = APIRouter()

async def read_customers_from_json() -> List[Customer]:
    file_path = os.path.join(os.path.dirname(__file__), 'customers.json')
    data = await read_from_json(file_path) 
    return [Customer(**item) for item in data]

async def write_customers_to_json(data: List[Customer]):
    file_path = os.path.join(os.path.dirname(__file__), 'customers.json')
    async with aiofiles.open(file_path, 'w', encoding='utf-8') as f:
        await f.write(json.dumps([c.dict() for c in data], indent=4))

@customer_router.get("/", response_model=List[Customer])
async def get_all_customers():
    customers = await read_customers_from_json()
    return customers

@customer_router.get("/{customer_id}", response_model=Customer, status_code=status.HTTP_200_OK)
async def get_customer(customer_id: str):
    customers = await read_customers_from_json()
    customer = next((c for c in customers if c.id == customer_id), None)
    if customer:
        return customer
    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Customer not found")

@customer_router.post("/", response_model=Customer, status_code=status.HTTP_201_CREATED)
async def create_customer(customer: Customer):
    customers = await read_customers_from_json()
    customers.append(customer)
    await write_customers_to_json(customers)
    return customer

@customer_router.put("/{customer_id}", response_model=Customer, status_code=status.HTTP_200_OK)
async def update_customer(customer_id: str, customer: Customer):
    customers = await read_customers_from_json()
    customer_index = next((i for i, c in enumerate(customers) if c.id == customer_id), None)
    if customer_index is not None:
        customers[customer_index] = customer
        await write_customers_to_json(customers)
        return customer
    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Customer not found")

@customer_router.delete("/{customer_id}", status_code=status.HTTP_200_OK)
async def delete_customer(customer_id: str):
    customers = await read_customers_from_json()
    customer_index = next((i for i, c in enumerate(customers) if c.id == customer_id), None)
    if customer_index is not None:
        customers.pop(customer_index)
        await write_customers_to_json(customers)
        return {"message": "Customer deleted"}
    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Customer not found")