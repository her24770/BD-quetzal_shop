/// <reference types="vitest" />
import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vite';

export default defineConfig({
  plugins: [sveltekit()],
  server: {
    host: '0.0.0.0',
    port: parseInt(process.env.FRONTEND_PORT ?? '3000'),
    strictPort: true
  },
  test: {
    environment: 'node',
    include: ['tests/**/*.test.ts'],
  },
});
