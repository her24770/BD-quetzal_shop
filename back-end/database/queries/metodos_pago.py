from sqlmodel import select

from database.orm import get_session
from database.models.metodo_pago import MetodoPago


def get_all() -> list[dict]:
    with get_session() as session:
        metodos = session.exec(select(MetodoPago).order_by(MetodoPago.id)).all()
        return [m.model_dump() for m in metodos]
