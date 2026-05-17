import { writable } from 'svelte/store';

export interface User {
  user_id:        number;
  email:          string;
  rol_id:         number;
  rol_nombre:     string;
  empleado_id:    number | null;
  nombre_empleado: string | null;
}

interface AuthState {
  token: string | null;
  user:  User   | null;
}

// Lee el estado guardado en localStorage al iniciar
function createAuthStore() {
  const stored = typeof localStorage !== 'undefined'
    ? localStorage.getItem('auth')
    : null;

  const initial: AuthState = stored
    ? JSON.parse(stored)
    : { token: null, user: null };

  const { subscribe, set } = writable<AuthState>(initial);

  return {
    subscribe,

    // Guarda el token y los datos del usuario tras un login exitoso
    login(token: string, user: User) {
      const state = { token, user };
      localStorage.setItem('auth', JSON.stringify(state));
      set(state);
    },

    // Limpia el estado al hacer logout
    logout() {
      localStorage.removeItem('auth');
      set({ token: null, user: null });
    }
  };
}

export const auth = createAuthStore();
