import os
from pathlib import Path
from dotenv import load_dotenv

# El .env está en la raíz del repo, un nivel arriba de back-end/
load_dotenv(dotenv_path=Path(__file__).resolve().parent.parent / ".env")

class Settings:
    # Base de datos
    DB_HOST: str = os.getenv("DB_HOST", "localhost")
    DB_PORT: int = int(os.getenv("DB_PORT", "5432"))
    DB_NAME: str = os.getenv("DB_NAME", "quetzalshop_db")
    DB_USER: str = os.getenv("DB_USER", "proy2")
    DB_PASSWORD: str = os.getenv("DB_PASSWORD", "secret")

    # JWT
    JWT_SECRET: str = os.getenv("JWT_SECRET", "")
    JWT_ALGORITHM: str = os.getenv("JWT_ALGORITHM", "HS256")
    JWT_EXPIRE_HOURS: int = int(os.getenv("JWT_EXPIRE_HOURS", "24"))

    # App
    APP_PORT: int = int(os.getenv("APP_PORT", "8000"))
    APP_ENV: str = os.getenv("APP_ENV", "development")

    # CORS — orígenes permitidos separados por coma en el .env
    CORS_ORIGINS: list = os.getenv(
        "CORS_ORIGINS", "http://localhost:5173,http://localhost:3000"
    ).split(",")

    # Credenciales de los 5 roles de PostgreSQL (las usa el API en runtime)
    DB_ADMIN_PASSWORD: str     = os.getenv("DB_ADMIN_PASSWORD",     "admin_secret")
    DB_CAJERO_PASSWORD: str    = os.getenv("DB_CAJERO_PASSWORD",    "cajero_secret")
    DB_BODEGUERO_PASSWORD: str = os.getenv("DB_BODEGUERO_PASSWORD", "bodeguero_secret")
    DB_GERENTE_PASSWORD: str   = os.getenv("DB_GERENTE_PASSWORD",   "gerente_secret")
    DB_AUDITOR_PASSWORD: str   = os.getenv("DB_AUDITOR_PASSWORD",   "auditor_secret")

    # Construct database URL for connection string
    DATABASE_URL: str = f"postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"

settings = Settings()
