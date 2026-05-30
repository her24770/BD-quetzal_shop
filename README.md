# QuetzalShop — Sistema de gestion de tienda

Proyecto 3 — cc3088 Bases de Datos 1 | UVG Ciclo 1 2026  
Rama de entrega: `proyecto-3`

---

## Produccion

| Servicio          | URL                                      |
|-------------------|------------------------------------------|
| Aplicacion        | https://quetzalshop.jhgo.online          |
| Documentacion API | https://quetzalshop.jhgo.online/api/docs |

---

## Levantar el proyecto

```bash
git clone https://github.com/her24770/BD-quetzal_shop
cd BD-quetzal_shop
git checkout proyecto-3
```

Variables de entorno
```bash
cp .env.example .env
```

Levantar con docker
```bash
docker compose up
```

| Servicio      | URL local                  |
|---------------|----------------------------|
| Frontend      | http://localhost:3000      |
| Backend API   | http://localhost:8000      |
| Documentacion | http://localhost:8000/docs |

> **Nota sobre puertos:** No es necesario cambiar los puertos para levantar el proyecto.
> Si necesitas cambiarlos, revisa los comentarios en `.env.example` — cada variable
> indica qué otras variables deben actualizarse en conjunto para evitar errores.
>
> Resumen rápido de dependencias:
> - `APP_PORT` cambia → actualizar `VITE_API_URL` con el mismo puerto
> - `FRONTEND_PORT` cambia → actualizar `CORS_ORIGINS` con el mismo puerto
> - `DB_PORT` y `DB_HOST` → **no cambiar**, son internos de Docker

---

## Credenciales

### Aplicacion web

| Rol       | Correo                     | Contrasena |
|-----------|----------------------------|------------|
| Admin     | admin@quetzalshop.com      | admin123   |
| Cajero    | cajero1@quetzalshop.com    | cajero123  |
| Bodeguero | bodeguero1@quetzalshop.com | bodega123  |
| Gerente   | gerente@quetzalshop.com    | gerente123 |
| Auditor   | auditor@quetzalshop.com    | auditor123 |

### Base de datos

| Parametro  | Valor          |
|------------|----------------|
| Host       | localhost      |
| Puerto     | 5432           |
| Base       | quetzalshop_db |
| Usuario    | proy3          |
| Contrasena | secret         |

---

## Rubrica de evaluacion

### I. Seguridad y roles

#### 5 roles definidos en el DBMS con CREATE ROLE y permisos granulares mediante GRANT y REVOKE

Los 5 roles se crean en `back-end/sql/schema.sql` con `CREATE ROLE ... WITH LOGIN` y reciben permisos especificos por tabla y operacion. No son roles de aplicacion — existen directamente en PostgreSQL y el backend conecta con el usuario del rol correspondiente al usuario autenticado.

| Rol PostgreSQL | SELECT | INSERT | UPDATE | DELETE |
|----------------|--------|--------|--------|--------|
| `qs_admin`     | todas las tablas | todas | todas | todas |
| `qs_cajero`    | productos, categorias, clientes, ventas, items_venta, metodos_pago | clientes, ventas, items_venta | clientes, productos(stock) | — |
| `qs_bodeguero` | categorias, productos, proveedores, producto_proveedor, compras, items_compra | productos, proveedores, producto_proveedor, compras, items_compra | productos, proveedores, producto_proveedor | producto_proveedor |
| `qs_gerente`   | todas las tablas | — | — | — |
| `qs_auditor`   | ventas, items_venta, compras, items_compra | — | — | — |

---

#### Esquema de roles documentado: nombre, tablas accesibles y operaciones permitidas

El sistema esta diseñado para que el administrador pueda modificar los permisos de cada rol en tiempo real desde el dashboard, sin necesidad de tocar la base de datos manualmente. La tabla de permisos mostrada arriba es la configuracion base que se carga al iniciar el proyecto, pero puede cambiar dinamicamente: el admin puede otorgar o revocar permisos especificos por tabla y operacion desde el modulo de Gestion de permisos, lo cual ejecuta `sp_grant_permiso_rol` o `sp_revoke_permiso_rol` directamente en PostgreSQL.

Cada rol tiene un proposito de negocio distinto:

- **qs_admin** — acceso total, gestiona el sistema completo.
- **qs_cajero** — registra ventas y gestiona clientes. No puede tocar inventario ni compras.
- **qs_bodeguero** — gestiona inventario y registra compras. No puede registrar ventas.
- **qs_gerente** — solo lectura sobre todo el sistema para supervision y reportes.
- **qs_auditor** — solo lectura sobre el historial de ventas y compras para auditoria.

---

#### Autenticacion con sesion (login/logout) y un usuario de prueba funcional por cada rol incluido en el script de datos

El sistema implementa autenticacion con JWT. Al hacer login el backend genera un token que incluye el `rol_id`; el frontend lo guarda en `localStorage` y lo envia en cada peticion. El logout limpia la sesion.

Los 5 usuarios de prueba estan en `back-end/sql/seed.sql` con sus contrasenas hasheadas en bcrypt:

| Rol       | Correo                     | Contrasena |
|-----------|----------------------------|------------|
| Admin     | admin@quetzalshop.com      | admin123   |
| Cajero    | cajero1@quetzalshop.com    | cajero123  |
| Bodeguero | bodeguero1@quetzalshop.com | bodega123  |
| Gerente   | gerente@quetzalshop.com    | gerente123 |
| Auditor   | auditor@quetzalshop.com    | auditor123 |

---

#### Rutas y vistas de la UI protegidas segun el rol del usuario autenticado

La proteccion funciona en tres capas:

**Backend — permisos dinamicos:** Cada endpoint usa `require_permission(tabla, operacion)` definido en `back-end/dependencies.py`. En cada request, esta dependencia consulta `information_schema.role_table_grants` en PostgreSQL para verificar si el rol activo tiene el permiso necesario sobre la tabla correspondiente. Si el admin cambia un permiso desde el dashboard (ejecutando `sp_grant_permiso_rol` o `sp_revoke_permiso_rol`), el cambio se refleja de inmediato en todos los endpoints sin reiniciar el servidor.

**Frontend — sidebar y llamadas condicionales:** El sidebar filtra los modulos visibles consultando `GET /auth/me/permisos`, que devuelve los permisos reales del rol desde PostgreSQL. El dashboard solo llama los endpoints de reportes para los que el usuario tiene permiso (no llama endpoints que devolverian 403). Las rutas del dashboard redirigen a una pagina de acceso denegado si el usuario intenta acceder a un modulo sin permiso.

**Sin sesion:** Cualquier ruta del dashboard redirige al login si no hay token activo.

| Modulo           | Admin | Cajero      | Bodeguero    | Gerente  | Auditor  |
|------------------|:-----:|:-----------:|:------------:|:--------:|:--------:|
| Dashboard        | si    | si          | si           | si       | si       |
| Productos        | CRUD  | lectura     | CRUD         | lectura  | —        |
| Categorias       | CRUD  | —           | lectura      | lectura  | —        |
| Proveedores      | CRUD  | —           | lectura      | lectura  | —        |
| Clientes         | CRUD  | CRUD        | —            | lectura  | —        |
| Transacciones    | ambas | solo ventas | solo compras | —        | —        |
| Historial        | ambas | solo ventas | solo compras | ambas    | ambas    |
| Empleados        | CRUD  | —           | —            | lectura  | —        |
| Gestion permisos | si    | —           | —            | —        | —        |

---

### II. Stored Procedures y ORM

#### Al menos 5 stored procedures invocados desde el backend

Se implementaron 8 stored procedures en `back-end/sql/stored_procedures.sql`, todos invocados desde el backend mediante `CALL` o `SELECT * FROM`. Ninguno se ejecuta desde scripts independientes.

| SP | Invocado desde | Descripcion |
|----|----------------|-------------|
| `sp_registrar_venta` | `queries/ventas.py` | Registra una venta completa con items y descuenta stock |
| `sp_registrar_compra` | `queries/compras.py` | Registra una compra completa con items y aumenta stock |
| `sp_crear_empleado` | `queries/empleados.py` | Crea usuario y empleado de forma atomica |
| `sp_actualizar_stock` | `queries/productos.py` | Ajusta el stock de un producto manualmente |
| `sp_eliminar_producto` | `queries/productos.py` | Elimina un producto manejando violaciones de FK |
| `sp_reporte_ventas_periodo` | `queries/reportes.py` | Retorna ventas agregadas por dia en un rango de fechas |
| `sp_grant_permiso_rol` | `queries/permisos.py` | Ejecuta un GRANT dinamico desde la UI de administracion |
| `sp_revoke_permiso_rol` | `queries/permisos.py` | Ejecuta un REVOKE dinamico desde la UI de administracion |

---

#### Al menos 1 stored procedure con parametros de entrada/salida y manejo de excepciones

Tres stored procedures cumplen este criterio:

- **`sp_registrar_venta`** — parametro `INOUT p_venta_id` devuelve el ID de la venta creada. Lanza excepcion si un producto no existe o si el stock es insuficiente.
- **`sp_crear_empleado`** — parametros `INOUT p_usuario_id` e `INOUT p_empleado_id` devuelven los IDs generados. Lanza excepcion si el email ya esta registrado.
- **`sp_eliminar_producto`** — parametro `INOUT p_resultado` retorna `'OK'`, `'NOT_FOUND'` o el mensaje del error. Captura la excepcion de violacion de FK con un bloque `EXCEPTION WHEN foreign_key_violation`.

---

#### Al menos 1 transaccion explicita con ROLLBACK implementada dentro de un stored procedure

Tres stored procedures implementan `ROLLBACK` explicito en sus rutas de error:

- **`sp_registrar_venta`** — hace `ROLLBACK` explicito antes de lanzar la excepcion si el stock es insuficiente o el producto no existe, garantizando que ningun dato quede escrito en la BD.
- **`sp_registrar_compra`** — hace `ROLLBACK` explicito si el producto o proveedor referenciado en los items no existe.
- **`sp_crear_empleado`** — demuestra ROLLBACK real despues de una escritura: primero inserta el usuario en `usuarios`, luego valida que el DPI no exista en `empleados`; si el DPI ya esta registrado, el `ROLLBACK` deshace el INSERT del usuario que acaba de ejecutarse. La validacion del email ocurre antes de cualquier escritura (sin necesidad de ROLLBACK).

---

#### ORM configurado y utilizado en al menos 3 operaciones CRUD de la aplicacion

Se usa **SQLModel** como ORM, configurado en `back-end/database/orm.py`. Los modelos estan en `back-end/database/models/`. El ORM se utiliza en las siguientes operaciones CRUD:

| Entidad   | Operaciones via ORM                        |
|-----------|--------------------------------------------|
| Categoria | get_all, get_by_id, create, update, delete |
| Cliente   | get_all, get_by_id, create, update, delete |
| Producto  | create, update                             |
| Empleado  | update, delete                             |

Las consultas que requieren JOINs entre multiples tablas y las llamadas a stored procedures usan SQL explicito via psycopg2 para complementar el ORM.

---

## Estructura del proyecto

```
BD-quetzal_shop/
├── back-end/
│   ├── database/
│   │   ├── connection.py       # Pools de conexion por rol
│   │   ├── orm.py              # Motor SQLModel
│   │   ├── models/             # Modelos ORM por entidad
│   │   └── queries/            # Acceso a datos por entidad
│   ├── controllers/            # Logica de negocio
│   ├── routes/                 # Endpoints con proteccion de roles
│   ├── schemas/                # Modelos Pydantic
│   ├── sql/
│   │   ├── schema.sql          # Tablas, indices, roles, GRANTs
│   │   ├── views.sql           # Vistas SQL
│   │   ├── seed.sql            # Datos de prueba
│   │   └── stored_procedures.sql
│   └── dependencies.py         # Guards de autenticacion y roles
├── front-end/
│   └── src/
│       ├── lib/
│       │   ├── api/            # Clientes HTTP
│       │   ├── components/     # Componentes reutilizables
│       │   └── stores/         # Estado global
│       └── routes/             # Paginas protegidas por rol
├── docker-compose.yml
├── .env.example
└── README.md
```
