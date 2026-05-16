from fastapi import APIRouter, Depends, Query

from dependencies import require_role, TokenData
from controllers import reportes as reportes_controller

router = APIRouter()


# GET /reportes/stats — stats del dashboard (todos los roles)
@router.get("/stats")
def stats(current_user: TokenData = Depends(require_role(1, 2, 3))):
    return reportes_controller.get_stats()


# GET /reportes/top-productos — top 5 por unidades vendidas usando CTE (todos los roles)
@router.get("/top-productos")
def top_productos(current_user: TokenData = Depends(require_role(1, 2, 3))):
    return reportes_controller.get_top_productos()


# GET /reportes/ventas-por-metodo — ventas agrupadas por método de pago (admin y cajero)
@router.get("/ventas-por-metodo")
def ventas_por_metodo(current_user: TokenData = Depends(require_role(1, 2))):
    return reportes_controller.get_ventas_por_metodo()


# GET /reportes/clientes-activos — clientes con al menos 1 venta usando EXISTS (admin y cajero)
@router.get("/clientes-activos")
def clientes_activos(current_user: TokenData = Depends(require_role(1, 2))):
    return reportes_controller.get_clientes_activos()


# GET /reportes/productos-bajo-vendidos — stock bajo que también han sido vendidos usando IN (todos)
@router.get("/productos-bajo-vendidos")
def productos_bajo_vendidos(current_user: TokenData = Depends(require_role(1, 2, 3))):
    return reportes_controller.get_productos_bajo_vendidos()


# GET /reportes/ventas-periodo — agrega ventas diarias via SP en un rango de fechas (admin y gerente)
@router.get("/ventas-periodo")
def ventas_periodo(
    fecha_inicio: str = Query(..., description="Fecha inicio YYYY-MM-DD"),
    fecha_fin: str = Query(..., description="Fecha fin YYYY-MM-DD"),
    current_user: TokenData = Depends(require_role(1, 4)),
):
    return reportes_controller.get_ventas_periodo(fecha_inicio, fecha_fin)
