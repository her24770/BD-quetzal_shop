<script lang="ts">
  import { goto } from '$app/navigation';
  import { auth } from '$lib/stores/auth';
  import Icon from '$lib/components/Icon.svelte';
  import { IC } from '$lib/icons';
</script>

<div class="forbidden">
  <div class="forbidden__card">
    <div class="forbidden__icon">
      <Icon path={IC.lock} size={40} strokeWidth={1.5} />
    </div>
    <h1 class="forbidden__title">Acceso denegado</h1>
    <p class="forbidden__desc">
      Tu rol <strong>{$auth.user?.rol_nombre ?? ''}</strong> no tiene permiso para acceder a esta sección.
    </p>
    <button class="forbidden__btn" on:click={() => goto('/dashboard')}>
      Volver al dashboard
    </button>
  </div>
</div>

<style>
  .forbidden {
    display: flex;
    align-items: center;
    justify-content: center;
    min-height: 60vh;
  }

  .forbidden__card {
    text-align: center;
    padding: 48px 40px;
    background: var(--surface, #fff);
    border-radius: 16px;
    border: 1px solid var(--border, #e5e7eb);
    max-width: 400px;
    width: 100%;
  }

  .forbidden__icon {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 80px;
    height: 80px;
    background: #fef2f2;
    border-radius: 50%;
    color: #ef4444;
    margin-bottom: 20px;
  }

  .forbidden__title {
    font-size: 22px;
    font-weight: 700;
    color: var(--text, #111827);
    margin: 0 0 10px;
  }

  .forbidden__desc {
    font-size: 14px;
    color: var(--text-muted, #6b7280);
    margin: 0 0 28px;
    line-height: 1.6;
  }

  .forbidden__btn {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    padding: 10px 24px;
    background: #4C1D95;
    color: #fff;
    border: none;
    border-radius: 8px;
    font-size: 14px;
    font-weight: 500;
    cursor: pointer;
    transition: background 0.15s;
  }

  .forbidden__btn:hover {
    background: #3b1678;
  }
</style>
