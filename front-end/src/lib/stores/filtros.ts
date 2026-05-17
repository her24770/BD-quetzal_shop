import { writable } from 'svelte/store';

function makeStore<T extends object>(initial: T) {
  const { subscribe, set, update } = writable<T>({ ...initial });
  return {
    subscribe,
    set: (v: Partial<T>) => update((s: T) => ({ ...s, ...v })),
    reset: () => set({ ...initial }),
  };
}

export const filtrosProducto  = makeStore({ busqueda: '', categoria_id: '', stock_status: 'todos' as 'todos' | 'ok' | 'bajo' | 'agotado' });
export const filtrosClientes  = makeStore({ busqueda: '' });
export const filtrosCategorias = makeStore({ busqueda: '' });
export const filtrosProveedores = makeStore({ busqueda: '' });
export const filtrosEmpleados = makeStore({ busqueda: '', estado: 'todos' });
export const filtrosVentas    = makeStore({ busqueda: '', metodo_pago: '' });
export const filtrosCompras   = makeStore({ busqueda: '' });
