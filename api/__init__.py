from fastapi import FastAPI
from api.features.customers.routes import customer_router
from api.features.countries.routes import country_router
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

origins = [
    "*"
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(customer_router, prefix="/customers")
app.include_router(country_router, prefix="/countries")