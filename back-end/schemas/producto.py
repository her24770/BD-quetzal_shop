from pydantic import BaseModel
from typing import Literal, Optional


# Datos requeridos para crear un producto
class ProductoCreate(BaseModel):
    nombre: str
    descripcion: str
    precio: float
    stock: int
    stock_minimo: int
    categoria_id: int


# Todos los campos son opcionales para permitir edición parcial (PATCH)
class ProductoUpdate(BaseModel):
    nombre: Optional[str] = None
    descripcion: Optional[str] = None
    precio: Optional[float] = None
    stock: Optional[int] = None
    stock_minimo: Optional[int] = None
    categoria_id: Optional[int] = None


# Datos que devuelve la API, incluye el nombre de la categoría por JOIN
class ProductoResponse(BaseModel):
    id: int
    nombre: str
    descripcion: str
    precio: float
    stock: int
    stock_minimo: int
    categoria_id: int
    categoria: str


# Datos para ajustar el stock via sp_actualizar_stock
class StockUpdate(BaseModel):
    cantidad: int
    operacion: Literal["incrementar", "decrementar"]
