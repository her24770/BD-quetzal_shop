# QuetzalShop — Sistema gestion de data

Proyecto 2 — cc3088 Bases de Datos 1 | UVG Ciclo 1 2026

Sistema de punto de venta (POS) para una tienda, compuesto por una base de datos PostgreSQL, una API REST con FastAPI y una interfaz web con SvelteKit. El stack completo se levanta con un solo comando mediante Docker Compose.

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

Copiar el archivo de ejemplo y ajustar si se desea cambiar puertos:

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

Docker Compose construira las imagenes y levantara tres servicios en orden:

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

| Servicio   | URL                          |
|------------|------------------------------|
| Frontend   | http://localhost:5173        |
| Backend API| http://localhost:8000        |
| Docs API   | http://localhost:8000/docs   |

---

## Credenciales de prueba

### Acceso a la aplicacion web

Valores predeterminados en roles


| Rol       | Correo                      | Contrasena |
|-----------|-----------------------------|------------|
| Admin     | admin@quetzalshop.com       | admin123   |
| Cajero    | cajero1@quetzalshop.com     | cajero123  |
| Bodeguero | bodeguero1@quetzalshop.com  | bodega123  |

### Acceso directo a la base de datos (opcional)

| Parametro  | Valor          |
|------------|----------------|
| Host       | localhost      |
| Puerto     | 5432           |
| Base       | quetzalshop_db |
| Usuario    | proy2          |
| Contrasena | secret         |

---

## Roles y permisos

| Modulo        | Admin (1) | Cajero (2) | Bodeguero (3) |
|---------------|:---------:|:----------:|:-------------:|
| Dashboard     | si        | si         | si            |
| Productos     | CRUD      | lectura    | CRUD          |
| Categorias    | CRUD      | --         | lectura       |
| Proveedores   | CRUD      | --         | lectura       |
| Clientes      | CRUD      | CRUD       | --            |
| Transacciones | ventas + compras | solo ventas | solo compras |
| Empleados     | CRUD      | --         | --            |

---

## Estructura del proyecto

```
quetzal_shop-backend/
├── back-end/
│   ├── database/
│   │   ├── connection.py       # Pool de conexiones psycopg2
│   │   └── queries/            # SQL por entidad + reportes
│   ├── controllers/            # Logica de negocio
│   ├── routes/                 # Endpoints FastAPI
│   ├── schemas/                # Modelos Pydantic
│   ├── sql/
│   │   ├── schema.sql          # DDL — tablas, indices, constraints
│   │   ├── views.sql           # Vistas SQL
│   │   └── seed.sql            # Datos de prueba (25+ registros)
│   ├── Dockerfile
│   ├── main.py
│   └── requirements.txt
├── front-end/
│   ├── src/
│   │   ├── lib/
│   │   │   ├── components/     # StatCard, Sidebar, Navbar, etc.
│   │   │   ├── stores/         # auth store (Svelte writable)
│   │   │   └── api.ts          # apiFetch helper
│   │   └── routes/
│   │       ├── +page.svelte    # Login
│   │       └── dashboard/      # Paginas protegidas por rol
│   ├── Dockerfile
│   └── package.json
├── doc/
│   └── Proyecto_2.pdf
├── docker-compose.yml
├── .env.example
└── README.md
```

---

## Cobertura de requisitos SQL

| Requisito                          | Implementacion                                               |
|------------------------------------|--------------------------------------------------------------|
| JOINs multi-tabla (3+)             | Ventas, items_venta, clientes, empleados, metodo_pago        |
| Subquery con IN                    | Productos con stock bajo que han sido vendidos               |
| Subquery con EXISTS                | Clientes que tienen al menos una venta registrada            |
| GROUP BY + HAVING + agregacion     | Ventas agrupadas por metodo de pago con totales              |
| CTE (WITH)                         | Top 5 productos mas vendidos                                 |
| VIEW                               | `v_ventas_completo` — detalle completo de cada venta         |
| Transaccion con ROLLBACK           | Registro de venta: inserta encabezado + items atomicamente   |

Todos los resultados se muestran en el Dashboard con etiquetas que identifican el tipo de consulta SQL utilizado.

---

## Notas de desarrollo

- La API no usa ORM; todas las consultas son SQL directo con `psycopg2`.
- El frontend consume la API mediante JWT almacenado en `localStorage`.
- Los errores de restriccion de clave foranea (FK) se capturan y se retornan como HTTP 409 con mensaje descriptivo.
