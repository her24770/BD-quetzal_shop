-- QuetzalShop — Stored Procedures (Proyecto 3, CC3088 Bases de Datos 1)


-- SP1: registra una venta completa con sus items y descuenta el stock
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

    -- primera pasada: validar stock de todos los productos antes de escribir nada
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items) LOOP

        SELECT precio, stock
        INTO   v_precio, v_stock
        FROM   productos
        WHERE  id = (v_item->>'producto_id')::INT;

        IF NOT FOUND THEN
            ROLLBACK;
            RAISE EXCEPTION 'Producto % no encontrado', v_item->>'producto_id';
        END IF;

        IF v_stock < (v_item->>'cantidad')::INT THEN
            ROLLBACK;
            RAISE EXCEPTION 'Stock insuficiente para el producto %', v_item->>'producto_id';
        END IF;

        v_total := v_total + v_precio * (v_item->>'cantidad')::INT;

    END LOOP;

    v_total := v_total - p_descuento;

    -- inserta la cabecera de la venta y guarda el id generado
    INSERT INTO ventas (cliente_id, empleado_id, metodo_pago_id, total, descuento)
    VALUES (p_cliente_id, p_empleado_id, p_metodo_pago_id, v_total, p_descuento)
    RETURNING id INTO p_venta_id;

    -- segunda pasada: inserta los items y descuenta el stock de cada producto
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items) LOOP

        SELECT precio INTO v_precio
        FROM productos WHERE id = (v_item->>'producto_id')::INT;

        -- guarda el precio actual como historico para trazabilidad
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

    COMMIT;

END;
$$;


-- SP2: registra una compra de inventario con sus items y suma el stock
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

    -- primera pasada: verificar que producto y proveedor existan antes de escribir
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items) LOOP

        IF NOT EXISTS (SELECT 1 FROM productos WHERE id = (v_item->>'producto_id')::INT) THEN
            ROLLBACK;
            RAISE EXCEPTION 'Producto % no encontrado', v_item->>'producto_id';
        END IF;

        IF NOT EXISTS (SELECT 1 FROM proveedores WHERE id = (v_item->>'proveedor_id')::INT) THEN
            ROLLBACK;
            RAISE EXCEPTION 'Proveedor % no encontrado', v_item->>'proveedor_id';
        END IF;

        v_total := v_total + (v_item->>'precio_costo')::NUMERIC * (v_item->>'cantidad')::INT;

    END LOOP;

    INSERT INTO compras (empleado_id, numero_factura, total)
    VALUES (p_empleado_id, p_numero_factura, v_total)
    RETURNING id INTO p_compra_id;

    -- segunda pasada: inserta los items y suma el stock a cada producto
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items) LOOP

        -- guarda el costo de compra como historico para trazabilidad contable
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


-- SP3: crea un usuario y su empleado en una sola transaccion atomica.
-- Demuestra ROLLBACK real: primero escribe el usuario, luego valida el DPI;
-- si el DPI ya existe el ROLLBACK deshace el INSERT de usuarios antes de lanzar la excepcion.
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

    -- validacion previa sin escrituras: email unico
    IF EXISTS (SELECT 1 FROM usuarios WHERE email = p_email) THEN
        RAISE EXCEPTION 'El email % ya esta registrado', p_email;
    END IF;

    -- primera escritura: insertar el usuario
    INSERT INTO usuarios (email, password_hash, rol_id)
    VALUES (p_email, p_password_hash, p_rol_id)
    RETURNING id INTO p_usuario_id;

    -- validacion DESPUES de la primera escritura: si el DPI ya existe,
    -- el ROLLBACK deshace el INSERT de usuarios que acaba de ejecutarse
    IF EXISTS (SELECT 1 FROM empleados WHERE dpi = p_dpi) THEN
        ROLLBACK;
        RAISE EXCEPTION 'El DPI % ya esta registrado', p_dpi;
    END IF;

    -- segunda escritura: insertar el empleado vinculado al usuario creado
    INSERT INTO empleados (usuario_id, dpi, nombre, telefono, cargo, fecha_contrato)
    VALUES (p_usuario_id, p_dpi, p_nombre, p_telefono, p_cargo, p_fecha_contrato)
    RETURNING id INTO p_empleado_id;

    COMMIT;

END;
$$;


-- SP4: ajusta el stock de un producto, ya sea sumando o restando
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

    -- solo se aceptan estas dos operaciones
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


-- SP5: elimina un producto; si tiene referencias activas retorna un mensaje en lugar de fallar
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
    -- si el producto esta referenciado en ventas, compras o proveedores no se puede borrar
    WHEN foreign_key_violation THEN
        p_resultado := 'El producto no se puede eliminar porque esta referenciado en ventas, compras o proveedores';

END;
$$;


-- SP6: retorna las ventas agrupadas por dia en un rango de fechas
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

    RETURN QUERY
    SELECT
        v.fecha::DATE,
        COUNT(v.id)::BIGINT,
        COALESCE(SUM(v.total), 0)::NUMERIC,
        COALESCE(AVG(v.total), 0)::NUMERIC
    FROM ventas v
    WHERE v.fecha::DATE BETWEEN p_fecha_inicio AND p_fecha_fin
    GROUP BY v.fecha::DATE
    ORDER BY v.fecha::DATE;

END;
$$;


-- SP7: otorga un permiso sobre una tabla a un rol especifico
-- usa SECURITY DEFINER para poder ejecutar GRANTs sin ser superusuario
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

    -- valida la operacion antes de usarla en sql dinamico
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

    EXECUTE format('GRANT %s ON %I TO %I', p_operacion, p_tabla, p_nombre_rol);

    p_resultado := 'OK: GRANT ' || p_operacion || ' ON ' || p_tabla || ' TO ' || p_nombre_rol;

END;
$$;


-- SP8: revoca un permiso sobre una tabla de un rol especifico
-- qs_admin no puede perder permisos
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
