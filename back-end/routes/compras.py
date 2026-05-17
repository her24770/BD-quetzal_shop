from fastapi import APIRouter, Depends

from schemas.compra import CompraCreate, CompraResponse, CompraResumen
from dependencies import get_current_user, TokenData
from controllers import compra as compra_controller

router = APIRouter()


@router.get("/", response_model=list[CompraResumen])
def listar(current_user: TokenData = Depends(get_current_user)):
    return compra_controller.get_all()


@router.get("/{compra_id}", response_model=CompraResponse)
def obtener(compra_id: int, current_user: TokenData = Depends(get_current_user)):
    return compra_controller.get_by_id(compra_id)


@router.post("/", response_model=CompraResponse, status_code=201)
def crear(body: CompraCreate, current_user: TokenData = Depends(get_current_user)):
    return compra_controller.crear(body, current_user.empleado_id, current_user.rol_id)
