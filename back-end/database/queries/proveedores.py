from sqlmodel import select

from database.connection import get_connection, return_connection
from database.orm import get_session
from database.models.proveedor import Proveedor


def get_all() -> list[dict]:
    with get_session() as session:
        proveedores = session.exec(select(Proveedor).order_by(Proveedor.nombre)).all()
        return [p.model_dump() for p in proveedores]


def get_by_id(proveedor_id: int) -> dict | None:
    with get_session() as session:
        proveedor = session.get(Proveedor, proveedor_id)
        if proveedor is None:
            return None
        return proveedor.model_dump()


# JOIN a 3 tablas — consulta avanzada, se mantiene en SQL explícito
def get_productos(proveedor_id: int) -> list[dict]:
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute("""
                SELECT p.id, p.nombre, p.descripcion, p.precio,
                       pp.precio_costo, c.nombre AS categoria
                FROM producto_proveedor pp
                INNER JOIN productos p   ON pp.producto_id  = p.id
                INNER JOIN categorias c  ON p.categoria_id  = c.id
                WHERE pp.proveedor_id = %s
                ORDER BY p.nombre
            """, (proveedor_id,))
            cols = [desc[0] for desc in cur.description]
            return [dict(zip(cols, row)) for row in cur.fetchall()]
    finally:
        return_connection(conn)


def create(nombre: str, telefono: str, email: str, direccion: str) -> dict:
    with get_session() as session:
        proveedor = Proveedor(nombre=nombre, telefono=telefono, email=email, direccion=direccion)
        session.add(proveedor)
        session.commit()
        session.refresh(proveedor)
        return proveedor.model_dump()


def update(proveedor_id: int, campos: dict) -> dict | None:
    if not campos:
        return get_by_id(proveedor_id)
    with get_session() as session:
        proveedor = session.get(Proveedor, proveedor_id)
        if proveedor is None:
            return None
        for key, value in campos.items():
            setattr(proveedor, key, value)
        session.add(proveedor)
        session.commit()
        session.refresh(proveedor)
        return proveedor.model_dump()


def delete(proveedor_id: int) -> bool:
    with get_session() as session:
        proveedor = session.get(Proveedor, proveedor_id)
        if proveedor is None:
            return False
        try:
            session.delete(proveedor)
            session.commit()
            return True
        except Exception as e:
            session.rollback()
            if "foreign key" in str(e).lower() or "violates" in str(e).lower():
                raise ValueError("No se puede eliminar: el proveedor tiene compras o productos asociados")
            raise
