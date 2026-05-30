from fastapi import APIRouter, Depends

from schemas.cliente import ClienteCreate, ClienteUpdate, ClienteResponse
from dependencies import require_permission, require_admin, TokenData
from controllers import cliente as cliente_controller

router = APIRouter()


@router.get("/", response_model=list[ClienteResponse])
def listar(current_user: TokenData = Depends(require_permission("clientes", "SELECT"))):
    return cliente_controller.get_all()


@router.get("/nit/{nit}", response_model=ClienteResponse)
def buscar_por_nit(nit: str, current_user: TokenData = Depends(require_permission("clientes", "SELECT"))):
    return cliente_controller.get_by_nit(nit)


@router.get("/{cliente_id}", response_model=ClienteResponse)
def obtener(cliente_id: int, current_user: TokenData = Depends(require_permission("clientes", "SELECT"))):
    return cliente_controller.get_by_id(cliente_id)


@router.post("/", response_model=ClienteResponse, status_code=201)
def crear(body: ClienteCreate, current_user: TokenData = Depends(require_permission("clientes", "INSERT"))):
    return cliente_controller.create(body)


@router.patch("/{cliente_id}", response_model=ClienteResponse)
def actualizar(cliente_id: int, body: ClienteUpdate, current_user: TokenData = Depends(require_permission("clientes", "UPDATE"))):
    return cliente_controller.update(cliente_id, body)


@router.delete("/{cliente_id}")
def eliminar(cliente_id: int, current_user: TokenData = Depends(require_admin)):
    return cliente_controller.delete(cliente_id)
