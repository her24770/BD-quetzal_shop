from datetime import date
from typing import Optional

from sqlmodel import Field, SQLModel


class Empleado(SQLModel, table=True):
    __tablename__ = "empleados"

    id: Optional[int] = Field(default=None, primary_key=True)
    usuario_id: int
    dpi: str
    nombre: str
    telefono: str
    cargo: str
    fecha_contrato: date
    estado: str = Field(default="activo")
