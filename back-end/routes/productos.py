from fastapi import APIRouter, Depends

from schemas.producto import ProductoCreate, ProductoUpdate, ProductoResponse, StockUpdate
from dependencies import get_current_user, TokenData
from controllers import producto as producto_controller

router = APIRouter()


@router.get("/", response_model=list[ProductoResponse])
def listar(current_user: TokenData = Depends(get_current_user)):
    return producto_controller.get_all()


@router.get("/stock-bajo", response_model=list[ProductoResponse])
def stock_bajo(current_user: TokenData = Depends(get_current_user)):
    return producto_controller.get_stock_bajo()


@router.get("/{producto_id}", response_model=ProductoResponse)
def obtener(producto_id: int, current_user: TokenData = Depends(get_current_user)):
    return producto_controller.get_by_id(producto_id)


@router.post("/", response_model=ProductoResponse, status_code=201)
def crear(body: ProductoCreate, current_user: TokenData = Depends(get_current_user)):
    return producto_controller.create(body)


@router.patch("/{producto_id}", response_model=ProductoResponse)
def actualizar(producto_id: int, body: ProductoUpdate, current_user: TokenData = Depends(get_current_user)):
    return producto_controller.update(producto_id, body)


@router.delete("/{producto_id}")
def eliminar(producto_id: int, current_user: TokenData = Depends(get_current_user)):
    return producto_controller.delete(producto_id, current_user.rol_id)


@router.patch("/{producto_id}/stock")
def ajustar_stock(producto_id: int, body: StockUpdate, current_user: TokenData = Depends(get_current_user)):
    return producto_controller.actualizar_stock(producto_id, body, current_user.rol_id)
