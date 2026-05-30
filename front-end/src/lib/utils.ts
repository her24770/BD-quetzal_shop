export function formatCurrency(n: number): string {
  return 'Q ' + Number(n).toLocaleString('es-GT', { minimumFractionDigits: 2 });
}

export function formatFecha(f: string): string {
  // Strings de solo fecha (YYYY-MM-DD) se parsean como UTC medianoche en browsers,
  // lo que desplaza el día en zonas negativas. Forzar mediodía local evita el problema.
  // Strings de datetime del backend ya vienen en hora Guatemala (sin Z); parsear como local.
  const iso = f.length === 10 ? f + 'T12:00:00' : f.replace(' ', 'T');
  return new Date(iso).toLocaleDateString('es-GT', {
    year: 'numeric', month: 'short', day: 'numeric',
  });
}

export function stockStatus(stock: number, stockMinimo: number): 'ok' | 'bajo' | 'agotado' {
  if (stock === 0) return 'agotado';
  if (stock <= stockMinimo) return 'bajo';
  return 'ok';
}
