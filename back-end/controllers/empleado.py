from fastapi import HTTPException, status
from passlib.context import CryptContext
from database.queries import empleados as empleados_query
from schemas.empleado import EmpleadoCreate, EmpleadoUpdate, EmpleadoResponse

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


# Retorna la lista completa de empleados con su email y rol
def get_all() -> list[EmpleadoResponse]:
    return empleados_query.get_all()


# Busca un empleado por ID y lanza 404 si no existe
def get_by_id(empleado_id: int) -> EmpleadoResponse:
    empleado = empleados_query.get_by_id(empleado_id)
    if empleado is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Empleado no encontrado")
    return empleado


# Crea un usuario y su empleado en una sola transacción — rol_id del token para el pool de BD
def create(body: EmpleadoCreate, rol_id: int) -> EmpleadoResponse:
    try:
        return empleados_query.create(
            body.email,
            pwd_context.hash(body.password),
            body.rol_id,
            body.dpi,
            body.nombre,
            body.telefono,
            body.cargo,
            body.fecha_contrato,
            rol_id,
        )
    except Exception as e:
        if "unique" in str(e).lower() and "email" in str(e).lower():
            raise HTTPException(status_code=409, detail="Ya existe un usuario con ese email")
        if "unique" in str(e).lower() and "dpi" in str(e).lower():
            raise HTTPException(status_code=409, detail="Ya existe un empleado con ese DPI")
        raise HTTPException(status_code=500, detail="Error al crear el empleado")


# Actualiza solo los campos que vienen en el body (solo telefono, cargo y estado son editables)
def update(empleado_id: int, body: EmpleadoUpdate) -> EmpleadoResponse:
    campos = {k: v for k, v in body.model_dump().items() if v is not None}
    empleado = empleados_query.update(empleado_id, campos)
    if empleado is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Empleado no encontrado")
    return empleado


# Elimina un empleado; lanza 404 si no existe y 409 si tiene ventas o compras registradas
def delete(empleado_id: int) -> dict:
    try:
        eliminado = empleados_query.delete(empleado_id)
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail=str(e))
    if not eliminado:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Empleado no encontrado")
    return {"message": "Empleado eliminado correctamente"}
