from typing import Optional

from sqlmodel import Field, SQLModel


class Proveedor(SQLModel, table=True):
    __tablename__ = "proveedores"

    id: Optional[int] = Field(default=None, primary_key=True)
    nombre: str
    telefono: str
    email: str
    direccion: str
