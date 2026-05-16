from fastapi import APIRouter, Depends

from schemas.empleado import EmpleadoCreate, EmpleadoUpdate, EmpleadoResponse
from dependencies import require_role, TokenData
from controllers import empleado as empleado_controller

router = APIRouter()


# GET /empleados — lista todos los empleados (solo admin)
@router.get("/", response_model=list[EmpleadoResponse])
def listar(current_user: TokenData = Depends(require_role(1))):
    return empleado_controller.get_all()


# GET /empleados/{id} — obtiene un empleado por ID (solo admin)
@router.get("/{empleado_id}", response_model=EmpleadoResponse)
def obtener(empleado_id: int, current_user: TokenData = Depends(require_role(1))):
    return empleado_controller.get_by_id(empleado_id)


# POST /empleados — registra un nuevo empleado via SP (solo admin)
@router.post("/", response_model=EmpleadoResponse, status_code=201)
def crear(body: EmpleadoCreate, current_user: TokenData = Depends(require_role(1))):
    return empleado_controller.create(body, current_user.rol_id)


# PATCH /empleados/{id} — actualiza telefono, cargo o estado del empleado (solo admin)
@router.patch("/{empleado_id}", response_model=EmpleadoResponse)
def actualizar(empleado_id: int, body: EmpleadoUpdate, current_user: TokenData = Depends(require_role(1))):
    return empleado_controller.update(empleado_id, body)


# DELETE /empleados/{id} — elimina un empleado (solo admin)
@router.delete("/{empleado_id}")
def eliminar(empleado_id: int, current_user: TokenData = Depends(require_role(1))):
    return empleado_controller.delete(empleado_id)
