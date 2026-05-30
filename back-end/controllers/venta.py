from fastapi import HTTPException, status
import psycopg2
from database.queries import ventas as ventas_query, metodos_pago as metodos_pago_query
from schemas.venta import VentaCreate, VentaResponse, VentaResumen


# Retorna el listado resumido de ventas
def get_all() -> list[VentaResumen]:
    return ventas_query.get_all()


# Busca una venta por ID con todos sus items y lanza 404 si no existe
def get_by_id(venta_id: int) -> VentaResponse:
    venta = ventas_query.get_by_id(venta_id)
    if venta is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Venta no encontrada")
    return venta


# Retorna los métodos de pago disponibles
def get_metodos_pago() -> list:
    return metodos_pago_query.get_all()


# Registra una nueva venta — empleado_id y rol_id vienen del token
def crear(body: VentaCreate, empleado_id: int, rol_id: int) -> VentaResponse:
    items = [item.model_dump() for item in body.items]
    try:
        return ventas_query.crear(
            body.cliente_id,
            empleado_id,
            body.metodo_pago_id,
            body.descuento,
            items,
            rol_id,
        )
    except (ValueError, psycopg2.Error) as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e).split('\n')[0])
