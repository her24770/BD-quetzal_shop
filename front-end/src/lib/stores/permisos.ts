import { writable, get } from 'svelte/store';

type PermisosMap = Record<string, string[]>;

function createPermisosStore() {
  const { subscribe, set } = writable<PermisosMap>({});

  return {
    subscribe,
    load(data: PermisosMap) { set(data); },
    reset()                 { set({}); },
  };
}

export const permisos = createPermisosStore();

export function can(tabla: string, op: 'SELECT' | 'INSERT' | 'UPDATE' | 'DELETE'): boolean {
  return get(permisos)[tabla]?.includes(op) ?? false;
}
