from fastapi import FastAPI
from database import engine, Base
from routers.fund import router as fund_router

app = FastAPI(title="Fund Service")

@app.on_event("startup")
async def startup():
    Base.metadata.create_all(bind=engine)

app.include_router(fund_router)

@app.get("/health")
async def health():
    return {"status": "healthy", "service": "fund"}