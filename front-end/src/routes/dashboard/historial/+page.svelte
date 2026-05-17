<script lang="ts">
  import { onMount } from 'svelte';
  import Icon from '$lib/components/Icon.svelte';
  import DataTable from '$lib/components/DataTable.svelte';
  import FilterBar from '$lib/components/FilterBar.svelte';
  import { IC } from '$lib/icons';
  import { auth } from '$lib/stores/auth';
  import { exportCsv } from '$lib/csv';
  import { filtrosVentas, filtrosCompras } from '$lib/stores/filtros';
  import { permisos } from '$lib/stores/permisos';
  import { formatCurrency, formatFecha } from '$lib/utils';
  import { type Venta, ventasApi } from '$lib/api/ventas';
  import { type Compra, comprasApi } from '$lib/api/compras';

  let ventas:  Venta[]  = [];
  let compras: Compra[] = [];
  let loading = true;

  $: token      = $auth.token ?? '';
  $: canVentas  = ($permisos['ventas']  ?? []).includes('SELECT');
  $: canCompras = ($permisos['compras'] ?? []).includes('SELECT');

  let activeTab: 'ventas' | 'compras' = 'ventas';
  $: if (!canVentas && canCompras) activeTab = 'compras';

  $: ventasFiltradas = ventas.filter(v => {
    const q = $filtrosVentas.busqueda.toLowerCase();
    const matchBusqueda = !q || v.cliente.toLowerCase().includes(q) || v.empleado.toLowerCase().includes(q);
    const matchMetodo   = !$filtrosVentas.metodo_pago || v.metodo_pago === $filtrosVentas.metodo_pago;
    return matchBusqueda && matchMetodo;
  });
  $: hayFiltrosVentas = $filtrosVentas.busqueda !== '' || $filtrosVentas.metodo_pago !== '';

  $: comprasFiltradas = compras.filter(c => {
    const q = $filtrosCompras.busqueda.toLowerCase();
    return !q || c.numero_factura.toLowerCase().includes(q) || c.empleado.toLowerCase().includes(q);
  });
  $: hayFiltrosCompras = $filtrosCompras.busqueda !== '';

  $: metodosPago = [...new Set(ventas.map(v => v.metodo_pago))];

  onMount(async () => {
    try {
      const calls: Promise<void>[] = [];
      if (canVentas)  calls.push(ventasApi.getAll(token).then(d => { ventas  = d; }));
      if (canCompras) calls.push(comprasApi.getAll(token).then(d => { compras = d; }));
      await Promise.all(calls);
    } finally {
      loading = false;
    }
  });

  function exportVentas() {
    exportCsv('historial-ventas.csv',
      ['ID', 'Fecha', 'Cliente', 'NIT', 'Empleado', 'Metodo Pago', 'Descuento', 'Total'],
      ventasFiltradas.map(v => [v.id, v.fecha, v.cliente, v.nit, v.empleado, v.metodo_pago, v.descuento, v.total])
    );
  }

  function exportCompras() {
    exportCsv('historial-compras.csv',
      ['ID', 'Fecha', 'No. Factura', 'Empleado', 'Total'],
      comprasFiltradas.map(c => [c.id, c.fecha, c.numero_factura, c.empleado, c.total])
    );
  }
</script>

<svelte:head><title>Historial — QuetzalShop</title></svelte:head>

<div class="page-header">
  <h2 class="page-title">Historial</h2>
  {#if canVentas && canCompras}
    <div class="tab-toggle">
      <button class="tab-btn" class:active={activeTab === 'ventas'}  on:click={() => activeTab = 'ventas'}>
        <Icon path={IC.cart} size={13} /> Ventas
      </button>
      <button class="tab-btn" class:active={activeTab === 'compras'} on:click={() => activeTab = 'compras'}>
        <Icon path={IC.pkg}  size={13} /> Compras
      </button>
    </div>
  {:else}
    <span class="tab-label">{canVentas ? 'Ventas' : 'Compras'}</span>
  {/if}
</div>

{#if loading}
  <div class="loading-msg">Cargando historial…</div>
{:else}

{#if activeTab === 'ventas' && canVentas}
  <FilterBar
    value={$filtrosVentas.busqueda}
    placeholder="Buscar por cliente o empleado…"
    total={ventas.length}
    filtered={ventasFiltradas.length}
    hasActive={hayFiltrosVentas}
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
    <button class="btn btn-sm btn-ghost" on:click={exportVentas} disabled={ventasFiltradas.length === 0}>
      <Icon path={IC.down} size={13} /> Exportar CSV
    </button>
  </FilterBar>

  <DataTable
    rows={ventasFiltradas}
    canWrite={false}
    canDelete={false}
    colspan={8}
    emptyMsg={hayFiltrosVentas ? 'Sin coincidencias' : 'Sin ventas registradas'}
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

{:else if activeTab === 'compras' && canCompras}
  <FilterBar
    value={$filtrosCompras.busqueda}
    placeholder="Buscar por factura o empleado…"
    total={compras.length}
    filtered={comprasFiltradas.length}
    hasActive={hayFiltrosCompras}
    on:search={e => filtrosCompras.set({ busqueda: e.detail })}
    on:clear={() => filtrosCompras.reset()}
  >
    <button class="btn btn-sm btn-ghost" on:click={exportCompras} disabled={comprasFiltradas.length === 0}>
      <Icon path={IC.down} size={13} /> Exportar CSV
    </button>
  </FilterBar>

  <DataTable
    rows={comprasFiltradas}
    canWrite={false}
    canDelete={false}
    colspan={5}
    emptyMsg={hayFiltrosCompras ? 'Sin coincidencias' : 'Sin compras registradas'}
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

{/if}
