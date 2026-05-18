# QuetzalShop — Sistema de gestion de tienda

Proyecto 2 — cc3062 Sistemas y Tecnologías Web | UVG Ciclo 1 2026

Sistema de punto de venta para una tienda, compuesto por una base de datos PostgreSQL, una API REST con FastAPI y una interfaz web con SvelteKit. El stack completo se levanta con un solo comando mediante Docker Compose.

---

## Requisitos previos

- Docker Desktop >= 24 (incluye Docker Compose v2)
- Git

---

## Configuracion

### 1. Clonar el repositorio

```bash
git clone <url-del-repositorio>
cd BD-quetzal_shop
```

### 2. Copiar los archivos de configuracion

Tanto `docker-compose.yml` como `.env` estan en `.gitignore` y deben generarse a partir de sus ejemplos incluidos en el repositorio:

```bash
cp docker-compose.yml.example docker-compose.yml
cp .env.example .env
```

El archivo `.env` por defecto contiene:

```env
# Base de datos
DB_HOST=db
DB_PORT=5432
DB_NAME=quetzalshop_db
DB_USER=proy2
DB_PASSWORD=secret

# JWT
JWT_SECRET=ejemplo_clave
JWT_ALGORITHM=HS256
JWT_EXPIRE_HOURS=24

# Backend
APP_PORT=8000
APP_ENV=development
CORS_ORIGINS=http://localhost:5173,http://localhost:3000

# Frontend
FRONTEND_PORT=5173
VITE_API_URL=http://localhost:8000
```

No es necesario cambiar ningun valor para ejecutar el proyecto en desarrollo local.

---

## Levantar el proyecto

```bash
cp docker-compose.yml.example docker-compose.yml
cp .env.example .env
docker compose up
```

Docker Compose construye las imagenes y levanta tres servicios en orden:

1. **db** — PostgreSQL 15. Al iniciarse por primera vez carga automaticamente `schema.sql`, `views.sql` y `seed.sql`, creando tablas, vistas y datos de prueba.
2. **backend** — FastAPI en. Espera a que la base de datos este lista (healthcheck) antes de arrancar.
3. **frontend** — SvelteKit. Espera a que el backend este disponible.

Para ejecutar en segundo plano:

```bash
docker compose up -d
```

Para detener y eliminar los contenedores:

```bash
docker compose down
```

Para eliminar tambien el volumen de la base de datos (datos persistidos):

```bash
docker compose down -v
```

---

## URLs de acceso
segun el .example

| Servicio        | URL                        |
|-----------------|----------------------------|
| Frontend        | http://localhost:5173      |
| Backend API     | http://localhost:8000      |
| Documentacion   | http://localhost:8000/docs |

---

## Credenciales de prueba

### Acceso a la aplicacion web

| Rol       | Correo                     | Contrasena  |
|-----------|----------------------------|-------------|
| Admin     | admin@quetzalshop.com      | admin123    |
| Cajero    | cajero1@quetzalshop.com    | cajero123   |
| Bodeguero | bodeguero1@quetzalshop.com | bodega123   |
| Gerente   | gerente@quetzalshop.com    | gerente123  |
| Auditor   | auditor@quetzalshop.com    | auditor123  |

### Acceso directo a la base de datos

| Parametro  | Valor          |
|------------|----------------|
| Host       | localhost      |
| Puerto     | 5432           |
| Base       | quetzalshop_db |
| Usuario    | proy3          |
| Contrasena | secret         |

---

## Roles y permisos

### Roles de PostgreSQL

Cada rol tiene su propio usuario en PostgreSQL con permisos granulares. El backend conecta con el pool del rol correspondiente al usuario autenticado.

| Rol PostgreSQL  | rol_id | SELECT                                              | INSERT                        | UPDATE             | DELETE |
|-----------------|--------|-----------------------------------------------------|-------------------------------|--------------------|--------|
| qs_admin        | 1      | todas las tablas                                    | todas las tablas              | todas las tablas   | todas las tablas |
| qs_cajero       | 2      | productos, categorias, clientes, ventas, items_venta | clientes, ventas, items_venta | clientes           | —      |
| qs_bodeguero    | 3      | productos, categorias, proveedores, compras, items_compra | productos, proveedores, compras, items_compra | productos, proveedores | — |
| qs_gerente      | 4      | todas las tablas                                    | —                             | —                  | —      |
| qs_auditor      | 5      | ventas, items_venta, compras, items_compra          | —                             | —                  | —      |

### Acceso por modulo

| Modulo           | Admin (1)        | Cajero (2)    | Bodeguero (3)  | Gerente (4)      | Auditor (5)      |
|------------------|:----------------:|:-------------:|:--------------:|:----------------:|:----------------:|
| Dashboard        | si               | si            | si             | si               | si               |
| Productos        | CRUD             | lectura       | CRUD           | lectura          | —                |
| Categorias       | CRUD             | —             | lectura        | lectura          | —                |
| Proveedores      | CRUD             | —             | lectura        | lectura          | —                |
| Clientes         | CRUD             | CRUD          | —              | lectura          | —                |
| Transacciones    | ventas + compras | solo ventas   | solo compras   | —                | —                |
| Historial        | ventas + compras | solo ventas   | solo compras   | ventas + compras | ventas + compras |
| Empleados        | CRUD             | —             | —              | lectura          | —                |
| Gestion permisos | si               | —             | —              | —                | —                |

---

## Estructura del proyecto

```
BD-quetzal_shop/
├── back-end/
│   ├── database/
│   │   ├── connection.py          # Pool de conexiones psycopg2
│   │   └── queries/               # SQL por entidad + reportes
│   ├── controllers/               # Logica de negocio
│   ├── routes/                    # Endpoints FastAPI
│   ├── schemas/                   # Modelos Pydantic
│   ├── sql/
│   │   ├── schema.sql             # DDL — tablas, indices, constraints
│   │   ├── views.sql              # Vistas SQL
│   │   └── seed.sql               # Datos de prueba (25+ registros)
│   ├── Dockerfile
│   ├── main.py
│   └── requirements.txt
├── front-end/
│   ├── src/
│   │   ├── app.css                # Tokens de diseño, utilidades globales, dark mode
│   │   ├── lib/
│   │   │   ├── api.ts             # Helper apiFetch con auth header
│   │   │   ├── csv.ts             # Exportacion CSV
│   │   │   ├── icons.ts           # Paths SVG de iconos
│   │   │   ├── components/
│   │   │   │   ├── Icon.svelte    # Icono SVG generico
│   │   │   │   ├── Modal.svelte   # Ventana modal reutilizable
│   │   │   │   ├── Navbar.svelte  # Barra superior con menu hamburguesa
│   │   │   │   ├── Sidebar.svelte # Navegacion lateral (slide-in en movil)
│   │   │   │   ├── StatCard.svelte# Tarjeta de estadistica
│   │   │   │   └── Toast.svelte   # Notificaciones flotantes
│   │   │   └── stores/
│   │   │       ├── auth.ts        # Sesion y token JWT
│   │   │       ├── filtros.ts     # Estado de filtros por pagina
│   │   │       └── theme.ts       # Tema claro/oscuro con persistencia
│   │   └── routes/
│   │       ├── +layout.svelte     # Root layout
│   │       ├── +page.svelte       # Login
│   │       └── dashboard/
│   │           ├── +layout.svelte # Shell autenticado (Navbar + Sidebar)
│   │           ├── +page.svelte   # Dashboard con reportes
│   │           ├── productos/     # CRUD de productos con filtros
│   │           ├── categorias/    # CRUD de categorias
│   │           ├── proveedores/   # CRUD de proveedores
│   │           ├── clientes/      # CRUD de clientes
│   │           ├── empleados/     # CRUD de empleados
│   │           ├── transacciones/ # Formulario nueva venta / compra
│   │           ├── historial/     # Historial de ventas y compras (solo lectura)
│   │           ├── ventas/        # Vista de ventas
│   │           └── compras/       # Vista de compras
│   ├── tests/
│   │   ├── utils.test.ts          # Tests de funciones utilitarias
│   │   └── csv.test.ts            # Tests de exportacion CSV
│   ├── Dockerfile
│   └── package.json
├── doc/
│   └── Proyecto_2.pdf
├── docker-compose.yml
├── .env.example
└── README.md
```

---

## Aspectos de rubrica

> El frontend fue desarrollado con **SvelteKit** en lugar de React, con autorizacion del catedratico. La seccion II documenta el sinonimo de cada concepto de React en Svelte.

---

### I. Arquitectura y API REST

**Endpoints REST documentados**
FastAPI genera documentacion OpenAPI automaticamente en `http://localhost:8000/docs` (Swagger UI) y `http://localhost:8000/redoc`. Todos los endpoints aparecen con sus parametros, esquemas de request/response y codigos de respuesta.

**CRUD completo para al menos 2 entidades**
Se implemento CRUD completo (GET, POST, PATCH, DELETE) para las siguientes entidades, cada una con su propio router en `back-end/routes/`:

- `Productos` — `/productos`
- `Clientes` — `/clientes`
- `Categorias` — `/categorias`
- `Proveedores` — `/proveedores`
- `Empleados` — `/empleados`
- `Ventas` — `/ventas`
- `Compras` — `/compras`

**Manejo de errores en la API**
Todos los endpoints retornan codigos HTTP correctos: `200` exito, `201` creacion, `404` recurso no encontrado, `409` conflicto de clave foranea, `422` datos invalidos. Los errores siempre se retornan como JSON con el campo `detail`.

**Endpoint de agregacion de datos**
El router `/reportes` expone cinco endpoints que agregan datos reales de la base de datos:

| Endpoint | Tecnica SQL | Descripcion |
|---|---|---|
| `GET /reportes/stats` | agregaciones simples | ventas del dia, compras del mes, stock bajo, empleados activos |
| `GET /reportes/top-productos` | CTE + GROUP BY | top 5 productos mas vendidos por unidades e ingresos |
| `GET /reportes/ventas-por-metodo` | GROUP BY + HAVING | ventas agrupadas por metodo de pago |
| `GET /reportes/clientes-activos` | subquery EXISTS | clientes con al menos una venta registrada |
| `GET /reportes/productos-bajo-vendidos` | subquery IN | productos con stock critico que han sido vendidos |

---

### II. Frontend — SvelteKit (equivalentes a React)

El proyecto usa SvelteKit como framework frontend, con autorizacion del catedratico. A continuacion se documenta como cada concepto de React exigido en la rubrica fue implementado con su equivalente directo en Svelte.

**Navegacion entre vistas → SvelteKit file-based routing**
En lugar de React Router con componentes `<Route>`, SvelteKit genera las rutas automaticamente a partir de la estructura de carpetas en `src/routes/`. El proyecto tiene 11 rutas distintas: el login en la raiz (`/`), el dashboard principal y nueve modulos del sistema (productos, categorias, clientes, proveedores, empleados, transacciones, historial, ventas y compras). La navegacion protegida —redireccion al login si no hay sesion activa— se maneja en el layout compartido del dashboard (`src/routes/dashboard/+layout.svelte`), de manera analoga a un componente `<PrivateRoute>` de React Router.

**Estado global con React Context → Svelte writable store**
Svelte reemplaza el patron `createContext` + `Provider` + `useContext` con stores exportados desde modulos compartidos en `src/lib/stores/`. El proyecto usa tres stores globales: `auth.ts` gestiona la sesion del usuario y el token JWT con persistencia en `localStorage` y metodos `login` y `logout` accesibles desde cualquier componente; `filtros.ts` mantiene el estado de busqueda y filtros de cada pagina del dashboard; y `theme.ts` controla el tema claro/oscuro. No se requiere ningun Provider en el arbol de componentes: cualquier archivo que importe el store puede leer y modificar el estado global directamente.

**useState + useEffect + useMemo/useCallback → reactividad de Svelte**
Svelte maneja estos cuatro hooks con mecanismos propios del compilador. Las variables declaradas con `let` en el bloque `<script>` son reactivas por defecto —equivalente a `useState`—: cualquier reasignacion dispara una actualizacion del DOM sin necesidad de un setter explicito. Los efectos de montaje se implementan con `onMount`, que se ejecuta una unica vez al insertar el componente en el DOM, cumpliendo el rol de `useEffect` con arreglo de dependencias vacio. Los valores derivados se expresan con instrucciones reactivas prefijadas con `$:`, que el compilador recalcula automaticamente cada vez que cambia alguna de sus dependencias, reemplazando `useMemo`; en `productos/+page.svelte` esto se usa para calcular la lista filtrada cada vez que cambia el store de filtros o el arreglo de productos. Las funciones de evento —handlers de formularios, apertura y cierre de modales, acciones de tabla— se definen directamente en `<script>` sin necesitar `useCallback`, porque Svelte no re-ejecuta el bloque de script en cada render.

**Flujo de estado complejo con useReducer → custom store con acciones**
El archivo `src/lib/stores/filtros.ts` implementa el patron equivalente a `useReducer`: cada store de filtros expone metodos nombrados (`setBusqueda`, `setCategoria`, `setStockStatus`, `reset`) en lugar de un `set` generico, de manera que el estado solo puede modificarse a traves de acciones semanticas definidas, analogas a los `type` de un reducer. Este patron se aplica en siete paginas del dashboard —productos, ventas, compras, clientes, categorias, proveedores y empleados—, cada una con su propio store de filtros tipado en TypeScript.

**Formularios controlados con validacion → bind:value + validacion en submit**
En lugar del patron `value={state}` + `onChange` de React, Svelte usa la directiva `bind:value` para sincronizacion bidireccional automatica entre cada campo del formulario y la variable correspondiente. La validacion del lado del cliente ocurre dentro de la funcion `saveForm()` antes de cualquier llamada a la API: si algun campo requerido esta vacio, se muestra un mensaje de error en pantalla y se interrumpe el envio sin recargar la pagina. Todos los formularios de creacion y edicion se presentan en el componente modal reutilizable `Modal.svelte`.

**Reporte visible con datos reales → Dashboard**
El dashboard en `/dashboard` consume cinco endpoints del router `/reportes` y presenta los resultados directamente en la interfaz: tarjetas con estadisticas del dia (ventas, compras del mes, stock bajo, empleados activos), top 5 productos mas vendidos con unidades e ingresos, ultimas ventas registradas con cliente y metodo de pago, ventas agrupadas por metodo de pago, y productos con stock critico que han registrado ventas. Cada seccion indica la tecnica SQL que lo respalda (CTE, GROUP BY, HAVING, EXISTS, subquery IN).

**Manejo visible de errores → mensajes en pantalla**
Cada pagina con operaciones CRUD distingue dos contextos de error: los errores de validacion o respuesta fallida del servidor se muestran dentro del modal activo antes de que el usuario lo cierre; los errores al cargar o eliminar datos aparecen encima de la tabla principal como mensaje de pagina. Los botones de accion muestran texto de estado durante las operaciones en curso (`Guardando…`, `Agregando…`) y se deshabilitan para evitar envios duplicados. Las tablas vacias diferencian entre "sin resultados por filtros activos" y "sin registros en la base de datos".

---

### III. Calidad de codigo

**ESLint configurado sin errores**
Se configuro ESLint con soporte para TypeScript y Svelte mediante `.eslintrc.json`. Para verificar:

```bash
docker run --rm bd-quetzal_shop-frontend npm run lint
```

Resultado esperado: `0 errors`.

**Pruebas automatizadas con Vitest**
Se implementaron pruebas en 2 archivos usando Vitest:

| Archivo | Tests | Que verifica |
|---|---|---|
| `tests/utils.test.ts` | 9 | `formatCurrency`, `stockStatus`, `formatFecha` |
| `tests/csv.test.ts` | 1 | Escape de valores en exportacion CSV |

Para correr las pruebas:

```bash
docker run --rm bd-quetzal_shop-frontend npm run test
```

Resultado esperado: `10 passed`.

---

### IV. Despliegue y entrega

**El proyecto levanta con un solo comando**
Los tres servicios (db, backend, frontend) se orquestan con Docker Compose. La base de datos incluye healthcheck para garantizar que el backend no arranque antes de que PostgreSQL este listo. Las credenciales de base de datos son `proy2` / `secret` tal como lo exige la rubrica.

Tanto `docker-compose.yml` como `.env` estan en `.gitignore`; el repositorio incluye `docker-compose.yml.example` y `.env.example` con todos los valores listos para usar. Los pasos completos desde cero:

```bash
cp docker-compose.yml.example docker-compose.yml
cp .env.example .env
docker compose up
```

| Servicio          | URL                        |
|-------------------|----------------------------|
| Frontend          | http://localhost:5173      |
| Backend API       | http://localhost:8000      |
| Documentacion API | http://localhost:8000/docs |

---

### V. Avanzado

**Autenticacion con login/logout manejada mediante store global**
Se implemento un sistema de autenticacion completo con JWT. El login consume `POST /auth/login`, guarda el token en `localStorage` y lo distribuye a toda la aplicacion mediante el store `auth` en `src/lib/stores/auth.ts`. El logout limpia el store y redirige al login. El estado de sesion es accesible en cualquier componente con `$auth`.

**Exportar reportes a CSV desde la UI**
Todas las tablas del dashboard incluyen un boton "Exportar CSV" que descarga los datos actualmente visibles respetando los filtros aplicados. Implementado en `src/lib/csv.ts` y disponible en: productos, ventas, compras, clientes, proveedores, empleados e historial.

**Modo claro / oscuro**
La aplicacion soporta modo claro y oscuro con persistencia en `localStorage`. El tema se cambia desde el boton de la barra superior y se aplica globalmente mediante el atributo `data-theme` en el elemento `<html>`. Implementado en `src/lib/stores/theme.ts` usando tokens CSS (variables custom) definidos en `app.css`.

**Diseno responsivo**
La interfaz funciona correctamente en pantallas de escritorio, tablet y movil:

- **Navbar**: en pantallas menores a 768px aparece un boton hamburguesa y se oculta el nombre de usuario.
- **Sidebar**: en movil se convierte en un panel deslizable que se abre al presionar el hamburguesa, con overlay semitransparente y cierre automatico al navegar.
- **Grids de estadisticas**: pasan de 4 columnas a 2 columnas en tablet/movil.
- **Formularios modales**: la cuadricula de 2 columnas colapsa a 1 columna en pantallas pequeñas.
- **Tablas**: scroll horizontal para no romper el layout en pantallas angostas.
- **Barras de filtros**: los controles se apilan verticalmente con `flex-wrap`.
