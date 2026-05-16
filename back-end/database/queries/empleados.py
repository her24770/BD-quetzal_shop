from database.connection import get_connection, return_connection
from database.orm import get_session
from database.models.empleado import Empleado


# JOIN a 3 tablas (empleados + usuarios + roles) — consulta avanzada, se mantiene en SQL
def get_all() -> list[dict]:
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute("""
                SELECT e.id, e.usuario_id, e.dpi, e.nombre, e.telefono, e.cargo,
                       e.fecha_contrato::text, e.estado,
                       u.email, r.nombre AS rol_nombre
                FROM empleados e
                INNER JOIN usuarios u ON e.usuario_id = u.id
                INNER JOIN roles r    ON u.rol_id     = r.id
                ORDER BY e.nombre
            """)
            cols = [desc[0] for desc in cur.description]
            return [dict(zip(cols, row)) for row in cur.fetchall()]
    finally:
        return_connection(conn)


def get_by_id(empleado_id: int) -> dict | None:
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute("""
                SELECT e.id, e.usuario_id, e.dpi, e.nombre, e.telefono, e.cargo,
                       e.fecha_contrato::text, e.estado,
                       u.email, r.nombre AS rol_nombre
                FROM empleados e
                INNER JOIN usuarios u ON e.usuario_id = u.id
                INNER JOIN roles r    ON u.rol_id     = r.id
                WHERE e.id = %s
            """, (empleado_id,))
            row = cur.fetchone()
            if row is None:
                return None
            cols = [desc[0] for desc in cur.description]
            return dict(zip(cols, row))
    finally:
        return_connection(conn)


# Delega a sp_crear_empleado — garantiza que usuario y empleado se crean juntos o ninguno
def create(email: str, password_hash: str, rol_id_empleado: int, dpi: str, nombre: str,
           telefono: str, cargo: str, fecha_contrato: str, rol_id: int) -> dict:
    conn = get_connection(rol_id)
    try:
        conn.autocommit = True
        with conn.cursor() as cur:
            cur.execute(
                "CALL sp_crear_empleado(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)",
                (email, password_hash, rol_id_empleado, dpi, nombre, telefono, cargo, fecha_contrato, None, None)
            )
            row = cur.fetchone()
            empleado_id = row[1]
        conn.autocommit = False
        return get_by_id(empleado_id)
    except Exception:
        conn.autocommit = False
        raise
    finally:
        return_connection(conn, rol_id)


def update(empleado_id: int, campos: dict) -> dict | None:
    if not campos:
        return get_by_id(empleado_id)
    with get_session() as session:
        empleado = session.get(Empleado, empleado_id)
        if empleado is None:
            return None
        for key, value in campos.items():
            setattr(empleado, key, value)
        session.add(empleado)
        session.commit()
    return get_by_id(empleado_id)


def delete(empleado_id: int) -> bool:
    with get_session() as session:
        empleado = session.get(Empleado, empleado_id)
        if empleado is None:
            return False
        try:
            session.delete(empleado)
            session.commit()
            return True
        except Exception as e:
            session.rollback()
            if "foreign key" in str(e).lower() or "violates" in str(e).lower():
                raise ValueError("No se puede eliminar: el empleado tiene ventas o compras registradas")
            raise
