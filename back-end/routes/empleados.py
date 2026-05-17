from fastapi import APIRouter, Depends

from schemas.empleado import EmpleadoCreate, EmpleadoUpdate, EmpleadoResponse
from dependencies import get_current_user, TokenData
from controllers import empleado as empleado_controller

router = APIRouter()


@router.get("/", response_model=list[EmpleadoResponse])
def listar(current_user: TokenData = Depends(get_current_user)):
    return empleado_controller.get_all()


@router.get("/{empleado_id}", response_model=EmpleadoResponse)
def obtener(empleado_id: int, current_user: TokenData = Depends(get_current_user)):
    return empleado_controller.get_by_id(empleado_id)


@router.post("/", response_model=EmpleadoResponse, status_code=201)
def crear(body: EmpleadoCreate, current_user: TokenData = Depends(get_current_user)):
    return empleado_controller.create(body, current_user.rol_id)


@router.patch("/{empleado_id}", response_model=EmpleadoResponse)
def actualizar(empleado_id: int, body: EmpleadoUpdate, current_user: TokenData = Depends(get_current_user)):
    return empleado_controller.update(empleado_id, body)


@router.delete("/{empleado_id}")
def eliminar(empleado_id: int, current_user: TokenData = Depends(get_current_user)):
    return empleado_controller.delete(empleado_id)
