import { get } from 'svelte/store';
import { goto } from '$app/navigation';
import { permisos } from './stores/permisos';

type Op = 'SELECT' | 'INSERT' | 'UPDATE' | 'DELETE';

// Redirige al dashboard si el usuario no tiene el permiso indicado sobre la tabla.
// Si el store aún no tiene datos (sesión recién restaurada), deja pasar.
export function requirePermiso(tabla: string, op: Op = 'SELECT'): boolean {
  const map = get(permisos);
  if (Object.keys(map).length === 0) return true;
  if (!(map[tabla]?.includes(op) ?? false)) {
    goto('/dashboard');
    return false;
  }
  return true;
}

// Igual que requirePermiso pero acepta múltiples pares [tabla, op] en OR.
// Útil para páginas como Transacciones o Historial que combinan permisos de varias tablas.
export function requirePermisoAny(checks: Array<[string, Op]>): boolean {
  const map = get(permisos);
  if (Object.keys(map).length === 0) return true;
  if (!checks.some(([tabla, op]) => map[tabla]?.includes(op) ?? false)) {
    goto('/dashboard');
    return false;
  }
  return true;
}
