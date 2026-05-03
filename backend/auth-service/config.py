import os
from pydantic_settings import BaseSettings
from functools import lru_cache

class Settings(BaseSettings):
    SERVICE_NAME: str = "service"
    DATABASE_URL: str = os.getenv("DATABASE_URL", "sqlite:///./fund_app_dev.db")
    REDIS_URL: str = os.getenv("REDIS_URL", "redis://localhost:6379")
    JWT_SECRET: str = ""  # MUST be set via environment variable
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 15
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7

    class Config:
        env_file = ".env"

@lru_cache()
def get_settings():
    return Settings()
