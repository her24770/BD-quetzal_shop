from sqlmodel import select

from database.orm import get_session
from database.models.categoria import Categoria


# Trae todas las categorías ordenadas por nombre usando ORM
def get_all() -> list[dict]:
    with get_session() as session:
        categorias = session.exec(select(Categoria).order_by(Categoria.nombre)).all()
        return [c.model_dump() for c in categorias]


# Busca una categoría por ID; retorna None si no existe
def get_by_id(categoria_id: int) -> dict | None:
    with get_session() as session:
        # session.get() busca por PK directamente, más eficiente que un SELECT con WHERE
        categoria = session.get(Categoria, categoria_id)
        if categoria is None:
            return None
        return categoria.model_dump()


# Inserta una nueva categoría y retorna el registro creado con su ID generado
def create(nombre: str, descripcion: str) -> dict:
    with get_session() as session:
        categoria = Categoria(nombre=nombre, descripcion=descripcion)
        session.add(categoria)
        session.commit()
        # refresh actualiza el objeto con los valores que asignó la BD (ej. id autoincremental)
        session.refresh(categoria)
        return categoria.model_dump()


# Actualiza solo los campos recibidos y retorna la categoría actualizada
def update(categoria_id: int, campos: dict) -> dict | None:
    if not campos:
        return get_by_id(categoria_id)

    with get_session() as session:
        categoria = session.get(Categoria, categoria_id)
        if categoria is None:
            return None
        # setattr aplica cada campo del dict al objeto ORM sin necesidad de SQL dinámico
        for key, value in campos.items():
            setattr(categoria, key, value)
        session.add(categoria)
        session.commit()
        session.refresh(categoria)
        return categoria.model_dump()


# Elimina una categoría; lanza ValueError si tiene productos asociados (FK violation)
def delete(categoria_id: int) -> bool:
    with get_session() as session:
        categoria = session.get(Categoria, categoria_id)
        if categoria is None:
            return False
        try:
            session.delete(categoria)
            session.commit()
            return True
        except Exception as e:
            session.rollback()
            if "foreign key" in str(e).lower() or "violates" in str(e).lower():
                raise ValueError("No se puede eliminar: la categoría tiene productos asociados")
            raise
