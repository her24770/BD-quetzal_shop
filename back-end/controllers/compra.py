from fastapi import HTTPException, status
from database.queries import compras as compras_query
from schemas.compra import CompraCreate, CompraResponse, CompraResumen


# Retorna el listado resumido de compras
def get_all() -> list[CompraResumen]:
    return compras_query.get_all()


# Busca una compra por ID con todos sus items y lanza 404 si no existe
def get_by_id(compra_id: int) -> CompraResponse:
    compra = compras_query.get_by_id(compra_id)
    if compra is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Compra no encontrada")
    return compra


# Registra una nueva compra — empleado_id y rol_id vienen del token
def crear(body: CompraCreate, empleado_id: int, rol_id: int) -> CompraResponse:
    items = [item.model_dump() for item in body.items]
    try:
        return compras_query.crear(
            empleado_id,
            body.numero_factura,
            items,
            rol_id,
        )
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
