<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import Icon from '$lib/components/Icon.svelte';
  import { IC } from '$lib/icons';

  export let open = false;
  export let title = '';

  const dispatch = createEventDispatcher();

  function close() { dispatch('close'); }

  function onBackdrop(e: MouseEvent) {
    if (e.target === e.currentTarget) close();
  }

  function onKey(e: KeyboardEvent) {
    if (e.key === 'Escape') close();
  }
</script>

<svelte:window on:keydown={onKey} />

{#if open}
  <!-- svelte-ignore a11y-click-events-have-key-events a11y-no-static-element-interactions -->
  <div class="backdrop" on:click={onBackdrop}>
    <div class="box" role="dialog" aria-modal="true" aria-label={title}>
      <div class="header">
        <h3 class="title">{title}</h3>
        <button class="close-btn" on:click={close} aria-label="Cerrar">
          <Icon path={IC.x} size={16} />
        </button>
      </div>
      <div class="body">
        <slot />
      </div>
    </div>
  </div>
{/if}

<style>
  .backdrop {
    position: fixed;
    inset: 0;
    background: rgba(0, 0, 0, 0.5);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 200;
    padding: 16px;
  }
  .box {
    background: var(--surface, #fff);
    border-radius: 12px;
    width: 100%;
    max-width: 560px;
    max-height: 90vh;
    overflow-y: auto;
    box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
    border: 1px solid var(--border, #E5E7EB);
  }
  .header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 20px 24px 0;
  }
  .title {
    font-size: 16px;
    font-weight: 600;
    color: var(--txt, #111827);
    margin: 0;
  }
  .close-btn {
    background: none;
    border: none;
    cursor: pointer;
    color: var(--txt-3, #6B7280);
    padding: 4px;
    border-radius: 6px;
    display: flex;
    align-items: center;
  }
  .close-btn:hover { color: var(--txt, #111827); background: var(--surface-alt, #F3F4F6); }
  .body {
    padding: 16px 24px 24px;
  }
</style>
