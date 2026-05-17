from pydantic import BaseModel
from typing import Optional


# Datos requeridos para crear un empleado (también crea el usuario asociado)
class EmpleadoCreate(BaseModel):
    email: str
    password: str
    rol_id: int
    dpi: str
    nombre: str
    telefono: str
    cargo: str
    fecha_contrato: str


# Todos los campos son opcionales para permitir edición parcial (PATCH)
class EmpleadoUpdate(BaseModel):
    nombre:    Optional[str] = None
    telefono:  Optional[str] = None
    cargo:     Optional[str] = None
    estado:    Optional[str] = None
    rol_id:    Optional[int] = None


# Datos que devuelve la API al consultar un empleado
class EmpleadoResponse(BaseModel):
    id: int
    usuario_id: int
    dpi: str
    nombre: str
    telefono: str
    cargo: str
    fecha_contrato: str
    estado: str
    email: str
    rol_id: int
    rol_nombre: str
