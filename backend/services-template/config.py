from pydantic_settings import BaseSettings
from functools import lru_cache

class Settings(BaseSettings):
    SERVICE_NAME: str = "service"
    DATABASE_URL: str = "mysql+pymysql://root:root123@mysql:3306/fund_app"
    REDIS_URL: str = "redis://redis:6379"
    JWT_SECRET: str = "your-secret-key-change-in-production"
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 15
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7

    class Config:
        env_file = ".env"

@lru_cache()
def get_settings():
    return Settings()
