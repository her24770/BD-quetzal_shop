<script lang="ts">
  import { onMount } from 'svelte';
  import Icon from '$lib/components/Icon.svelte';
  import DataTable from '$lib/components/DataTable.svelte';
  import FilterBar from '$lib/components/FilterBar.svelte';
  import { IC } from '$lib/icons';
  import { auth } from '$lib/stores/auth';
  import { exportCsv } from '$lib/csv';
  import { filtrosCompras } from '$lib/stores/filtros';
  import { requirePermiso } from '$lib/guards';
  import { formatCurrency, formatFecha } from '$lib/utils';
  import { type Compra, comprasApi } from '$lib/api/compras';
  import { toast } from '$lib/stores/toast';

  let compras: Compra[] = [];
  let loading   = true;

  $: token = $auth.token ?? '';

  $: comprasFiltradas = compras.filter(c => {
    const q = $filtrosCompras.busqueda.toLowerCase();
    return !q || c.numero_factura.toLowerCase().includes(q) || c.empleado.toLowerCase().includes(q);
  });
  $: hayFiltros = $filtrosCompras.busqueda !== '';

  onMount(async () => {
    if (!requirePermiso('compras')) return;
    try {
      compras = await comprasApi.getAll(token);
    } catch (e: any) {
      toast.push(e.message, 'error');
    } finally {
      loading = false;
    }
  });

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

<FilterBar
  value={$filtrosCompras.busqueda}
  placeholder="Buscar por factura o empleado…"
  total={compras.length}
  filtered={comprasFiltradas.length}
  hasActive={hayFiltros}
  on:search={e => filtrosCompras.set({ busqueda: e.detail })}
  on:clear={() => filtrosCompras.reset()}
/>

{#if loading}
  <div class="loading-msg">Cargando compras…</div>
{:else}
  <DataTable
    rows={comprasFiltradas}
    canWrite={false}
    canDelete={false}
    colspan={5}
    emptyMsg={hayFiltros ? 'Sin coincidencias' : 'Sin compras registradas'}
  >
    <svelte:fragment slot="headers">
      <th>#</th><th>Fecha</th><th>No. Factura</th><th>Empleado</th><th>Total</th>
    </svelte:fragment>
    <svelte:fragment slot="row" let:row>
      <td><span class="cell-id">#{row.id}</span></td>
      <td>{formatFecha(row.fecha)}</td>
      <td><span class="cell-mono">{row.numero_factura}</span></td>
      <td><span class="cell-sub">{row.empleado}</span></td>
      <td><span class="cell-total">{formatCurrency(row.total)}</span></td>
    </svelte:fragment>
  </DataTable>
{/if}
