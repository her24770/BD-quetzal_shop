<script lang="ts">
  import { createEventDispatcher } from 'svelte';

  export let value    = '';
  export let placeholder = 'Buscar…';
  export let total    = 0;
  export let filtered = 0;
  export let hasActive = false;

  const dispatch = createEventDispatcher<{ search: string; clear: void }>();
</script>

<div class="filtros-bar">
  <input
    class="qz-input filtro-busqueda"
    {placeholder}
    {value}
    on:input={e => dispatch('search', e.currentTarget.value)}
  />

  <!-- Filtros extra opcionales (selects, toggles, etc.) -->
  <slot />

  {#if hasActive}
    <button class="btn btn-sm btn-ghost" on:click={() => dispatch('clear')}>Limpiar</button>
  {/if}

  <span class="filtro-count">{filtered} de {total}</span>
</div>
