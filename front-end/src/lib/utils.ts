export function formatCurrency(n: number): string {
  return 'Q ' + Number(n).toLocaleString('es-GT', { minimumFractionDigits: 2 });
}

export function formatFecha(f: string): string {
  return new Date(f).toLocaleDateString('es-GT', { year: 'numeric', month: 'short', day: 'numeric' });
}

export function stockStatus(stock: number, stockMinimo: number): 'ok' | 'bajo' | 'agotado' {
  if (stock === 0) return 'agotado';
  if (stock <= stockMinimo) return 'bajo';
  return 'ok';
}
