from typing import Optional

from sqlmodel import Field, SQLModel


# Modelo ORM de la tabla categorias — una sola clase sirve como modelo de BD y schema Pydantic
class Categoria(SQLModel, table=True):
    __tablename__ = "categorias"

    # Field(primary_key=True) mapea la columna id con autoincremento
    id: Optional[int] = Field(default=None, primary_key=True)
    nombre: str
    descripcion: str
