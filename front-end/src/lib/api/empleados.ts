import { apiFetch } from '$lib/api';
import { parseJson } from './base';

export interface Empleado {
  id: number;
  usuario_id: number;
  dpi: string;
  nombre: string;
  telefono: string;
  cargo: string;
  fecha_contrato: string;
  estado: string;
  email: string;
  rol_id: number;
  rol_nombre: string;
}

export interface EmpleadoForm {
  nombre: string;
  email: string;
  password: string;
  dpi: string;
  telefono: string;
  cargo: string;
  fecha_contrato: string;
  rol_id: string;
}

export interface EmpleadoEditForm {
  nombre: string;
  telefono: string;
  cargo: string;
  estado: string;
  rol_id: string;
}

export const empleadosApi = {
  getAll:  (token: string) =>
    apiFetch('/empleados', token).then(r => parseJson<Empleado[]>(r)),

  create:  (token: string, data: EmpleadoForm) =>
    apiFetch('/empleados', token, { method: 'POST', body: JSON.stringify(data) }).then(r => parseJson<Empleado>(r)),

  update:  (token: string, id: number, data: EmpleadoEditForm) =>
    apiFetch(`/empleados/${id}`, token, { method: 'PATCH', body: JSON.stringify(data) }).then(r => parseJson<Empleado>(r)),

  delete:  (token: string, id: number) =>
    apiFetch(`/empleados/${id}`, token, { method: 'DELETE' }).then(r => parseJson(r)),
};
