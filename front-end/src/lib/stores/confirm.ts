import { writable } from 'svelte/store';

interface ConfirmState {
  open: boolean;
  message: string;
  resolve: ((v: boolean) => void) | null;
}

function createConfirmStore() {
  const { subscribe, set, update } = writable<ConfirmState>({ open: false, message: '', resolve: null });

  function ask(message: string): Promise<boolean> {
    return new Promise(resolve => {
      set({ open: true, message, resolve });
    });
  }

  function answer(value: boolean) {
    update(s => {
      s.resolve?.(value);
      return { open: false, message: '', resolve: null };
    });
  }

  return { subscribe, ask, answer };
}

export const confirmStore = createConfirmStore();
