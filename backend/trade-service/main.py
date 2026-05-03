from fastapi import FastAPI
from database import engine, Base
from routers.trade import router as trade_router
from routers.wallet import wallet_router

app = FastAPI(title="Trade Service")

@app.on_event("startup")
async def startup():
    Base.metadata.create_all(bind=engine)

app.include_router(trade_router)
app.include_router(wallet_router)

@app.get("/health")
async def health():
    return {"status": "healthy", "service": "trade"}