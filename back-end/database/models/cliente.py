from typing import Optional

from sqlmodel import Field, SQLModel


class Cliente(SQLModel, table=True):
    __tablename__ = "clientes"

    id: Optional[int] = Field(default=None, primary_key=True)
    nombre: str
    nit: str
    telefono: str
    direccion: str
