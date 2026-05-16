from typing import Optional

from sqlmodel import Field, SQLModel


# Modelo ORM de la tabla productos
# categoria_id es FK a categorias; el JOIN para obtener el nombre se hace en la query psycopg2
class Producto(SQLModel, table=True):
    __tablename__ = "productos"

    id: Optional[int] = Field(default=None, primary_key=True)
    nombre: str
    descripcion: str
    precio: float
    stock: int
    stock_minimo: int
    categoria_id: int = Field(foreign_key="categorias.id")
