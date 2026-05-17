import { apiFetch } from '$lib/api';
import { parseJson } from './base';

export interface Compra {
  id: number;
  fecha: string;
  total: number;
  numero_factura: string;
  empleado: string;
}

export interface CompraForm {
  numero_factura: string;
  items: { producto_id: number; proveedor_id: number; cantidad: number; precio_costo: number }[];
}

export const comprasApi = {
  getAll:  (token: string) =>
    apiFetch('/compras', token).then(r => parseJson<Compra[]>(r)),

  create:  (token: string, data: CompraForm) =>
    apiFetch('/compras', token, { method: 'POST', body: JSON.stringify(data) }).then(r => parseJson(r)),
};
