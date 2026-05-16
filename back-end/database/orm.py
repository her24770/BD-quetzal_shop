from sqlmodel import Session, create_engine

from config import settings

# DATABASE_URL viene de config.py: postgresql://user:pass@host:port/db
engine = create_engine(settings.DATABASE_URL)


# Genera una sesión SQLModel lista para usar y la cierra al terminar
def get_session() -> Session:
    return Session(engine)
