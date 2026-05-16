<script lang="ts">
  import { onMount } from 'svelte';
  import Icon from '$lib/components/Icon.svelte';
  import { IC } from '$lib/icons';
  import { auth } from '$lib/stores/auth';
  import { apiFetch } from '$lib/api';
  import { requirePermiso } from '$lib/guards';
  import { exportCsv } from '$lib/csv';
  import { filtrosCompras } from '$lib/stores/filtros';

  interface Compra {
    id: number; fecha: string; total: number; numero_factura: string; empleado: string;
  }

  let compras: Compra[] = [];
  let loading = true;
  let errorMsg = '';

  $: token = $auth.token ?? '';

  const fmt = (n: number) => 'Q ' + n.toLocaleString('es-GT', { minimumFractionDigits: 2 });
  function formatFecha(f: string) {
    return new Date(f).toLocaleDateString('es-GT', { year: 'numeric', month: 'short', day: 'numeric' });
  }

  onMount(async () => {
    if (!requirePermiso('compras')) return;
    const r = await apiFetch('/compras', token);
    if (r.ok) compras = await r.json();
    else errorMsg = 'Error al cargar compras';
    loading = false;
  });

  $: comprasFiltradas = compras.filter(c => {
    const q = $filtrosCompras.busqueda.toLowerCase();
    return !q || c.numero_factura.toLowerCase().includes(q) || c.empleado.toLowerCase().includes(q);
  });
  $: hayFiltros = $filtrosCompras.busqueda !== '';

  function onBusqueda(e: Event) { filtrosCompras.set({ busqueda: (e.target as HTMLInputElement).value }); }

  function exportarCSV() {
    exportCsv('compras.csv',
      ['ID', 'Fecha', 'No. Factura', 'Empleado', 'Total'],
      comprasFiltradas.map(c => [c.id, c.fecha, c.numero_factura, c.empleado, c.total])
    );
  }
</script>

<svelte:head><title>Compras — QuetzalShop</title></svelte:head>

<div class="section-header">
  <h2 class="page-title">Compras</h2>
  <button class="btn btn-sm btn-ghost" on:click={exportarCSV} disabled={comprasFiltradas.length === 0}>
    <Icon path={IC.down} size={13} /> Exportar CSV
  </button>
</div>

<div class="filtros-bar">
  <input class="qz-input filtro-busqueda" placeholder="Buscar por factura o empleado…"
    value={$filtrosCompras.busqueda} on:input={onBusqueda} />
  {#if hayFiltros}
    <button class="btn btn-sm btn-ghost" on:click={() => filtrosCompras.reset()}>Limpiar</button>
  {/if}
  <span class="filtro-count">{comprasFiltradas.length} de {compras.length}</span>
</div>

{#if errorMsg}
  <div class="page-error">{errorMsg}</div>
{/if}

{#if loading}
  <div class="loading-msg">Cargando compras…</div>
{:else}
  <div class="qz-table-wrap">
    <table class="qz-table">
      <thead>
        <tr>
          <th>#</th>
          <th>Fecha</th>
          <th>No. Factura</th>
          <th>Empleado</th>
          <th>Total</th>
        </tr>
      </thead>
      <tbody>
        {#if comprasFiltradas.length === 0}
          <tr class="empty-row"><td colspan="5">{hayFiltros ? 'Sin coincidencias' : 'Sin compras registradas'}</td></tr>
        {:else}
          {#each comprasFiltradas as c}
            <tr>
              <td><span class="cell-id">#{c.id}</span></td>
              <td>{formatFecha(c.fecha)}</td>
              <td><span class="cell-mono">{c.numero_factura}</span></td>
              <td><span class="cell-sub">{c.empleado}</span></td>
              <td><span class="cell-total">{fmt(c.total)}</span></td>
            </tr>
          {/each}
        {/if}
      </tbody>
    </table>
  </div>
{/if}
