<script lang="ts">
  import { confirmStore } from '$lib/stores/confirm';
  import Icon from './Icon.svelte';
  import { IC } from '$lib/icons';
</script>

{#if $confirmStore.open}
  <!-- svelte-ignore a11y-click-events-have-key-events a11y-no-static-element-interactions -->
  <div class="confirm-backdrop" on:click={() => confirmStore.answer(false)}>
    <div class="confirm-dialog" on:click|stopPropagation>
      <div class="confirm-icon">
        <Icon path={IC.trash} size={22} />
      </div>
      <p class="confirm-msg">{$confirmStore.message}</p>
      <div class="confirm-actions">
        <button class="btn btn-md btn-ghost" on:click={() => confirmStore.answer(false)}>
          Cancelar
        </button>
        <button class="btn btn-md btn-danger" on:click={() => confirmStore.answer(true)}>
          Eliminar
        </button>
      </div>
    </div>
  </div>
{/if}

<style>
  .confirm-backdrop {
    position: fixed;
    inset: 0;
    background: rgba(0, 0, 0, 0.45);
    z-index: 999;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .confirm-dialog {
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 12px;
    padding: 28px 24px;
    width: 340px;
    max-width: calc(100vw - 32px);
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 16px;
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.15);
  }

  .confirm-icon {
    width: 52px;
    height: 52px;
    border-radius: 50%;
    background: #FEE2E2;
    display: flex;
    align-items: center;
    justify-content: center;
    color: #DC2626;
  }

  .confirm-msg {
    font-size: 14px;
    color: var(--txt);
    text-align: center;
    margin: 0;
    line-height: 1.5;
  }

  .confirm-actions {
    display: flex;
    gap: 10px;
  }
</style>
