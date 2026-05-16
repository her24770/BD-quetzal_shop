import json
from database.connection import get_connection, return_connection


# Trae el listado de ventas usando la vista v_ventas_completo
def get_all() -> list[dict]:
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute("""
                SELECT id, fecha::text, total, descuento,
                       cliente, nit, empleado, metodo_pago
                FROM v_ventas_completo
                ORDER BY fecha DESC
            """)
            cols = [desc[0] for desc in cur.description]
            return [dict(zip(cols, row)) for row in cur.fetchall()]
    finally:
        return_connection(conn)


# Trae una venta completa con todos sus items por JOINs
def get_by_id(venta_id: int) -> dict | None:
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute("""
                SELECT v.id, v.cliente_id, cl.nombre AS cliente_nombre,
                       v.empleado_id, e.nombre AS empleado_nombre,
                       v.metodo_pago_id, mp.metodo AS metodo_pago,
                       v.fecha::text, v.total, v.descuento
                FROM ventas v
                INNER JOIN clientes cl      ON v.cliente_id     = cl.id
                INNER JOIN empleados e      ON v.empleado_id    = e.id
                INNER JOIN metodos_pago mp  ON v.metodo_pago_id = mp.id
                WHERE v.id = %s
            """, (venta_id,))
            row = cur.fetchone()
            if row is None:
                return None
            cols = [desc[0] for desc in cur.description]
            venta = dict(zip(cols, row))

            cur.execute("""
                SELECT iv.producto_id, p.nombre AS producto_nombre,
                       iv.cantidad, iv.precio_unitario_historico, iv.subtotal
                FROM items_venta iv
                INNER JOIN productos p ON iv.producto_id = p.id
                WHERE iv.venta_id = %s
            """, (venta_id,))
            cols_items = [desc[0] for desc in cur.description]
            venta["items"] = [dict(zip(cols_items, r)) for r in cur.fetchall()]
            return venta
    finally:
        return_connection(conn)


# Delega a sp_registrar_venta — la transacción y el ROLLBACK viven en el SP
def crear(cliente_id: int, empleado_id: int, metodo_pago_id: int, descuento: float, items: list, rol_id: int) -> dict:
    conn = get_connection(rol_id)
    try:
        conn.autocommit = True
        with conn.cursor() as cur:
            cur.execute(
                "CALL sp_registrar_venta(%s, %s, %s, %s, %s::jsonb, %s)",
                (cliente_id, empleado_id, metodo_pago_id, descuento, json.dumps(items), None)
            )
            venta_id = cur.fetchone()[0]
        conn.autocommit = False
        return get_by_id(venta_id)
    except Exception:
        conn.autocommit = False
        raise
    finally:
        return_connection(conn, rol_id)
