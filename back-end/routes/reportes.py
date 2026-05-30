from fastapi import APIRouter, Depends, Query

from dependencies import get_current_user, require_permission, TokenData
from controllers import reportes as reportes_controller

router = APIRouter()


# stats filtra los datos según los permisos reales del rol en PostgreSQL
@router.get("/stats")
def stats(current_user: TokenData = Depends(get_current_user)):
    from database.queries.permisos import get_permisos_rol
    permisos = get_permisos_rol(current_user.rol_id)
    return reportes_controller.get_stats(permisos)


# top-productos consulta datos de productos y ventas
@router.get("/top-productos")
def top_productos(current_user: TokenData = Depends(require_permission("productos", "SELECT"))):
    return reportes_controller.get_top_productos()


# ventas-por-metodo consulta datos de ventas
@router.get("/ventas-por-metodo")
def ventas_por_metodo(current_user: TokenData = Depends(require_permission("ventas", "SELECT"))):
    return reportes_controller.get_ventas_por_metodo()


# clientes-activos consulta datos de clientes
@router.get("/clientes-activos")
def clientes_activos(current_user: TokenData = Depends(require_permission("clientes", "SELECT"))):
    return reportes_controller.get_clientes_activos()


# productos-bajo-vendidos consulta datos de productos
@router.get("/productos-bajo-vendidos")
def productos_bajo_vendidos(current_user: TokenData = Depends(require_permission("productos", "SELECT"))):
    return reportes_controller.get_productos_bajo_vendidos()


# ventas-periodo usa el SP sp_reporte_ventas_periodo — requiere acceso a ventas
@router.get("/ventas-periodo")
def ventas_periodo(
    fecha_inicio: str = Query(..., description="Fecha inicio YYYY-MM-DD"),
    fecha_fin: str    = Query(..., description="Fecha fin YYYY-MM-DD"),
    current_user: TokenData = Depends(require_permission("ventas", "SELECT")),
):
    return reportes_controller.get_ventas_periodo(fecha_inicio, fecha_fin)
