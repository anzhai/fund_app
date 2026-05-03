from fastapi import FastAPI
from database import engine, Base

def create_app() -> FastAPI:
    app = FastAPI(title="Service Name")

    @app.on_event("startup")
    async def startup():
        Base.metadata.create_all(bind=engine)

    @app.get("/health")
    async def health():
        return {"status": "healthy"}

    return app
