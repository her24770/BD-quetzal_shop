-- QuetzalShop — Stored Procedures (Proyecto 3, CC3088 Bases de Datos 1)


-- SP1: registra venta completa (cabecera + items + descuento de stock) en una sola transacción
-- Parámetro INOUT p_venta_id: devuelve el ID generado sin necesitar una segunda consulta
-- JSONB permite recibir toda la lista de items como un solo parámetro
CREATE OR REPLACE PROCEDURE sp_registrar_venta(
    IN  p_cliente_id     INT,
    IN  p_empleado_id    INT,
    IN  p_metodo_pago_id INT,
    IN  p_descuento      NUMERIC(10,2),
    IN  p_items          JSONB,
    INOUT p_venta_id     INT DEFAULT NULL
)
LANGUAGE plpgsql AS $$
DECLARE
    v_item     JSONB;
    v_precio   NUMERIC(10,2);
    v_stock    INT;
    v_total    NUMERIC(10,2) := 0;
BEGIN

    -- 1ra pasada: validar stock de todos los items antes de escribir nada en la BD
    -- Si cualquier producto falla, RAISE EXCEPTION aborta y PostgreSQL deshace todo
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items) LOOP

        -- jsonb_array_elements expande el array; ->> extrae campo como texto; ::INT lo convierte
        SELECT precio, stock
        INTO   v_precio, v_stock
        FROM   productos
        WHERE  id = (v_item->>'producto_id')::INT;

        -- NOT FOUND es TRUE cuando el SELECT anterior no encontró ninguna fila
        IF NOT FOUND THEN
            RAISE EXCEPTION 'Producto % no encontrado', v_item->>'producto_id';
        END IF;

        IF v_stock < (v_item->>'cantidad')::INT THEN
            RAISE EXCEPTION 'Stock insuficiente para el producto %', v_item->>'producto_id';
        END IF;

        v_total := v_total + v_precio * (v_item->>'cantidad')::INT;

    END LOOP;

    v_total := v_total - p_descuento;

    -- RETURNING id INTO captura el ID generado por la secuencia en el parámetro INOUT
    INSERT INTO ventas (cliente_id, empleado_id, metodo_pago_id, total, descuento)
    VALUES (p_cliente_id, p_empleado_id, p_metodo_pago_id, v_total, p_descuento)
    RETURNING id INTO p_venta_id;

    -- 2da pasada: escribir items y descontar stock (validación ya fue aprobada arriba)
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items) LOOP

        SELECT precio INTO v_precio
        FROM productos WHERE id = (v_item->>'producto_id')::INT;

        -- precio_unitario_historico guarda el precio al momento de la venta para auditoría
        INSERT INTO items_venta (venta_id, producto_id, cantidad, precio_unitario_historico, subtotal)
        VALUES (
            p_venta_id,
            (v_item->>'producto_id')::INT,
            (v_item->>'cantidad')::INT,
            v_precio,
            v_precio * (v_item->>'cantidad')::INT
        );

        UPDATE productos
        SET    stock = stock - (v_item->>'cantidad')::INT
        WHERE  id = (v_item->>'producto_id')::INT;

    END LOOP;

    -- COMMIT explícito: cierra la transacción desde el SP; requiere autocommit=True en psycopg2
    COMMIT;

END;
$$;


-- SP2: registra compra de inventario (cabecera + items + aumento de stock) en una sola transacción
CREATE OR REPLACE PROCEDURE sp_registrar_compra(
    IN  p_empleado_id    INT,
    IN  p_numero_factura VARCHAR(50),
    IN  p_items          JSONB,
    INOUT p_compra_id    INT DEFAULT NULL
)
LANGUAGE plpgsql AS $$
DECLARE
    v_item  JSONB;
    v_total NUMERIC(10,2) := 0;
BEGIN

    -- 1ra pasada: validar que producto y proveedor existan antes de escribir
    -- EXISTS (SELECT 1 ...) es más eficiente que COUNT(*): para al encontrar la primera fila
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items) LOOP

        IF NOT EXISTS (SELECT 1 FROM productos  WHERE id = (v_item->>'producto_id')::INT) THEN
            RAISE EXCEPTION 'Producto % no encontrado', v_item->>'producto_id';
        END IF;

        IF NOT EXISTS (SELECT 1 FROM proveedores WHERE id = (v_item->>'proveedor_id')::INT) THEN
            RAISE EXCEPTION 'Proveedor % no encontrado', v_item->>'proveedor_id';
        END IF;

        v_total := v_total + (v_item->>'precio_costo')::NUMERIC * (v_item->>'cantidad')::INT;

    END LOOP;

    INSERT INTO compras (empleado_id, numero_factura, total)
    VALUES (p_empleado_id, p_numero_factura, v_total)
    RETURNING id INTO p_compra_id;

    -- 2da pasada: insertar items y sumar stock a cada producto
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items) LOOP

        -- precio_costo_historico guarda el costo al momento de la compra para trazabilidad contable
        INSERT INTO items_compra (compra_id, producto_id, proveedor_id, cantidad, precio_costo_historico, subtotal)
        VALUES (
            p_compra_id,
            (v_item->>'producto_id')::INT,
            (v_item->>'proveedor_id')::INT,
            (v_item->>'cantidad')::INT,
            (v_item->>'precio_costo')::NUMERIC,
            (v_item->>'precio_costo')::NUMERIC * (v_item->>'cantidad')::INT
        );

        UPDATE productos
        SET    stock = stock + (v_item->>'cantidad')::INT
        WHERE  id = (v_item->>'producto_id')::INT;

    END LOOP;

    COMMIT;

END;
$$;


-- SP3: crea usuario + empleado en una sola transacción atómica
-- Sin este SP, si el 2do INSERT falla quedaría un usuario sin empleado (registro huérfano)
-- Dos parámetros INOUT devuelven ambos IDs generados al llamador
CREATE OR REPLACE PROCEDURE sp_crear_empleado(
    IN  p_email          VARCHAR(150),
    IN  p_password_hash  VARCHAR(255),
    IN  p_rol_id         INT,
    IN  p_dpi            VARCHAR(20),
    IN  p_nombre         VARCHAR(100),
    IN  p_telefono       VARCHAR(20),
    IN  p_cargo          VARCHAR(100),
    IN  p_fecha_contrato DATE,
    INOUT p_usuario_id   INT DEFAULT NULL,
    INOUT p_empleado_id  INT DEFAULT NULL
)
LANGUAGE plpgsql AS $$
BEGIN

    INSERT INTO usuarios (email, password_hash, rol_id)
    VALUES (p_email, p_password_hash, p_rol_id)
    RETURNING id INTO p_usuario_id;

    -- Si este INSERT falla, PostgreSQL deshace el INSERT de usuarios porque el COMMIT aún no ocurrió
    INSERT INTO empleados (usuario_id, dpi, nombre, telefono, cargo, fecha_contrato)
    VALUES (p_usuario_id, p_dpi, p_nombre, p_telefono, p_cargo, p_fecha_contrato)
    RETURNING id INTO p_empleado_id;

    COMMIT;

END;
$$;


-- SP4: ajuste manual de stock (incrementar o decrementar) con validaciones de negocio
-- No tiene COMMIT propio: el llamador (Python) controla la transacción externamente
CREATE OR REPLACE PROCEDURE sp_actualizar_stock(
    IN    p_producto_id INT,
    IN    p_cantidad    INT,
    IN    p_operacion   VARCHAR(15),
    INOUT p_stock_nuevo INT     DEFAULT NULL,
    INOUT p_mensaje     VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql AS $$
DECLARE
    v_stock_actual INT;
BEGIN

    -- Whitelist explícita: p_operacion se usará en lógica condicional, no en SQL dinámico
    IF p_operacion NOT IN ('incrementar', 'decrementar') THEN
        RAISE EXCEPTION 'Operacion invalida: debe ser "incrementar" o "decrementar"';
    END IF;

    SELECT stock INTO v_stock_actual
    FROM   productos WHERE id = p_producto_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Producto % no encontrado', p_producto_id;
    END IF;

    IF p_operacion = 'decrementar' AND v_stock_actual < p_cantidad THEN
        RAISE EXCEPTION 'Stock insuficiente: actual=%, solicitado=%', v_stock_actual, p_cantidad;
    END IF;

    -- RETURNING stock INTO captura el nuevo valor tras el UPDATE en una sola operación
    IF p_operacion = 'incrementar' THEN
        UPDATE productos SET stock = stock + p_cantidad WHERE id = p_producto_id
        RETURNING stock INTO p_stock_nuevo;
    ELSE
        UPDATE productos SET stock = stock - p_cantidad WHERE id = p_producto_id
        RETURNING stock INTO p_stock_nuevo;
    END IF;

    p_mensaje := 'Stock actualizado a ' || p_stock_nuevo::TEXT;

END;
$$;


-- SP5: elimina un producto manejando la violación de FK de forma controlada
-- Retorna un código en p_resultado en lugar de propagar la excepción al llamador
-- EXCEPTION puede coexistir aquí porque este SP no tiene COMMIT explícito
CREATE OR REPLACE PROCEDURE sp_eliminar_producto(
    IN    p_producto_id INT,
    INOUT p_resultado   VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql AS $$
BEGIN

    IF NOT EXISTS (SELECT 1 FROM productos WHERE id = p_producto_id) THEN
        p_resultado := 'NOT_FOUND';
        RETURN;
    END IF;

    DELETE FROM productos WHERE id = p_producto_id;
    p_resultado := 'OK';

EXCEPTION
    -- WHEN foreign_key_violation: captura solo el error SQLSTATE 23503 (referencia activa en otra tabla)
    WHEN foreign_key_violation THEN
        p_resultado := 'El producto no se puede eliminar porque esta referenciado en ventas, compras o proveedores';

END;
$$;


-- SP6: agrega ventas diarias en un rango de fechas
-- Es FUNCTION (no PROCEDURE) porque RETURNS TABLE permite devolver un conjunto de filas
-- Las FUNCTIONs se invocan con SELECT * FROM funcion(...); los PROCEDUREs no pueden retornar tablas
CREATE OR REPLACE FUNCTION sp_reporte_ventas_periodo(
    p_fecha_inicio DATE,
    p_fecha_fin    DATE
)
RETURNS TABLE (
    fecha          DATE,
    total_ventas   BIGINT,
    monto_total    NUMERIC,
    promedio_venta NUMERIC
)
LANGUAGE plpgsql AS $$
BEGIN

    IF p_fecha_inicio > p_fecha_fin THEN
        RAISE EXCEPTION 'La fecha de inicio no puede ser mayor que la fecha de fin';
    END IF;

    -- RETURN QUERY ejecuta el SELECT y vuelca sus filas como resultado de la función
    RETURN QUERY
    SELECT
        v.fecha::DATE,
        COUNT(v.id)::BIGINT,
        COALESCE(SUM(v.total), 0)::NUMERIC,   -- COALESCE protege contra NULL cuando no hay ventas
        COALESCE(AVG(v.total), 0)::NUMERIC
    FROM ventas v
    WHERE v.fecha::DATE BETWEEN p_fecha_inicio AND p_fecha_fin
    GROUP BY v.fecha::DATE
    ORDER BY v.fecha::DATE;

END;
$$;


-- SP7: otorga un permiso (GRANT) a un rol sobre una tabla usando SQL dinámico
-- SECURITY DEFINER: corre con privilegios del owner (proy2), no del rol que lo llama
-- Permite que qs_admin ejecute GRANTs sin ser superusuario
CREATE OR REPLACE PROCEDURE sp_grant_permiso_rol(
    IN    p_nombre_rol VARCHAR,
    IN    p_tabla      VARCHAR,
    IN    p_operacion  VARCHAR,
    INOUT p_resultado  VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN

    -- Whitelist obligatoria: las keywords SQL no pueden parametrizarse con %I, solo con %s
    -- Validar antes de usarlas en SQL dinámico previene inyección de comandos
    IF p_operacion NOT IN ('SELECT', 'INSERT', 'UPDATE', 'DELETE') THEN
        RAISE EXCEPTION 'Operacion invalida: debe ser SELECT, INSERT, UPDATE o DELETE';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE  table_schema = 'public' AND table_name = p_tabla
    ) THEN
        RAISE EXCEPTION 'La tabla % no existe en el schema public', p_tabla;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = p_nombre_rol) THEN
        RAISE EXCEPTION 'El rol % no existe', p_nombre_rol;
    END IF;

    -- format() construye el SQL dinámico; %I escapa tabla y rol como identificadores seguros
    EXECUTE format('GRANT %s ON %I TO %I', p_operacion, p_tabla, p_nombre_rol);

    p_resultado := 'OK: GRANT ' || p_operacion || ' ON ' || p_tabla || ' TO ' || p_nombre_rol;

END;
$$;


-- SP8: revoca un permiso (REVOKE) de un rol sobre una tabla
-- Misma lógica de seguridad que SP7; protege a qs_admin de revocaciones accidentales
-- REVOKE es idempotente en PostgreSQL: no falla si el permiso no existía
CREATE OR REPLACE PROCEDURE sp_revoke_permiso_rol(
    IN    p_nombre_rol VARCHAR,
    IN    p_tabla      VARCHAR,
    IN    p_operacion  VARCHAR,
    INOUT p_resultado  VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN

    -- qs_admin nunca puede quedarse sin permisos: es el rol raíz del sistema
    IF p_nombre_rol = 'qs_admin' THEN
        RAISE EXCEPTION 'No se pueden revocar permisos de qs_admin (rol raiz del sistema)';
    END IF;

    IF p_operacion NOT IN ('SELECT', 'INSERT', 'UPDATE', 'DELETE') THEN
        RAISE EXCEPTION 'Operacion invalida: debe ser SELECT, INSERT, UPDATE o DELETE';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE  table_schema = 'public' AND table_name = p_tabla
    ) THEN
        RAISE EXCEPTION 'La tabla % no existe en el schema public', p_tabla;
    END IF;

    EXECUTE format('REVOKE %s ON %I FROM %I', p_operacion, p_tabla, p_nombre_rol);

    p_resultado := 'OK: REVOKE ' || p_operacion || ' ON ' || p_tabla || ' FROM ' || p_nombre_rol;

END;
$$;
