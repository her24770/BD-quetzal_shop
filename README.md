# QuetzalShop — Sistema de gestion de tienda

Proyecto 2 — cc3088 Bases de Datos 1 | UVG Ciclo 1 2026

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

### 2. Crear el archivo de variables de entorno

```bash
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
docker compose up
```

Docker Compose construye las imagenes y levanta tres servicios en orden:

1. **db** — PostgreSQL 15. Al iniciarse por primera vez carga automaticamente `schema.sql`, `views.sql` y `seed.sql`, creando tablas, vistas y datos de prueba.
2. **backend** — FastAPI en `http://localhost:8000`. Espera a que la base de datos este lista (healthcheck) antes de arrancar.
3. **frontend** — SvelteKit en `http://localhost:5173`. Espera a que el backend este disponible.

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

| Servicio        | URL                        |
|-----------------|----------------------------|
| Frontend        | http://localhost:5173      |
| Backend API     | http://localhost:8000      |
| Documentacion   | http://localhost:8000/docs |

---

## Credenciales de prueba

### Acceso a la aplicacion web

| Rol       | Correo                     | Contrasena |
|-----------|----------------------------|------------|
| Admin     | admin@quetzalshop.com      | admin123   |
| Cajero    | cajero1@quetzalshop.com    | cajero123  |
| Bodeguero | bodeguero1@quetzalshop.com | bodega123  |

### Acceso directo a la base de datos

| Parametro  | Valor          |
|------------|----------------|
| Host       | localhost      |
| Puerto     | 5432           |
| Base       | quetzalshop_db |
| Usuario    | proy2          |
| Contrasena | secret         |

---

## Roles y permisos

| Modulo        | Admin (1)       | Cajero (2)   | Bodeguero (3) |
|---------------|:---------------:|:------------:|:-------------:|
| Dashboard     | si              | si           | si            |
| Productos     | CRUD            | lectura      | CRUD          |
| Categorias    | CRUD            | --           | lectura       |
| Proveedores   | CRUD            | --           | lectura       |
| Clientes      | CRUD            | CRUD         | --            |
| Transacciones | ventas + compras| solo ventas  | solo compras  |
| Historial     | ventas + compras| solo ventas  | solo compras  |
| Empleados     | CRUD            | --           | --            |

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

El proyecto usa SvelteKit como framework frontend. A continuacion se documenta el concepto de React que exige la rubrica y su equivalente directo en Svelte.

**Navegacion entre vistas → SvelteKit file-based routing**
React Router define rutas con `<Route path="...">`. SvelteKit usa el sistema de archivos: cada archivo `+page.svelte` dentro de `src/routes/` es automaticamente una ruta. El proyecto tiene 11 rutas distintas:

| Ruta | Archivo |
|------|---------|
| `/` | `src/routes/+page.svelte` (login) |
| `/dashboard` | `src/routes/dashboard/+page.svelte` |
| `/dashboard/productos` | `src/routes/dashboard/productos/+page.svelte` |
| `/dashboard/categorias` | `src/routes/dashboard/categorias/+page.svelte` |
| `/dashboard/clientes` | `src/routes/dashboard/clientes/+page.svelte` |
| `/dashboard/proveedores` | `src/routes/dashboard/proveedores/+page.svelte` |
| `/dashboard/empleados` | `src/routes/dashboard/empleados/+page.svelte` |
| `/dashboard/transacciones` | `src/routes/dashboard/transacciones/+page.svelte` |
| `/dashboard/historial` | `src/routes/dashboard/historial/+page.svelte` |
| `/dashboard/ventas` | `src/routes/dashboard/ventas/+page.svelte` |
| `/dashboard/compras` | `src/routes/dashboard/compras/+page.svelte` |

La navegacion protegida (redireccion si no hay sesion activa) se maneja en `src/routes/dashboard/+layout.svelte`.

**Estado global con React Context → Svelte writable store**
React Context requiere `createContext`, un `Provider` y `useContext` en cada componente. En Svelte, un `writable` store exportado desde `src/lib/stores/auth.ts` cumple el mismo rol: cualquier componente que lo importe puede leer el estado global con `$auth`. El store persiste el token JWT en `localStorage` y expone los metodos `login` y `logout`.

**useState + useEffect + useMemo/useCallback → reactividad de Svelte**

| Hook de React | Equivalente en Svelte |
|---|---|
| `useState(valor)` | `let variable = valor` — Svelte detecta cambios automaticamente |
| `useEffect(() => {}, [])` | `onMount(async () => { ... })` — se ejecuta al montar el componente |
| `useMemo(() => calc, [deps])` | `$: computado = expresion` — se recalcula cuando cambian sus dependencias |
| `useCallback(fn, [deps])` | Funciones normales en `<script>` — Svelte no requiere memoizacion manual |

Ejemplo real en `productos/+page.svelte`:
```js
// useMemo equivalente — se recalcula cuando cambia el store o los datos
$: productosFiltrados = productos.filter(p => { ... });

// useEffect equivalente
onMount(async () => {
  const r = await apiFetch('/productos', token);
  if (r.ok) productos = await r.json();
});
```

**Flujo de estado complejo con useReducer → custom store con acciones**
`useReducer` centraliza el estado y lo modifica solo mediante `dispatch({ type, payload })`. En Svelte el patron equivalente es un custom store que expone metodos nombrados. Implementado en `src/lib/stores/filtros.ts` para todas las paginas del dashboard:

```js
// Svelte — equivalente a useReducer
function createFiltrosProductoStore() {
  const { subscribe, set, update } = writable({ busqueda: '', categoria_id: '', stock_status: 'todos' });
  return {
    subscribe,
    setBusqueda:    (v)  => update(s => ({ ...s, busqueda: v })),
    setCategoria:   (id) => update(s => ({ ...s, categoria_id: id })),
    setStockStatus: (v)  => update(s => ({ ...s, stock_status: v })),
    reset:          ()   => set({ busqueda: '', categoria_id: '', stock_status: 'todos' }),
  };
}
```

Este patron se aplica en las paginas de productos, ventas, compras, clientes, categorias, proveedores y empleados.

**Formularios controlados con validacion → bind:value + validacion en submit**
React usa `value={state}` + `onChange` para formularios controlados. Svelte usa `bind:value` que sincroniza automaticamente el input con la variable. La validacion ocurre en `saveForm()` antes de llamar a la API, mostrando el mensaje de error si algun campo requerido esta vacio.

```js
if (!form.nombre || !form.precio || !form.stock) {
  errorMsg = 'Completa todos los campos obligatorios';
  return;
}
```

Los formularios de creacion y edicion se presentan en ventanas modales (`Modal.svelte`) en todas las paginas con CRUD.

**Reporte visible con datos reales → Dashboard**
El dashboard (`/dashboard`) muestra cinco reportes con datos reales consumidos desde los endpoints de `/reportes`:

1. Tarjetas de estadisticas — ventas del dia, stock bajo, compras del mes, empleados activos
2. Top 5 productos mas vendidos con unidades e ingresos totales
3. Ultimas ventas registradas con cliente, empleado y metodo de pago
4. Ventas agrupadas por metodo de pago (GROUP BY + HAVING)
5. Productos con stock critico que han sido vendidos (subquery IN)

Cada reporte muestra la tecnica SQL que lo produce (CTE, GROUP BY, EXISTS, IN, VIEW).

**Manejo visible de errores → mensajes en pantalla**
Cada pagina con operaciones CRUD muestra errores directamente en la interfaz sin recargar la pagina:

- `form-error` — error de validacion o respuesta fallida del servidor, aparece dentro del modal
- `page-error` — error al eliminar o al cargar datos, aparece antes de la tabla
- Texto de estado en botones (`Guardando…`, `Agregando…`) mientras la operacion esta en curso
- Mensaje diferenciado cuando no hay resultados por filtros activos vs. tabla realmente vacia

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

```bash
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
