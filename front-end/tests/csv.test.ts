// Prueba basica de escape de valores CSV
import { describe, it, expect } from 'vitest';
import { escapeCsvValue } from '../src/lib/csv';

describe('escapeCsvValue', () => {
  it('no modifica valores simples', () => {
    expect(escapeCsvValue('Producto')).toBe('Producto');
    expect(escapeCsvValue(123)).toBe('123');
  });
});
