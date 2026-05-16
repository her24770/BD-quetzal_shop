<script lang="ts">
  import { onMount } from 'svelte';
  import Icon from '$lib/components/Icon.svelte';
  import { IC } from '$lib/icons';
  import { auth } from '$lib/stores/auth';
  import { apiFetch } from '$lib/api';
  import { requirePermiso } from '$lib/guards';
  import { exportCsv } from '$lib/csv';
  import { filtrosVentas } from '$lib/stores/filtros';

  interface Venta {
    id: number; fecha: string; total: number; descuento: number;
    cliente: string; nit: string; empleado: string; metodo_pago: string;
  }

  let ventas: Venta[] = [];
  let loading = true;
  let errorMsg = '';

  $: token = $auth.token ?? '';

  const fmt = (n: number) => 'Q ' + n.toLocaleString('es-GT', { minimumFractionDigits: 2 });
  function formatFecha(f: string) {
    return new Date(f).toLocaleDateString('es-GT', { year: 'numeric', month: 'short', day: 'numeric' });
  }

  onMount(async () => {
    if (!requirePermiso('ventas')) return;
    const r = await apiFetch('/ventas', token);
    if (r.ok) ventas = await r.json();
    else errorMsg = 'Error al cargar ventas';
    loading = false;
  });

  $: metodosPago = [...new Set(ventas.map(v => v.metodo_pago))];

  $: ventasFiltradas = ventas.filter(v => {
    const q = $filtrosVentas.busqueda.toLowerCase();
    const matchBusqueda = !q || v.cliente.toLowerCase().includes(q) || v.empleado.toLowerCase().includes(q);
    const matchMetodo   = !$filtrosVentas.metodo_pago || v.metodo_pago === $filtrosVentas.metodo_pago;
    return matchBusqueda && matchMetodo;
  });
  $: hayFiltros = $filtrosVentas.busqueda !== '' || $filtrosVentas.metodo_pago !== '';

  function onBusqueda(e: Event) { filtrosVentas.set({ busqueda: (e.target as HTMLInputElement).value }); }
  function onMetodo(e: Event)   { filtrosVentas.set({ metodo_pago: (e.target as HTMLSelectElement).value }); }

  function exportarCSV() {
    exportCsv('ventas.csv',
      ['ID', 'Fecha', 'Cliente', 'NIT', 'Empleado', 'Metodo Pago', 'Descuento', 'Total'],
      ventas.map(v => [v.id, v.fecha, v.cliente, v.nit, v.empleado, v.metodo_pago, v.descuento, v.total])
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

<div class="filtros-bar">
  <input class="qz-input filtro-busqueda" placeholder="Buscar por cliente o empleado…"
    value={$filtrosVentas.busqueda} on:input={onBusqueda} />
  <select class="qz-input filtro-select" value={$filtrosVentas.metodo_pago} on:change={onMetodo}>
    <option value="">Todos los métodos</option>
    {#each metodosPago as m}
      <option value={m}>{m}</option>
    {/each}
  </select>
  {#if hayFiltros}
    <button class="btn btn-sm btn-ghost" on:click={() => filtrosVentas.reset()}>Limpiar</button>
  {/if}
  <span class="filtro-count">{ventasFiltradas.length} de {ventas.length}</span>
</div>

{#if errorMsg}
  <div class="page-error">{errorMsg}</div>
{/if}

{#if loading}
  <div class="loading-msg">Cargando ventas…</div>
{:else}
  <div class="qz-table-wrap">
    <table class="qz-table">
      <thead>
        <tr>
          <th>#</th>
          <th>Fecha</th>
          <th>Cliente</th>
          <th>NIT</th>
          <th>Empleado</th>
          <th>Método pago</th>
          <th>Descuento</th>
          <th>Total</th>
        </tr>
      </thead>
      <tbody>
        {#if ventasFiltradas.length === 0}
          <tr class="empty-row"><td colspan="8">{hayFiltros ? 'Sin coincidencias' : 'Sin ventas registradas'}</td></tr>
        {:else}
          {#each ventasFiltradas as v}
            <tr>
              <td><span class="cell-id">#{v.id}</span></td>
              <td>{formatFecha(v.fecha)}</td>
              <td><span class="cell-main">{v.cliente}</span></td>
              <td><span class="cell-mono">{v.nit}</span></td>
              <td><span class="cell-sub">{v.empleado}</span></td>
              <td>{v.metodo_pago}</td>
              <td>{v.descuento > 0 ? fmt(v.descuento) : '—'}</td>
              <td><span class="cell-total">{fmt(v.total)}</span></td>
            </tr>
          {/each}
        {/if}
      </tbody>
    </table>
  </div>
{/if}
