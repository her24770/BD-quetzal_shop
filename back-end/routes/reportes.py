from fastapi import APIRouter, Depends, Query

from dependencies import get_current_user, TokenData
from controllers import reportes as reportes_controller

router = APIRouter()


@router.get("/stats")
def stats(current_user: TokenData = Depends(get_current_user)):
    return reportes_controller.get_stats()


@router.get("/top-productos")
def top_productos(current_user: TokenData = Depends(get_current_user)):
    return reportes_controller.get_top_productos()


@router.get("/ventas-por-metodo")
def ventas_por_metodo(current_user: TokenData = Depends(get_current_user)):
    return reportes_controller.get_ventas_por_metodo()


@router.get("/clientes-activos")
def clientes_activos(current_user: TokenData = Depends(get_current_user)):
    return reportes_controller.get_clientes_activos()


@router.get("/productos-bajo-vendidos")
def productos_bajo_vendidos(current_user: TokenData = Depends(get_current_user)):
    return reportes_controller.get_productos_bajo_vendidos()


@router.get("/ventas-periodo")
def ventas_periodo(
    fecha_inicio: str = Query(..., description="Fecha inicio YYYY-MM-DD"),
    fecha_fin: str    = Query(..., description="Fecha fin YYYY-MM-DD"),
    current_user: TokenData = Depends(get_current_user),
):
    return reportes_controller.get_ventas_periodo(fecha_inicio, fecha_fin)
