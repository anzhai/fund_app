from fastapi import FastAPI
from database import engine, Base
from routers.auth import router as auth_router

app = FastAPI(title="Auth Service")

@app.on_event("startup")
async def startup():
    Base.metadata.create_all(bind=engine)

app.include_router(auth_router)

@app.get("/health")
async def health():
    return {"status": "healthy", "service": "auth"}