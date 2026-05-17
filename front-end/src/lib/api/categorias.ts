import { apiFetch } from '$lib/api';
import { parseJson } from './base';

export interface Categoria {
  id: number;
  nombre: string;
  descripcion: string;
}

export interface CategoriaForm {
  nombre: string;
  descripcion: string;
}

export const categoriasApi = {
  getAll:  (token: string) =>
    apiFetch('/categorias', token).then(r => parseJson<Categoria[]>(r)),

  create:  (token: string, data: CategoriaForm) =>
    apiFetch('/categorias', token, { method: 'POST', body: JSON.stringify(data) }).then(r => parseJson<Categoria>(r)),

  update:  (token: string, id: number, data: Partial<CategoriaForm>) =>
    apiFetch(`/categorias/${id}`, token, { method: 'PATCH', body: JSON.stringify(data) }).then(r => parseJson<Categoria>(r)),

  delete:  (token: string, id: number) =>
    apiFetch(`/categorias/${id}`, token, { method: 'DELETE' }).then(r => parseJson(r)),
};
