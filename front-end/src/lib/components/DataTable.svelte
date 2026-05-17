<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import Icon from './Icon.svelte';
  import { IC } from '$lib/icons';

  // rows: array de datos a mostrar
  export let rows:      any[]  = [];
  export let emptyMsg:  string = 'Sin registros';
  // colspan de la fila vacía — debe coincidir con el número total de columnas
  export let colspan:   number = 1;
  // permisos de escritura
  export let canWrite:  boolean = false;
  export let canDelete: boolean = false;

  const dispatch = createEventDispatcher<{ edit: any; delete: number }>();
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
                    <button class="btn btn-sm btn-danger" on:click={() => dispatch('delete', row.id)}>
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
