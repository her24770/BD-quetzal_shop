import { apiFetch } from '$lib/api';
import { parseJson } from './base';

export interface Rol { id: number; nombre: string; pg_user: string; }
export type PermisosMap = Record<string, string[]>;

export const adminApi = {
  getRoles: (token: string) =>
    apiFetch('/admin/roles', token).then(r => parseJson<Rol[]>(r)),

  getPermisos: (token: string, rolId: number) =>
    apiFetch(`/admin/roles/${rolId}/permisos`, token).then(r => parseJson<PermisosMap>(r)),

  grant: (token: string, rolId: number, tabla: string, operacion: string) =>
    apiFetch(`/admin/roles/${rolId}/permisos`, token, {
      method: 'POST',
      body: JSON.stringify({ tabla, operacion }),
    }).then(r => parseJson<{ message: string }>(r)),

  revoke: (token: string, rolId: number, tabla: string, operacion: string) =>
    apiFetch(`/admin/roles/${rolId}/permisos/${tabla}/${operacion}`, token, {
      method: 'DELETE',
    }).then(r => parseJson<{ message: string }>(r)),
};
