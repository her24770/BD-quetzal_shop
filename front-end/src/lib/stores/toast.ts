import { writable } from 'svelte/store';

interface ToastItem {
  id: number;
  msg: string;
  type: 'success' | 'error';
}

let _seq = 0;

function createToastStore() {
  const { subscribe, update } = writable<ToastItem[]>([]);

  function push(msg: string, type: 'success' | 'error' = 'success', duration = 4000) {
    const id = ++_seq;
    update(ts => [...ts, { id, msg, type }]);
    setTimeout(() => remove(id), duration);
  }

  function remove(id: number) {
    update(ts => ts.filter(t => t.id !== id));
  }

  return { subscribe, push, remove };
}

export const toast = createToastStore();
