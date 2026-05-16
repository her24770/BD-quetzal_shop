from fastapi import APIRouter, Depends

from schemas.producto import ProductoCreate, ProductoUpdate, ProductoResponse, StockUpdate
from dependencies import require_role, TokenData
from controllers import producto as producto_controller

router = APIRouter()


# GET /productos — lista todos los productos con su categoría (todos los roles)
@router.get("/", response_model=list[ProductoResponse])
def listar(current_user: TokenData = Depends(require_role(1, 2, 3))):
    return producto_controller.get_all()


# GET /productos/stock-bajo — productos con stock en o bajo el mínimo (todos los roles)
@router.get("/stock-bajo", response_model=list[ProductoResponse])
def stock_bajo(current_user: TokenData = Depends(require_role(1, 2, 3))):
    return producto_controller.get_stock_bajo()


# GET /productos/{id} — obtiene un producto por ID (todos los roles)
@router.get("/{producto_id}", response_model=ProductoResponse)
def obtener(producto_id: int, current_user: TokenData = Depends(require_role(1, 2, 3))):
    return producto_controller.get_by_id(producto_id)


# POST /productos — crea un nuevo producto (admin y bodeguero)
@router.post("/", response_model=ProductoResponse, status_code=201)
def crear(body: ProductoCreate, current_user: TokenData = Depends(require_role(1, 3))):
    return producto_controller.create(body)


# PATCH /productos/{id} — actualiza parcialmente un producto (admin y bodeguero)
@router.patch("/{producto_id}", response_model=ProductoResponse)
def actualizar(producto_id: int, body: ProductoUpdate, current_user: TokenData = Depends(require_role(1, 3))):
    return producto_controller.update(producto_id, body)


# DELETE /productos/{id} — elimina un producto via SP (solo admin)
@router.delete("/{producto_id}")
def eliminar(producto_id: int, current_user: TokenData = Depends(require_role(1))):
    return producto_controller.delete(producto_id, current_user.rol_id)


# PATCH /productos/{id}/stock — ajusta el stock via sp_actualizar_stock (admin y bodeguero)
@router.patch("/{producto_id}/stock")
def ajustar_stock(producto_id: int, body: StockUpdate, current_user: TokenData = Depends(require_role(1, 3))):
    return producto_controller.actualizar_stock(producto_id, body, current_user.rol_id)
