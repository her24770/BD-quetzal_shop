import psycopg2
from psycopg2 import pool
from config import settings


def _make_pool(user: str, password: str) -> psycopg2.pool.SimpleConnectionPool:
    return psycopg2.pool.SimpleConnectionPool(
        minconn=1,
        maxconn=10,
        host=settings.DB_HOST,
        port=settings.DB_PORT,
        database=settings.DB_NAME,
        user=user,
        password=password,
    )


# Pool owner — solo para migraciones o rutas internas que no dependen de rol
_owner_pool = _make_pool(settings.DB_USER, settings.DB_PASSWORD)

# 5 pools — uno por rol de PostgreSQL (el API los usa en runtime)
_role_pools: dict[int, psycopg2.pool.SimpleConnectionPool] = {
    1: _make_pool("qs_admin",     settings.DB_ADMIN_PASSWORD),
    2: _make_pool("qs_cajero",    settings.DB_CAJERO_PASSWORD),
    3: _make_pool("qs_bodeguero", settings.DB_BODEGUERO_PASSWORD),
    4: _make_pool("qs_gerente",   settings.DB_GERENTE_PASSWORD),
    5: _make_pool("qs_auditor",   settings.DB_AUDITOR_PASSWORD),
}


def get_connection(rol_id: int | None = None):
    """
    Devuelve una conexión del pool correspondiente al rol.
    Si no se pasa rol_id (rutas de auth/login), usa el pool owner.
    """
    if rol_id is None or rol_id not in _role_pools:
        return _owner_pool.getconn()
    return _role_pools[rol_id].getconn()


def return_connection(conn, rol_id: int | None = None):
    """Devuelve la conexión al pool correcto."""
    if rol_id is None or rol_id not in _role_pools:
        _owner_pool.putconn(conn)
    else:
        _role_pools[rol_id].putconn(conn)


def close_all_connections():
    """Cierra todos los pools (útil en shutdown)."""
    _owner_pool.closeall()
    for p in _role_pools.values():
        p.closeall()
