import { writable } from 'svelte/store';

function makeStore<T extends object>(initial: T) {
  const { subscribe, set, update } = writable<T>({ ...initial });
  return {
    subscribe,
    set: (v: Partial<T>) => update((s: T) => ({ ...s, ...v })),
    reset: () => set({ ...initial }),
  };
}

// Productos
export const filtrosProducto = (() => {
  type S = { busqueda: string; categoria_id: string; stock_status: 'todos' | 'ok' | 'bajo' | 'agotado' };
  const initial: S = { busqueda: '', categoria_id: '', stock_status: 'todos' };
  const { subscribe, set, update } = writable<S>({ ...initial });
  return {
    subscribe,
    setBusqueda:    (v: string)              => update((s: S) => ({ ...s, busqueda: v })),
    setCategoria:   (id: string)             => update((s: S) => ({ ...s, categoria_id: id })),
    setStockStatus: (v: S['stock_status'])   => update((s: S) => ({ ...s, stock_status: v })),
    reset:          ()                       => set({ ...initial }),
  };
})();

// Clientes
export const filtrosClientes = makeStore({ busqueda: '' });

// Categorías
export const filtrosCategorias = makeStore({ busqueda: '' });

// Proveedores
export const filtrosProveedores = makeStore({ busqueda: '' });

// Empleados
export const filtrosEmpleados = makeStore({ busqueda: '', estado: 'todos' });

// Ventas
export const filtrosVentas = makeStore({ busqueda: '', metodo_pago: '' });

// Compras
export const filtrosCompras = makeStore({ busqueda: '' });
