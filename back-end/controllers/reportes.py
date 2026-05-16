from database.queries import reportes as reportes_query


# Stats generales para el dashboard: ventas hoy, compras del mes, stock bajo y empleados
def get_stats() -> dict:
    return reportes_query.get_stats()


# Top 5 productos más vendidos usando CTE + GROUP BY
def get_top_productos() -> list:
    return reportes_query.get_top_productos()


# Ventas agrupadas por método de pago usando GROUP BY + HAVING
def get_ventas_por_metodo() -> list:
    return reportes_query.get_ventas_por_metodo()


# Clientes que tienen al menos una venta registrada usando EXISTS
def get_clientes_activos() -> list:
    return reportes_query.get_clientes_activos()


# Productos con stock bajo que han sido vendidos alguna vez usando IN
def get_productos_bajo_vendidos() -> list:
    return reportes_query.get_productos_bajo_vendidos()


# Llama a sp_reporte_ventas_periodo con el rango de fechas dado
def get_ventas_periodo(fecha_inicio: str, fecha_fin: str) -> list:
    return reportes_query.get_ventas_periodo(fecha_inicio, fecha_fin)
