from fastapi import APIRouter, Depends

from schemas.proveedor import ProveedorCreate, ProveedorUpdate, ProveedorResponse
from dependencies import require_permission, require_admin, TokenData
from controllers import proveedor as proveedor_controller

router = APIRouter()


@router.get("/", response_model=list[ProveedorResponse])
def listar(current_user: TokenData = Depends(require_permission("proveedores", "SELECT"))):
    return proveedor_controller.get_all()


@router.get("/{proveedor_id}", response_model=ProveedorResponse)
def obtener(proveedor_id: int, current_user: TokenData = Depends(require_permission("proveedores", "SELECT"))):
    return proveedor_controller.get_by_id(proveedor_id)


@router.get("/{proveedor_id}/productos")
def productos(proveedor_id: int, current_user: TokenData = Depends(require_permission("proveedores", "SELECT"))):
    return proveedor_controller.get_productos(proveedor_id)


@router.post("/", response_model=ProveedorResponse, status_code=201)
def crear(body: ProveedorCreate, current_user: TokenData = Depends(require_permission("proveedores", "INSERT"))):
    return proveedor_controller.create(body)


@router.patch("/{proveedor_id}", response_model=ProveedorResponse)
def actualizar(proveedor_id: int, body: ProveedorUpdate, current_user: TokenData = Depends(require_permission("proveedores", "UPDATE"))):
    return proveedor_controller.update(proveedor_id, body)


@router.delete("/{proveedor_id}")
def eliminar(proveedor_id: int, current_user: TokenData = Depends(require_admin)):
    return proveedor_controller.delete(proveedor_id)
