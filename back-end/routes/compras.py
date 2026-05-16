from fastapi import APIRouter, Depends

from schemas.compra import CompraCreate, CompraResponse, CompraResumen
from dependencies import require_role, TokenData
from controllers import compra as compra_controller

router = APIRouter()


# GET /compras — lista todas las compras resumidas (admin y bodeguero)
@router.get("/", response_model=list[CompraResumen])
def listar(current_user: TokenData = Depends(require_role(1, 3))):
    return compra_controller.get_all()


# GET /compras/{id} — obtiene una compra completa con sus items (admin y bodeguero)
@router.get("/{compra_id}", response_model=CompraResponse)
def obtener(compra_id: int, current_user: TokenData = Depends(require_role(1, 3))):
    return compra_controller.get_by_id(compra_id)


# POST /compras — registra una nueva compra via SP (admin y bodeguero)
# empleado_id y rol_id se toman del token para identificar quién compró y qué pool usar
@router.post("/", response_model=CompraResponse, status_code=201)
def crear(body: CompraCreate, current_user: TokenData = Depends(require_role(1, 3))):
    return compra_controller.crear(body, current_user.empleado_id, current_user.rol_id)
