import { apiFetch } from '$lib/api';
import { parseJson } from './base';

export interface Venta {
  id: number;
  fecha: string;
  total: number;
  descuento: number;
  cliente: string;
  nit: string;
  empleado: string;
  metodo_pago: string;
}

export interface VentaForm {
  cliente_id: number;
  metodo_pago_id: number;
  descuento: number;
  items: { producto_id: number; cantidad: number }[];
}

export interface MetodoPago {
  id: number;
  metodo: string;
}

export const ventasApi = {
  getAll:       (token: string) =>
    apiFetch('/ventas', token).then(r => parseJson<Venta[]>(r)),

  getMetodos:   (token: string) =>
    apiFetch('/ventas/metodos-pago', token).then(r => parseJson<MetodoPago[]>(r)),

  create:       (token: string, data: VentaForm) =>
    apiFetch('/ventas', token, { method: 'POST', body: JSON.stringify(data) }).then(r => parseJson(r)),
};
