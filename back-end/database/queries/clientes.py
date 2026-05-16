from sqlmodel import select

from database.orm import get_session
from database.models.cliente import Cliente


def get_all() -> list[dict]:
    with get_session() as session:
        clientes = session.exec(select(Cliente).order_by(Cliente.nombre)).all()
        return [c.model_dump() for c in clientes]


def get_by_id(cliente_id: int) -> dict | None:
    with get_session() as session:
        cliente = session.get(Cliente, cliente_id)
        if cliente is None:
            return None
        return cliente.model_dump()


def get_by_nit(nit: str) -> dict | None:
    with get_session() as session:
        cliente = session.exec(select(Cliente).where(Cliente.nit == nit)).first()
        if cliente is None:
            return None
        return cliente.model_dump()


def create(nombre: str, nit: str, telefono: str, direccion: str) -> dict:
    with get_session() as session:
        cliente = Cliente(nombre=nombre, nit=nit, telefono=telefono, direccion=direccion)
        session.add(cliente)
        session.commit()
        session.refresh(cliente)
        return cliente.model_dump()


def update(cliente_id: int, campos: dict) -> dict | None:
    if not campos:
        return get_by_id(cliente_id)
    with get_session() as session:
        cliente = session.get(Cliente, cliente_id)
        if cliente is None:
            return None
        for key, value in campos.items():
            setattr(cliente, key, value)
        session.add(cliente)
        session.commit()
        session.refresh(cliente)
        return cliente.model_dump()


def delete(cliente_id: int) -> bool:
    with get_session() as session:
        cliente = session.get(Cliente, cliente_id)
        if cliente is None:
            return False
        try:
            session.delete(cliente)
            session.commit()
            return True
        except Exception as e:
            session.rollback()
            if "foreign key" in str(e).lower() or "violates" in str(e).lower():
                raise ValueError("No se puede eliminar: el cliente tiene ventas asociadas")
            raise
