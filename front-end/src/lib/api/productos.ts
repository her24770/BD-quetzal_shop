import { apiFetch } from '$lib/api';
import { parseJson } from './base';

export interface Producto {
  id: number;
  nombre: string;
  descripcion: string;
  precio: number;
  stock: number;
  stock_minimo: number;
  categoria_id: number;
  categoria: string;
}

export interface ProductoForm {
  nombre: string;
  descripcion: string;
  precio: number;
  stock: number;
  stock_minimo: number;
  categoria_id: number;
}

export const productosApi = {
  getAll:  (token: string) =>
    apiFetch('/productos', token).then(r => parseJson<Producto[]>(r)),

  create:  (token: string, data: ProductoForm) =>
    apiFetch('/productos', token, { method: 'POST', body: JSON.stringify(data) }).then(r => parseJson<Producto>(r)),

  update:  (token: string, id: number, data: Partial<ProductoForm>) =>
    apiFetch(`/productos/${id}`, token, { method: 'PATCH', body: JSON.stringify(data) }).then(r => parseJson<Producto>(r)),

  delete:  (token: string, id: number) =>
    apiFetch(`/productos/${id}`, token, { method: 'DELETE' }).then(r => parseJson(r)),
};
