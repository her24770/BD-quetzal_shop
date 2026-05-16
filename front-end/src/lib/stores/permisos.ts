import { writable, get } from 'svelte/store';

type PermisosMap = Record<string, string[]>;

function createPermisosStore() {
  const stored = typeof localStorage !== 'undefined'
    ? localStorage.getItem('permisos')
    : null;

  const initial: PermisosMap = stored ? JSON.parse(stored) : {};
  const { subscribe, set } = writable<PermisosMap>(initial);

  return {
    subscribe,
    load(data: PermisosMap) {
      localStorage.setItem('permisos', JSON.stringify(data));
      set(data);
    },
    reset() {
      localStorage.removeItem('permisos');
      set({});
    },
  };
}

export const permisos = createPermisosStore();

export function can(tabla: string, op: 'SELECT' | 'INSERT' | 'UPDATE' | 'DELETE'): boolean {
  return get(permisos)[tabla]?.includes(op) ?? false;
}
