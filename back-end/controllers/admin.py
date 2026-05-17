from fastapi import HTTPException
from database.connection import get_connection, return_connection

ROL_USUARIO_PG: dict[int, tuple[str, str]] = {
    1: ('qs_admin',     'Admin'),
    2: ('qs_cajero',    'Cajero'),
    3: ('qs_bodeguero', 'Bodeguero'),
    4: ('qs_gerente',   'Gerente'),
    5: ('qs_auditor',   'Auditor'),
}

TABLAS = ['categorias', 'productos', 'proveedores', 'clientes', 'empleados', 'ventas', 'compras']


def get_roles() -> list[dict]:
    return [
        {'id': rid, 'nombre': nombre, 'pg_user': pg_user}
        for rid, (pg_user, nombre) in ROL_USUARIO_PG.items()
    ]


def get_permisos_rol(rol_id: int) -> dict:
    entry = ROL_USUARIO_PG.get(rol_id)
    if not entry:
        raise HTTPException(status_code=404, detail='Rol no encontrado')
    pg_user, _ = entry
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute("""
                SELECT table_name, privilege_type
                FROM information_schema.role_table_grants
                WHERE grantee = %s
                  AND table_schema = 'public'
                  AND table_name = ANY(%s)
                  AND privilege_type IN ('SELECT','INSERT','UPDATE','DELETE')
                ORDER BY table_name
            """, (pg_user, TABLAS))
            result: dict = {}
            for table_name, privilege_type in cur.fetchall():
                result.setdefault(table_name, []).append(privilege_type)
            return result
    finally:
        return_connection(conn)


def grant_permiso(rol_id: int, tabla: str, operacion: str) -> dict:
    entry = ROL_USUARIO_PG.get(rol_id)
    if not entry:
        raise HTTPException(status_code=404, detail='Rol no encontrado')
    pg_user, _ = entry
    conn = get_connection(1)
    try:
        conn.autocommit = True
        with conn.cursor() as cur:
            cur.execute('CALL sp_grant_permiso_rol(%s, %s, %s, %s)', (pg_user, tabla, operacion, None))
            row = cur.fetchone()
        conn.autocommit = False
        return {'message': row[0] if row else 'OK'}
    except Exception as e:
        conn.autocommit = False
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        return_connection(conn, 1)


def revoke_permiso(rol_id: int, tabla: str, operacion: str) -> dict:
    entry = ROL_USUARIO_PG.get(rol_id)
    if not entry:
        raise HTTPException(status_code=404, detail='Rol no encontrado')
    pg_user, _ = entry
    conn = get_connection(1)
    try:
        conn.autocommit = True
        with conn.cursor() as cur:
            cur.execute('CALL sp_revoke_permiso_rol(%s, %s, %s, %s)', (pg_user, tabla, operacion, None))
            row = cur.fetchone()
        conn.autocommit = False
        return {'message': row[0] if row else 'OK'}
    except Exception as e:
        conn.autocommit = False
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        return_connection(conn, 1)
