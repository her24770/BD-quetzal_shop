from fastapi import APIRouter, Depends

from schemas.venta import VentaCreate, VentaResponse, VentaResumen
from dependencies import require_permission, get_current_user, TokenData
from controllers import venta as venta_controller

router = APIRouter()


@router.get("/", response_model=list[VentaResumen])
def listar(current_user: TokenData = Depends(require_permission("ventas", "SELECT"))):
    return venta_controller.get_all()


@router.get("/metodos-pago")
def metodos_pago(current_user: TokenData = Depends(require_permission("ventas", "INSERT"))):
    return venta_controller.get_metodos_pago()


@router.get("/{venta_id}", response_model=VentaResponse)
def obtener(venta_id: int, current_user: TokenData = Depends(require_permission("ventas", "SELECT"))):
    return venta_controller.get_by_id(venta_id)


@router.post("/", response_model=VentaResponse, status_code=201)
def crear(body: VentaCreate, current_user: TokenData = Depends(require_permission("ventas", "INSERT"))):
    return venta_controller.crear(body, current_user.empleado_id, current_user.rol_id)
