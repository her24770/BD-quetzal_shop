// Pruebas de las funciones utilitarias puras: formato de moneda, fechas y estado de stock
import { describe, it, expect } from 'vitest';
import { formatCurrency, formatFecha, stockStatus } from '../src/lib/utils';

// Verifica que los numeros se muestren siempre con prefijo Q y dos decimales
describe('formatCurrency', () => {
  it('formatea cero correctamente', () => {
    expect(formatCurrency(0)).toBe('Q 0.00');
  });

  it('formatea numeros con decimales', () => {
    expect(formatCurrency(1500.5)).toBe('Q 1,500.50');
  });

  it('formatea numeros enteros con dos decimales', () => {
    expect(formatCurrency(250)).toBe('Q 250.00');
  });
});

// Verifica que el nivel de stock se clasifique correctamente segun el minimo
describe('stockStatus', () => {
  it('retorna agotado cuando stock es 0', () => {
    expect(stockStatus(0, 5)).toBe('agotado');
  });

  it('retorna bajo cuando stock es menor al minimo', () => {
    expect(stockStatus(3, 5)).toBe('bajo');
  });

  it('retorna bajo cuando stock es igual al minimo', () => {
    expect(stockStatus(5, 5)).toBe('bajo');
  });

  it('retorna ok cuando stock supera el minimo', () => {
    expect(stockStatus(10, 5)).toBe('ok');
  });

  it('retorna ok cuando stock minimo es 0 y hay existencias', () => {
    expect(stockStatus(1, 0)).toBe('ok');
  });
});

// Verifica que las fechas ISO se conviertan a formato legible en espanol
describe('formatFecha', () => {
  it('formatea una fecha ISO en formato legible', () => {
    const resultado = formatFecha('2026-01-15T00:00:00');
    expect(resultado).toContain('2026');
    expect(resultado).toContain('15');
  });
});
