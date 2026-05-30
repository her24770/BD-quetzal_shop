from fastapi import HTTPException, status
import psycopg2
from database.queries import productos as productos_query
from schemas.producto import ProductoCreate, ProductoUpdate, ProductoResponse, StockUpdate


# Retorna la lista completa de productos con su categoría
def get_all() -> list[ProductoResponse]:
    return productos_query.get_all()


# Busca un producto por ID y lanza 404 si no existe
def get_by_id(producto_id: int) -> ProductoResponse:
    producto = productos_query.get_by_id(producto_id)
    if producto is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Producto no encontrado")
    return producto


# Retorna productos cuyo stock está en o por debajo del mínimo
def get_stock_bajo() -> list[ProductoResponse]:
    return productos_query.get_stock_bajo()


# Crea un nuevo producto con los datos del body
def create(body: ProductoCreate) -> ProductoResponse:
    return productos_query.create(
        body.nombre,
        body.descripcion,
        body.precio,
        body.stock,
        body.stock_minimo,
        body.categoria_id,
    )


# Actualiza solo los campos que vienen en el body (ignora los None)
def update(producto_id: int, body: ProductoUpdate) -> ProductoResponse:
    campos = {k: v for k, v in body.model_dump().items() if v is not None}
    producto = productos_query.update(producto_id, campos)
    if producto is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Producto no encontrado")
    return producto


# Elimina un producto via SP — rol_id del token selecciona el pool de BD
def delete(producto_id: int, rol_id: int) -> dict:
    try:
        eliminado = productos_query.delete(producto_id, rol_id)
    except (ValueError, psycopg2.Error) as e:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail=str(e).split('\n')[0])
    if not eliminado:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Producto no encontrado")
    return {"message": "Producto eliminado correctamente"}


# Ajusta el stock via sp_actualizar_stock — incrementar o decrementar
def actualizar_stock(producto_id: int, body: StockUpdate, rol_id: int) -> dict:
    try:
        return productos_query.actualizar_stock(producto_id, body.cantidad, body.operacion, rol_id)
    except (ValueError, psycopg2.Error) as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e).split('\n')[0])
