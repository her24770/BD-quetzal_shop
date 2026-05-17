from fastapi import APIRouter, Depends
from pydantic import BaseModel
from dependencies import require_role, TokenData
from controllers import admin as admin_controller

router = APIRouter()


class PermisoBody(BaseModel):
    tabla:     str
    operacion: str


@router.get('/roles')
def listar_roles(current_user: TokenData = Depends(require_role(1))):
    return admin_controller.get_roles()


@router.get('/roles/{rol_id}/permisos')
def get_permisos(rol_id: int, current_user: TokenData = Depends(require_role(1))):
    return admin_controller.get_permisos_rol(rol_id)


@router.post('/roles/{rol_id}/permisos')
def grant(rol_id: int, body: PermisoBody, current_user: TokenData = Depends(require_role(1))):
    return admin_controller.grant_permiso(rol_id, body.tabla, body.operacion)


@router.delete('/roles/{rol_id}/permisos/{tabla}/{operacion}')
def revoke(rol_id: int, tabla: str, operacion: str, current_user: TokenData = Depends(require_role(1))):
    return admin_controller.revoke_permiso(rol_id, tabla, operacion)
