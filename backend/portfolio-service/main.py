from fastapi import FastAPI
from database import engine, Base
from routers.portfolio import router as portfolio_router

app = FastAPI(title="Portfolio Service")

@app.on_event("startup")
async def startup():
    Base.metadata.create_all(bind=engine)

app.include_router(portfolio_router)

@app.get("/health")
async def health():
    return {"status": "healthy", "service": "portfolio"}