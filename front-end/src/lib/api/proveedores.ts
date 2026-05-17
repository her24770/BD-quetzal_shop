import { apiFetch } from '$lib/api';
import { parseJson } from './base';

export interface Proveedor {
  id: number;
  nombre: string;
  telefono: string;
  email: string;
  direccion: string;
}

export interface ProveedorForm {
  nombre: string;
  telefono: string;
  email: string;
  direccion: string;
}

export const proveedoresApi = {
  getAll:  (token: string) =>
    apiFetch('/proveedores', token).then(r => parseJson<Proveedor[]>(r)),

  create:  (token: string, data: ProveedorForm) =>
    apiFetch('/proveedores', token, { method: 'POST', body: JSON.stringify(data) }).then(r => parseJson<Proveedor>(r)),

  update:  (token: string, id: number, data: Partial<ProveedorForm>) =>
    apiFetch(`/proveedores/${id}`, token, { method: 'PATCH', body: JSON.stringify(data) }).then(r => parseJson<Proveedor>(r)),

  delete:  (token: string, id: number) =>
    apiFetch(`/proveedores/${id}`, token, { method: 'DELETE' }).then(r => parseJson(r)),
};
