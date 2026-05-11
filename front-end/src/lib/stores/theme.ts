import { writable } from 'svelte/store';
import { browser } from '$app/environment';

type Theme = 'light' | 'dark';

const initial: Theme = browser
  ? (localStorage.getItem('theme') as Theme) ?? 'light'
  : 'light';

export const theme = writable<Theme>(initial);

theme.subscribe(val => {
  if (!browser) return;
  localStorage.setItem('theme', val);
  document.documentElement.setAttribute('data-theme', val);
});

export function toggleTheme() {
  theme.update(t => (t === 'light' ? 'dark' : 'light'));
}

export function initTheme() {
  if (!browser) return;
  document.documentElement.setAttribute('data-theme', initial);
}
