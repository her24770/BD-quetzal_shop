from database.connection import get_connection, return_connection

ROL_USUARIO_PG = {
    1: 'qs_admin',
    2: 'qs_cajero',
    3: 'qs_bodeguero',
    4: 'qs_gerente',
    5: 'qs_auditor',
}


def get_permisos_rol(rol_id: int) -> dict:
    pg_user = ROL_USUARIO_PG.get(rol_id)
    if not pg_user:
        return {}
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute("""
                SELECT table_name, privilege_type
                FROM information_schema.role_table_grants
                WHERE grantee = %s
                  AND table_schema = 'public'
                  AND privilege_type IN ('SELECT','INSERT','UPDATE','DELETE')
                ORDER BY table_name
            """, (pg_user,))
            result: dict = {}
            for table_name, privilege_type in cur.fetchall():
                result.setdefault(table_name, []).append(privilege_type)
            return result
    finally:
        return_connection(conn)
