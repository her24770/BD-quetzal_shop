import { apiFetch } from '$lib/api';
import { parseJson } from './base';

export interface Stats {
  ventas_hoy:  { count: number; total: number };
  compras_mes: number;
  stock_bajo:  number;
  empleados:   { total: number; activos: number };
}
export interface TopProducto  { nombre: string; categoria: string; total_vendido: number; total_ingresos: number; }
export interface VentaMetodo  { metodo: string; cantidad: number; total: number; }
export interface ProductoBajo { nombre: string; stock: number; stock_minimo: number; categoria: string; }
export interface VentaReciente { id: number; fecha: string; total: number; cliente: string; empleado: string; metodo_pago: string; }

export const reportesApi = {
  getStats:           (token: string) =>
    apiFetch('/reportes/stats', token).then(r => parseJson<Stats>(r)),

  getTopProductos:    (token: string) =>
    apiFetch('/reportes/top-productos', token).then(r => parseJson<TopProducto[]>(r)),

  getBajoVendidos:    (token: string) =>
    apiFetch('/reportes/productos-bajo-vendidos', token).then(r => parseJson<ProductoBajo[]>(r)),

  getVentasPorMetodo: (token: string) =>
    apiFetch('/reportes/ventas-por-metodo', token).then(r => parseJson<VentaMetodo[]>(r)),

  getVentasRecientes: (token: string, limit = 5) =>
    apiFetch('/ventas', token).then(r => parseJson<VentaReciente[]>(r)).then(d => d.slice(0, limit)),
};
