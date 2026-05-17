// Resuelve la respuesta como JSON. Si falla extrae el 'detail' y lanza un Error.
// Soporta respuestas vacías (DELETE 204, etc.).
export async function parseJson<T = void>(res: Response): Promise<T> {
  if (!res.ok) {
    const e = await res.json().catch(() => ({}));
    throw new Error((e as any).detail ?? 'Error en la solicitud');
  }
  const text = await res.text();
  return (text ? JSON.parse(text) : undefined) as T;
}
