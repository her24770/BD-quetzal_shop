export function escapeCsvValue(v: string | number | null | undefined): string {
  const s = String(v ?? '');
  return /[,"\n\r]/.test(s) ? `"${s.replace(/"/g, '""')}"` : s;
}

export function buildCsvContent(headers: string[], rows: (string | number | null | undefined)[][]): string {
  return [headers, ...rows].map(r => r.map(escapeCsvValue).join(',')).join('\n');
}

export function exportCsv(filename: string, headers: string[], rows: (string | number | null | undefined)[][]) {
  const blob = new Blob(['﻿' + buildCsvContent(headers, rows)], { type: 'text/csv;charset=utf-8;' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = filename;
  a.click();
  URL.revokeObjectURL(url);
}
