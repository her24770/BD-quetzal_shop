from typing import Optional

from sqlmodel import Field, SQLModel


class MetodoPago(SQLModel, table=True):
    __tablename__ = "metodos_pago"

    id: Optional[int] = Field(default=None, primary_key=True)
    metodo: str
