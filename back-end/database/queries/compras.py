import json
from database.connection import get_connection, return_connection


# Trae el listado de compras con el nombre del empleado
def get_all() -> list[dict]:
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute("""
                SELECT c.id, c.fecha::text, c.total, c.numero_factura,
                       e.nombre AS empleado
                FROM compras c
                INNER JOIN empleados e ON c.empleado_id = e.id
                ORDER BY c.fecha DESC
            """)
            cols = [desc[0] for desc in cur.description]
            return [dict(zip(cols, row)) for row in cur.fetchall()]
    finally:
        return_connection(conn)


# Trae una compra completa con todos sus items por JOINs
def get_by_id(compra_id: int) -> dict | None:
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute("""
                SELECT c.id, c.empleado_id, e.nombre AS empleado_nombre,
                       c.fecha::text, c.total, c.numero_factura
                FROM compras c
                INNER JOIN empleados e ON c.empleado_id = e.id
                WHERE c.id = %s
            """, (compra_id,))
            row = cur.fetchone()
            if row is None:
                return None
            cols = [desc[0] for desc in cur.description]
            compra = dict(zip(cols, row))

            cur.execute("""
                SELECT ic.producto_id, p.nombre AS producto_nombre,
                       ic.proveedor_id, pr.nombre AS proveedor_nombre,
                       ic.cantidad, ic.precio_costo_historico, ic.subtotal
                FROM items_compra ic
                INNER JOIN productos  p  ON ic.producto_id  = p.id
                INNER JOIN proveedores pr ON ic.proveedor_id = pr.id
                WHERE ic.compra_id = %s
            """, (compra_id,))
            cols_items = [desc[0] for desc in cur.description]
            compra["items"] = [dict(zip(cols_items, r)) for r in cur.fetchall()]
            return compra
    finally:
        return_connection(conn)


# Delega a sp_registrar_compra — la transacción y el ROLLBACK viven en el SP
def crear(empleado_id: int, numero_factura: str, items: list, rol_id: int) -> dict:
    conn = get_connection(rol_id)
    try:
        conn.autocommit = True
        with conn.cursor() as cur:
            cur.execute(
                "CALL sp_registrar_compra(%s, %s, %s::jsonb, %s)",
                (empleado_id, numero_factura, json.dumps(items), None)
            )
            compra_id = cur.fetchone()[0]
        conn.autocommit = False
        return get_by_id(compra_id)
    except Exception:
        conn.autocommit = False
        raise
    finally:
        return_connection(conn, rol_id)
