import { apiFetch } from '$lib/api';
import { parseJson } from './base';

export interface Cliente {
  id: number;
  nombre: string;
  nit: string;
  telefono: string;
  direccion: string;
}

export interface ClienteForm {
  nombre: string;
  nit: string;
  telefono: string;
  direccion: string;
}

export const clientesApi = {
  getAll:  (token: string) =>
    apiFetch('/clientes', token).then(r => parseJson<Cliente[]>(r)),

  create:  (token: string, data: ClienteForm) =>
    apiFetch('/clientes', token, { method: 'POST', body: JSON.stringify(data) }).then(r => parseJson<Cliente>(r)),

  update:  (token: string, id: number, data: Partial<ClienteForm>) =>
    apiFetch(`/clientes/${id}`, token, { method: 'PATCH', body: JSON.stringify(data) }).then(r => parseJson<Cliente>(r)),

  delete:  (token: string, id: number) =>
    apiFetch(`/clientes/${id}`, token, { method: 'DELETE' }).then(r => parseJson(r)),
};
