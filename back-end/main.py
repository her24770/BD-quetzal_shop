from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from routes import auth, categorias, productos, proveedores, clientes, empleados, ventas, compras, reportes, admin
from config import settings

# Inicialización de la aplicación
app = FastAPI(
    title="QuetzalShop API",
    description="Backend del sistema QuetzalShop",
    version="1.0.0",
)

# CORS — permite que el frontend (SvelteKit o React) haga requests al backend.
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Registro de routers
app.include_router(auth.router,       prefix="/auth",       tags=["Autenticación"])
app.include_router(categorias.router, prefix="/categorias", tags=["Categorías"])
app.include_router(productos.router,   prefix="/productos",   tags=["Productos"])
app.include_router(proveedores.router, prefix="/proveedores", tags=["Proveedores"])
app.include_router(clientes.router,    prefix="/clientes",    tags=["Clientes"])
app.include_router(empleados.router,   prefix="/empleados",   tags=["Empleados"])
app.include_router(ventas.router,      prefix="/ventas",      tags=["Ventas"])
app.include_router(compras.router,     prefix="/compras",     tags=["Compras"])
app.include_router(reportes.router,    prefix="/reportes",    tags=["Reportes"])
app.include_router(admin.router,       prefix="/admin",        tags=["Admin"])


# verificar que el servidor está vivo# ---------------------------------------------------------------------------
@app.get("/", tags=["Health"])
def root():
    return {"status": "ok", "app": "QuetzalShop API"}
