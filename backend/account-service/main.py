from fastapi import FastAPI
from database import engine, Base
from routers.account import router as account_router
from routers.risk import risk_router

app = FastAPI(title="Account Service")

@app.on_event("startup")
async def startup():
    Base.metadata.create_all(bind=engine)

app.include_router(account_router)
app.include_router(risk_router)

@app.get("/health")
async def health():
    return {"status": "healthy", "service": "account"}