-- ============================================================
-- Proyecto 2 - DDL Completo
-- DBMS: PostgreSQL
-- ============================================================

CREATE TABLE IF NOT EXISTS roles (
    id          SERIAL          PRIMARY KEY,
    nombre      VARCHAR(50)     NOT NULL,
    descripcion VARCHAR(255)    NOT NULL
);

CREATE TABLE IF NOT EXISTS usuarios (
    id              SERIAL          PRIMARY KEY,
    email           VARCHAR(150)    NOT NULL    UNIQUE,
    password_hash   VARCHAR(255)    NOT NULL,
    rol_id          INT             NOT NULL,
    creado          TIMESTAMP       NOT NULL    DEFAULT NOW(),
    CONSTRAINT fk_usuarios_roles    FOREIGN KEY (rol_id)    REFERENCES roles(id)
);


CREATE TABLE IF NOT EXISTS empleados (
    id              SERIAL          PRIMARY KEY,
    usuario_id      INT             NOT NULL    UNIQUE,
    dpi             VARCHAR(20)     NOT NULL    UNIQUE,
    nombre          VARCHAR(100)    NOT NULL,
    telefono        VARCHAR(20)     NOT NULL,
    cargo           VARCHAR(100)    NOT NULL,
    fecha_contrato  DATE            NOT NULL,
    estado          VARCHAR(20)     NOT NULL    DEFAULT 'activo',
    CONSTRAINT fk_empleados_usuarios    FOREIGN KEY (usuario_id)    REFERENCES usuarios(id),
    CONSTRAINT chk_empleados_estado     CHECK (estado IN ('activo', 'inactivo'))
);


CREATE TABLE IF NOT EXISTS categorias (
    id          SERIAL          PRIMARY KEY,
    nombre      VARCHAR(100)    NOT NULL,
    descripcion VARCHAR(255)    NOT NULL
);

CREATE TABLE IF NOT EXISTS proveedores (
    id          SERIAL          PRIMARY KEY,
    nombre      VARCHAR(150)    NOT NULL,
    telefono    VARCHAR(20)     NOT NULL,
    email       VARCHAR(150)    NOT NULL,
    direccion   VARCHAR(255)    NOT NULL
);

CREATE TABLE IF NOT EXISTS productos (
    id              SERIAL          PRIMARY KEY,
    nombre          VARCHAR(150)    NOT NULL,
    descripcion     VARCHAR(500)    NOT NULL,
    precio          NUMERIC(10,2)   NOT NULL,
    stock           INT             NOT NULL    DEFAULT 0,
    stock_minimo    INT             NOT NULL    DEFAULT 5,
    categoria_id    INT             NOT NULL,
    CONSTRAINT fk_productos_categorias  FOREIGN KEY (categoria_id)  REFERENCES categorias(id),
    CONSTRAINT chk_productos_precio     CHECK (precio > 0),
    CONSTRAINT chk_productos_stock      CHECK (stock >= 0)
);

CREATE TABLE IF NOT EXISTS producto_proveedor (
    producto_id     INT             NOT NULL,
    proveedor_id    INT             NOT NULL,
    precio_costo    NUMERIC(10,2)   NOT NULL,
    CONSTRAINT pk_producto_proveedor    PRIMARY KEY (producto_id, proveedor_id),
    CONSTRAINT fk_pp_productos          FOREIGN KEY (producto_id)   REFERENCES productos(id),
    CONSTRAINT fk_pp_proveedores        FOREIGN KEY (proveedor_id)  REFERENCES proveedores(id),
    CONSTRAINT chk_pp_precio_costo      CHECK (precio_costo > 0)
);


CREATE TABLE IF NOT EXISTS clientes (
    id          SERIAL          PRIMARY KEY,
    nombre      VARCHAR(150)    NOT NULL,
    nit         VARCHAR(20)     NOT NULL,
    telefono    VARCHAR(20)     NOT NULL,
    direccion   VARCHAR(255)    NOT NULL
);


CREATE TABLE IF NOT EXISTS metodos_pago (
    id      SERIAL          PRIMARY KEY,
    metodo  VARCHAR(50)     NOT NULL    UNIQUE
);


CREATE TABLE IF NOT EXISTS ventas (
    id              SERIAL          PRIMARY KEY,
    cliente_id      INT             NOT NULL,
    empleado_id     INT             NOT NULL,
    metodo_pago_id  INT             NOT NULL,
    fecha           TIMESTAMP       NOT NULL    DEFAULT NOW(),
    total           NUMERIC(10,2)   NOT NULL    DEFAULT 0,
    descuento       NUMERIC(10,2)   NOT NULL    DEFAULT 0,
    CONSTRAINT fk_ventas_clientes       FOREIGN KEY (cliente_id)        REFERENCES clientes(id),
    CONSTRAINT fk_ventas_empleados      FOREIGN KEY (empleado_id)       REFERENCES empleados(id),
    CONSTRAINT fk_ventas_metodos_pago   FOREIGN KEY (metodo_pago_id)    REFERENCES metodos_pago(id),
    CONSTRAINT chk_ventas_total         CHECK (total >= 0),
    CONSTRAINT chk_ventas_descuento     CHECK (descuento >= 0)
);

CREATE TABLE IF NOT EXISTS items_venta (
    venta_id                    INT             NOT NULL,
    producto_id                 INT             NOT NULL,
    cantidad                    INT             NOT NULL,
    precio_unitario_historico   NUMERIC(10,2)   NOT NULL,
    subtotal                    NUMERIC(10,2)   NOT NULL,
    CONSTRAINT pk_items_venta       PRIMARY KEY (venta_id, producto_id),
    CONSTRAINT fk_iv_ventas         FOREIGN KEY (venta_id)      REFERENCES ventas(id),
    CONSTRAINT fk_iv_productos      FOREIGN KEY (producto_id)   REFERENCES productos(id),
    CONSTRAINT chk_iv_cantidad      CHECK (cantidad > 0),
    CONSTRAINT chk_iv_subtotal      CHECK (subtotal >= 0)
);


CREATE TABLE IF NOT EXISTS compras (
    id              SERIAL          PRIMARY KEY,
    empleado_id     INT             NOT NULL,
    fecha           TIMESTAMP       NOT NULL    DEFAULT NOW(),
    total           NUMERIC(10,2)   NOT NULL    DEFAULT 0,
    numero_factura  VARCHAR(50)     NOT NULL,
    CONSTRAINT fk_compras_empleados FOREIGN KEY (empleado_id)   REFERENCES empleados(id),
    CONSTRAINT chk_compras_total    CHECK (total >= 0)
);

CREATE TABLE IF NOT EXISTS items_compra (
    compra_id               INT             NOT NULL,
    producto_id             INT             NOT NULL,
    proveedor_id            INT             NOT NULL,
    cantidad                INT             NOT NULL,
    precio_costo_historico  NUMERIC(10,2)   NOT NULL,
    subtotal                NUMERIC(10,2)   NOT NULL,
    CONSTRAINT pk_items_compra      PRIMARY KEY (compra_id, producto_id),
    CONSTRAINT fk_ic_compras        FOREIGN KEY (compra_id)     REFERENCES compras(id),
    CONSTRAINT fk_ic_productos      FOREIGN KEY (producto_id)   REFERENCES productos(id),
    CONSTRAINT fk_ic_proveedores    FOREIGN KEY (proveedor_id)  REFERENCES proveedores(id),
    CONSTRAINT chk_ic_cantidad      CHECK (cantidad > 0),
    CONSTRAINT chk_ic_costo         CHECK (precio_costo_historico > 0)
);

-- ============================================================
-- INDICES
-- ============================================================

-- Login: busqueda por email en cada inicio de sesion
CREATE INDEX IF NOT EXISTS ix_usuarios_email
ON usuarios(email);

-- Busqueda por DPI al registrar empleados
CREATE INDEX IF NOT EXISTS ix_empleados_dpi
ON empleados(dpi);

-- Filtro de productos por categoria en el dashboard
CREATE INDEX IF NOT EXISTS ix_productos_categoria
ON productos(categoria_id);

-- Reportes de ventas filtrados por fecha
CREATE INDEX IF NOT EXISTS ix_ventas_fecha
ON ventas(fecha);

-- Reportes de rendimiento por empleado
CREATE INDEX IF NOT EXISTS ix_ventas_empleado
ON ventas(empleado_id);

-- Carga del detalle de una venta especifica
CREATE INDEX IF NOT EXISTS ix_items_venta_venta
ON items_venta(venta_id);

-- Carga del detalle de una compra especifica
CREATE INDEX IF NOT EXISTS ix_items_compra_compra
ON items_compra(compra_id);

-- ============================================================
-- ROLES DE POSTGRESQL (Proyecto 3)
-- Cada rol tiene LOGIN propio — el API conecta con el rol del usuario autenticado
-- proy3 sigue siendo el owner pero ya no lo usa el API en runtime
-- ============================================================
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'qs_admin') THEN
    CREATE ROLE qs_admin WITH LOGIN PASSWORD 'admin_secret';
  END IF;
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'qs_cajero') THEN
    CREATE ROLE qs_cajero WITH LOGIN PASSWORD 'cajero_secret';
  END IF;
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'qs_bodeguero') THEN
    CREATE ROLE qs_bodeguero WITH LOGIN PASSWORD 'bodeguero_secret';
  END IF;
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'qs_gerente') THEN
    CREATE ROLE qs_gerente WITH LOGIN PASSWORD 'gerente_secret';
  END IF;
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'qs_auditor') THEN
    CREATE ROLE qs_auditor WITH LOGIN PASSWORD 'auditor_secret';
  END IF;
END
$$;

-- Permisos de conexion a la base de datos
GRANT CONNECT ON DATABASE quetzalshop_db TO qs_admin, qs_cajero, qs_bodeguero, qs_gerente, qs_auditor;
GRANT USAGE ON SCHEMA public TO qs_admin, qs_cajero, qs_bodeguero, qs_gerente, qs_auditor;

-- qs_admin: acceso total
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO qs_admin;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO qs_admin;

-- qs_cajero: ventas y clientes
GRANT SELECT ON productos, categorias, metodos_pago, clientes, ventas, items_venta TO qs_cajero;
GRANT INSERT, UPDATE ON clientes TO qs_cajero;
GRANT INSERT ON ventas, items_venta TO qs_cajero;
-- UPDATE solo en la columna stock: lo necesita sp_registrar_venta para decrementar el inventario
GRANT UPDATE (stock) ON productos TO qs_cajero;
GRANT USAGE, SELECT ON SEQUENCE ventas_id_seq, clientes_id_seq TO qs_cajero;

-- qs_bodeguero: inventario y compras
GRANT SELECT ON categorias TO qs_bodeguero;
GRANT SELECT, INSERT, UPDATE ON productos, proveedores, producto_proveedor TO qs_bodeguero;
GRANT DELETE ON producto_proveedor TO qs_bodeguero;
GRANT SELECT, INSERT ON compras, items_compra TO qs_bodeguero;
GRANT USAGE, SELECT ON SEQUENCE productos_id_seq, proveedores_id_seq, compras_id_seq TO qs_bodeguero;

-- qs_gerente: solo lectura total
GRANT SELECT ON ALL TABLES IN SCHEMA public TO qs_gerente;

-- qs_auditor: solo historial de ventas y compras
GRANT SELECT ON ventas, items_venta, compras, items_compra TO qs_auditor;
