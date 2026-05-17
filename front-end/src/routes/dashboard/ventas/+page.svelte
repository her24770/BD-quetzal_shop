<script lang="ts">
  import { onMount } from 'svelte';
  import Icon from '$lib/components/Icon.svelte';
  import DataTable from '$lib/components/DataTable.svelte';
  import FilterBar from '$lib/components/FilterBar.svelte';
  import { IC } from '$lib/icons';
  import { auth } from '$lib/stores/auth';
  import { exportCsv } from '$lib/csv';
  import { filtrosVentas } from '$lib/stores/filtros';
  import { requirePermiso } from '$lib/guards';
  import { formatCurrency, formatFecha } from '$lib/utils';
  import { type Venta, ventasApi } from '$lib/api/ventas';
  import { toast } from '$lib/stores/toast';

  let ventas: Venta[] = [];
  let loading  = true;

  $: token = $auth.token ?? '';

  $: metodosPago = [...new Set(ventas.map(v => v.metodo_pago))];

  $: ventasFiltradas = ventas.filter(v => {
    const q = $filtrosVentas.busqueda.toLowerCase();
    const matchBusqueda = !q || v.cliente.toLowerCase().includes(q) || v.empleado.toLowerCase().includes(q);
    const matchMetodo   = !$filtrosVentas.metodo_pago || v.metodo_pago === $filtrosVentas.metodo_pago;
    return matchBusqueda && matchMetodo;
  });
  $: hayFiltros = $filtrosVentas.busqueda !== '' || $filtrosVentas.metodo_pago !== '';

  onMount(async () => {
    if (!requirePermiso('ventas')) return;
    try {
      ventas = await ventasApi.getAll(token);
    } catch (e: any) {
      toast.push(e.message, 'error');
    } finally {
      loading = false;
    }
  });

  function exportarCSV() {
    exportCsv('ventas.csv',
      ['ID', 'Fecha', 'Cliente', 'NIT', 'Empleado', 'Metodo Pago', 'Descuento', 'Total'],
      ventasFiltradas.map(v => [v.id, v.fecha, v.cliente, v.nit, v.empleado, v.metodo_pago, v.descuento, v.total])
    );
  }
</script>

<svelte:head><title>Ventas — QuetzalShop</title></svelte:head>

<div class="section-header">
  <h2 class="page-title">Ventas</h2>
  <button class="btn btn-sm btn-ghost" on:click={exportarCSV} disabled={ventasFiltradas.length === 0}>
    <Icon path={IC.down} size={13} /> Exportar CSV
  </button>
</div>

<FilterBar
  value={$filtrosVentas.busqueda}
  placeholder="Buscar por cliente o empleado…"
  total={ventas.length}
  filtered={ventasFiltradas.length}
  hasActive={hayFiltros}
  on:search={e => filtrosVentas.set({ busqueda: e.detail })}
  on:clear={() => filtrosVentas.reset()}
>
  <select class="qz-input filtro-select" value={$filtrosVentas.metodo_pago}
    on:change={e => filtrosVentas.set({ metodo_pago: e.currentTarget.value })}>
    <option value="">Todos los métodos</option>
    {#each metodosPago as m}
      <option value={m}>{m}</option>
    {/each}
  </select>
</FilterBar>

{#if loading}
  <div class="loading-msg">Cargando ventas…</div>
{:else}
  <DataTable
    rows={ventasFiltradas}
    canWrite={false}
    canDelete={false}
    colspan={8}
    emptyMsg={hayFiltros ? 'Sin coincidencias' : 'Sin ventas registradas'}
  >
    <svelte:fragment slot="headers">
      <th>#</th><th>Fecha</th><th>Cliente</th><th>NIT</th><th>Empleado</th><th>Método pago</th><th>Descuento</th><th>Total</th>
    </svelte:fragment>
    <svelte:fragment slot="row" let:row>
      <td><span class="cell-id">#{row.id}</span></td>
      <td>{formatFecha(row.fecha)}</td>
      <td><span class="cell-main">{row.cliente}</span></td>
      <td><span class="cell-mono">{row.nit}</span></td>
      <td><span class="cell-sub">{row.empleado}</span></td>
      <td>{row.metodo_pago}</td>
      <td>{row.descuento > 0 ? formatCurrency(row.descuento) : '—'}</td>
      <td><span class="cell-total">{formatCurrency(row.total)}</span></td>
    </svelte:fragment>
  </DataTable>
{/if}
