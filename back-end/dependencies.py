from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from jose import JWTError, jwt
from datetime import datetime, timedelta
from config import settings

security = HTTPBearer()

# Estructura que representa al usuario autenticado extraído del JWT
class TokenData:
    def __init__(self, user_id: int, email: str, rol_id: int, empleado_id: int = None):
        self.user_id = user_id
        self.email = email
        self.rol_id = rol_id
        self.empleado_id = empleado_id

# Genera un JWT firmado con los datos del usuario y tiempo de expiración
def create_access_token(data: dict, expires_delta: timedelta = None) -> str:
    to_encode = data.copy()

    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(hours=settings.JWT_EXPIRE_HOURS)

    to_encode.update({"exp": expire})

    encoded_jwt = jwt.encode(
        to_encode,
        settings.JWT_SECRET,
        algorithm=settings.JWT_ALGORITHM
    )
    return encoded_jwt

# Decodifica y valida el JWT del header Authorization — lanza 401 si es inválido o expirado
async def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security)) -> TokenData:
    token = credentials.credentials

    try:
        payload = jwt.decode(
            token,
            settings.JWT_SECRET,
            algorithms=[settings.JWT_ALGORITHM]
        )
        user_id: int = payload.get("user_id")
        email: str = payload.get("email")
        rol_id: int = payload.get("rol_id")
        empleado_id: int = payload.get("empleado_id")

        if user_id is None or email is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Token inválido: datos faltantes",
                headers={"WWW-Authenticate": "Bearer"},
            )

        return TokenData(
            user_id=user_id,
            email=email,
            rol_id=rol_id,
            empleado_id=empleado_id
        )

    except JWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token inválido o expirado",
            headers={"WWW-Authenticate": "Bearer"},
        )

# Dependencia para rutas exclusivas del Admin (rol_id=1)
def require_admin(current_user: TokenData = Depends(get_current_user)) -> TokenData:
    if current_user.rol_id != 1:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Solo el administrador puede acceder a este recurso"
        )
    return current_user

# Dependencia de roles múltiples — verifica que el usuario tenga alguno de los roles permitidos
def require_role(*allowed_roles: int):
    async def role_checker(current_user: TokenData = Depends(get_current_user)) -> TokenData:
        if current_user.rol_id not in allowed_roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="No tienes permiso para acceder a este recurso"
            )
        return current_user
    return role_checker

# Dependencia dinámica — consulta los permisos reales del rol en PostgreSQL.
# Si el admin cambia permisos desde el dashboard, este check lo refleja de inmediato.
def require_permission(tabla: str, operacion: str):
    async def checker(current_user: TokenData = Depends(get_current_user)) -> TokenData:
        from database.queries.permisos import get_permisos_rol
        permisos = get_permisos_rol(current_user.rol_id)
        if operacion not in permisos.get(tabla, []):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Tu rol no tiene permiso de {operacion} en {tabla}"
            )
        return current_user
    return checker
