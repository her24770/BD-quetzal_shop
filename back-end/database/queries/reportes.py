from database.connection import get_connection, return_connection


# Stats generales: usa GROUP BY + COUNT + SUM con FILTER para el dashboard
def get_stats() -> dict:
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute("""
                SELECT
                    COUNT(*)                                              AS ventas_hoy_count,
                    COALESCE(SUM(total), 0)                              AS ventas_hoy_total
                FROM ventas
                WHERE fecha::date = CURRENT_DATE
            """)
            row = cur.fetchone()
            v_hoy = {"count": int(row[0]), "total": float(row[1])}

            cur.execute("""
                SELECT COALESCE(SUM(total), 0)
                FROM compras
                WHERE fecha >= DATE_TRUNC('month', CURRENT_DATE)
            """)
            compras_mes = float(cur.fetchone()[0])

            cur.execute("SELECT COUNT(*) FROM v_stock_bajo")
            stock_bajo = int(cur.fetchone()[0])

            cur.execute("""
                SELECT
                    COUNT(*)                                      AS total,
                    COUNT(*) FILTER (WHERE estado = 'activo')     AS activos
                FROM empleados
            """)
            row = cur.fetchone()
            empleados = {"total": int(row[0]), "activos": int(row[1])}

            return {
                "ventas_hoy": v_hoy,
                "compras_mes": compras_mes,
                "stock_bajo": stock_bajo,
                "empleados": empleados,
            }
    finally:
        return_connection(conn)


# Top 5 productos más vendidos usando CTE + GROUP BY + JOIN
def get_top_productos() -> list[dict]:
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute("""
                WITH ventas_por_producto AS (
                    SELECT
                        producto_id,
                        SUM(cantidad)  AS total_vendido,
                        SUM(subtotal)  AS total_ingresos
                    FROM items_venta
                    GROUP BY producto_id
                )
                SELECT
                    p.nombre,
                    c.nombre       AS categoria,
                    v.total_vendido,
                    v.total_ingresos
                FROM ventas_por_producto v
                INNER JOIN productos  p ON v.producto_id   = p.id
                INNER JOIN categorias c ON p.categoria_id  = c.id
                ORDER BY v.total_vendido DESC
                LIMIT 5
            """)
            cols = [desc[0] for desc in cur.description]
            return [dict(zip(cols, row)) for row in cur.fetchall()]
    finally:
        return_connection(conn)


# Ventas agrupadas por método de pago — GROUP BY + HAVING
def get_ventas_por_metodo() -> list[dict]:
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute("""
                SELECT
                    mp.metodo,
                    COUNT(v.id)  AS cantidad,
                    SUM(v.total) AS total
                FROM ventas v
                INNER JOIN metodos_pago mp ON v.metodo_pago_id = mp.id
                GROUP BY mp.id, mp.metodo
                HAVING COUNT(v.id) > 0
                ORDER BY total DESC
            """)
            cols = [desc[0] for desc in cur.description]
            return [dict(zip(cols, row)) for row in cur.fetchall()]
    finally:
        return_connection(conn)


# Clientes que han realizado al menos una venta — subquery con EXISTS
def get_clientes_activos() -> list[dict]:
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute("""
                SELECT c.id, c.nombre, c.nit, c.telefono
                FROM clientes c
                WHERE EXISTS (
                    SELECT 1
                    FROM ventas v
                    WHERE v.cliente_id = c.id
                )
                ORDER BY c.nombre
            """)
            cols = [desc[0] for desc in cur.description]
            return [dict(zip(cols, row)) for row in cur.fetchall()]
    finally:
        return_connection(conn)


# Productos con stock bajo que han sido vendidos alguna vez — subquery con IN
def get_productos_bajo_vendidos() -> list[dict]:
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute("""
                SELECT
                    p.nombre,
                    p.stock,
                    p.stock_minimo,
                    c.nombre AS categoria
                FROM productos p
                INNER JOIN categorias c ON p.categoria_id = c.id
                WHERE p.stock <= p.stock_minimo
                  AND p.id IN (
                      SELECT DISTINCT producto_id
                      FROM items_venta
                  )
                ORDER BY p.stock ASC
            """)
            cols = [desc[0] for desc in cur.description]
            return [dict(zip(cols, row)) for row in cur.fetchall()]
    finally:
        return_connection(conn)


# Llama a sp_reporte_ventas_periodo para agregar ventas diarias en un rango de fechas
def get_ventas_periodo(fecha_inicio: str, fecha_fin: str) -> list[dict]:
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute(
                "SELECT * FROM sp_reporte_ventas_periodo(%s, %s)",
                (fecha_inicio, fecha_fin)
            )
            cols = [desc[0] for desc in cur.description]
            return [dict(zip(cols, row)) for row in cur.fetchall()]
    finally:
        return_connection(conn)
