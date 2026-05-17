<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import { confirmStore } from '$lib/stores/confirm';
  import Icon from './Icon.svelte';
  import { IC } from '$lib/icons';

  export let rows:      any[]   = [];
  export let emptyMsg:  string  = 'Sin registros';
  export let colspan:   number  = 1;
  export let canWrite:  boolean = false;
  export let canDelete: boolean = false;
  export let confirmMsg: string = '¿Estás seguro de que deseas eliminar este elemento?';

  const dispatch = createEventDispatcher<{ edit: any; delete: number }>();

  async function handleDelete(id: number) {
    if (await confirmStore.ask(confirmMsg)) dispatch('delete', id);
  }
</script>

<div class="qz-table-wrap">
  <table class="qz-table">
    <thead>
      <tr>
        <slot name="headers" />
        {#if canWrite || canDelete}<th>Acciones</th>{/if}
      </tr>
    </thead>
    <tbody>
      {#if rows.length === 0}
        <tr class="empty-row">
          <td colspan={colspan + (canWrite || canDelete ? 1 : 0)}>{emptyMsg}</td>
        </tr>
      {:else}
        {#each rows as row}
          <tr>
            <slot name="row" {row} />
            {#if canWrite || canDelete}
              <td>
                <div class="row-actions">
                  {#if canWrite}
                    <button class="btn btn-sm btn-blue" on:click={() => dispatch('edit', row)}>
                      <Icon path={IC.edit} size={11} /> Editar
                    </button>
                  {/if}
                  {#if canDelete}
                    <button class="btn btn-sm btn-danger" on:click={() => handleDelete(row.id)}>
                      <Icon path={IC.trash} size={11} /> Eliminar
                    </button>
                  {/if}
                </div>
              </td>
            {/if}
          </tr>
        {/each}
      {/if}
    </tbody>
  </table>
</div>
