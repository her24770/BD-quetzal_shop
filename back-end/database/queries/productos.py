from database.connection import get_connection, return_connection


# Trae todos los productos con su categoría por JOIN
def get_all() -> list[dict]:
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute("""
                SELECT p.id, p.nombre, p.descripcion, p.precio, p.stock, p.stock_minimo,
                       p.categoria_id, c.nombre AS categoria
                FROM productos p
                INNER JOIN categorias c ON p.categoria_id = c.id
                ORDER BY p.nombre
            """)
            cols = [desc[0] for desc in cur.description]
            return [dict(zip(cols, row)) for row in cur.fetchall()]
    finally:
        return_connection(conn)


# Busca un producto por ID con su categoría, retorna None si no existe
def get_by_id(producto_id: int) -> dict | None:
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute("""
                SELECT p.id, p.nombre, p.descripcion, p.precio, p.stock, p.stock_minimo,
                       p.categoria_id, c.nombre AS categoria
                FROM productos p
                INNER JOIN categorias c ON p.categoria_id = c.id
                WHERE p.id = %s
            """, (producto_id,))
            row = cur.fetchone()
            if row is None:
                return None
            cols = [desc[0] for desc in cur.description]
            return dict(zip(cols, row))
    finally:
        return_connection(conn)


# Usa la vista v_stock_bajo para traer productos con stock crítico
def get_stock_bajo() -> list[dict]:
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute("SELECT id, nombre, stock, stock_minimo, categoria FROM v_stock_bajo")
            cols = [desc[0] for desc in cur.description]
            return [dict(zip(cols, row)) for row in cur.fetchall()]
    finally:
        return_connection(conn)


# Inserta un producto y retorna el registro completo con JOIN a categoría
def create(nombre: str, descripcion: str, precio: float, stock: int, stock_minimo: int, categoria_id: int) -> dict:
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute("""
                INSERT INTO productos (nombre, descripcion, precio, stock, stock_minimo, categoria_id)
                VALUES (%s, %s, %s, %s, %s, %s)
                RETURNING id
            """, (nombre, descripcion, precio, stock, stock_minimo, categoria_id))
            conn.commit()
            producto_id = cur.fetchone()[0]
        return get_by_id(producto_id)
    finally:
        return_connection(conn)


# Actualiza solo los campos recibidos y retorna el producto actualizado
def update(producto_id: int, campos: dict) -> dict | None:
    if not campos:
        return get_by_id(producto_id)

    sets = ", ".join(f"{k} = %s" for k in campos)
    valores = list(campos.values()) + [producto_id]

    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute(f"UPDATE productos SET {sets} WHERE id = %s", valores)
            conn.commit()
            if cur.rowcount == 0:
                return None
        return get_by_id(producto_id)
    finally:
        return_connection(conn)


# Delega a sp_eliminar_producto — captura FK sin explotar, retorna mensaje en p_resultado
def delete(producto_id: int, rol_id: int) -> bool:
    conn = get_connection(rol_id)
    try:
        with conn.cursor() as cur:
            cur.execute("CALL sp_eliminar_producto(%s, %s)", (producto_id, None))
            resultado = cur.fetchone()[0]
        conn.commit()
        if resultado == 'OK':
            return True
        if resultado == 'NOT_FOUND':
            return False
        raise ValueError(resultado)
    except ValueError:
        conn.rollback()
        raise
    except Exception:
        conn.rollback()
        raise
    finally:
        return_connection(conn, rol_id)


# Delega a sp_actualizar_stock — retorna stock nuevo y mensaje; lanza ValueError si falla
def actualizar_stock(producto_id: int, cantidad: int, operacion: str, rol_id: int) -> dict:
    conn = get_connection(rol_id)
    try:
        with conn.cursor() as cur:
            cur.execute(
                "CALL sp_actualizar_stock(%s, %s, %s, %s, %s)",
                (producto_id, cantidad, operacion, None, None)
            )
            row = cur.fetchone()
            stock_nuevo, mensaje = row[0], row[1]
        conn.commit()
        return {"stock_nuevo": stock_nuevo, "mensaje": mensaje}
    except Exception:
        conn.rollback()
        raise
    finally:
        return_connection(conn, rol_id)
