<script lang="ts">
  import { onMount } from 'svelte';
  import Icon from '$lib/components/Icon.svelte';
  import { IC } from '$lib/icons';
  import { auth } from '$lib/stores/auth';
  import { apiFetch } from '$lib/api';
  import { permisos } from '$lib/stores/permisos';
  import { exportCsv } from '$lib/csv';

  interface VentaResumen  { id: number; fecha: string; total: number; descuento: number; cliente: string; nit: string; empleado: string; metodo_pago: string; }
  interface CompraResumen { id: number; fecha: string; total: number; numero_factura: string; empleado: string; }

  let ventas:  VentaResumen[]  = [];
  let compras: CompraResumen[] = [];
  let loading = true;

  $: token      = $auth.token ?? '';
  $: canVentas  = ($permisos['ventas']  ?? []).includes('SELECT');
  $: canCompras = ($permisos['compras'] ?? []).includes('SELECT');

  let activeTab: 'ventas' | 'compras' = 'ventas';
  $: if (!canVentas && canCompras) activeTab = 'compras';

  let busquedaVentas  = '';
  let busquedaCompras = '';

  $: ventasFiltradas = ventas.filter(v => {
    const q = busquedaVentas.toLowerCase();
    return !q || v.cliente.toLowerCase().includes(q) || v.empleado.toLowerCase().includes(q);
  });

  $: comprasFiltradas = compras.filter(c => {
    const q = busquedaCompras.toLowerCase();
    return !q || c.numero_factura.toLowerCase().includes(q) || c.empleado.toLowerCase().includes(q);
  });

  const fmt  = (n: number) => 'Q ' + Number(n).toLocaleString('es-GT', { minimumFractionDigits: 2 });
  const fmtF = (f: string) => new Date(f).toLocaleDateString('es-GT', { year: 'numeric', month: 'short', day: 'numeric' });

  onMount(async () => {
    const calls: Promise<any>[] = [];
    if (canVentas)  calls.push(apiFetch('/ventas',  token).then(r => r.ok && r.json().then((d: VentaResumen[]) => ventas = d)));
    if (canCompras) calls.push(apiFetch('/compras', token).then(r => r.ok && r.json().then((d: CompraResumen[]) => compras = d)));
    await Promise.all(calls);
    loading = false;
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
  <div class="filtros-bar">
    <input class="qz-input filtro-busqueda" placeholder="Buscar por cliente o empleado…"
      bind:value={busquedaVentas} />
    <button class="btn btn-sm btn-ghost" on:click={exportVentas} disabled={ventasFiltradas.length === 0}>
      <Icon path={IC.down} size={13} /> Exportar CSV
    </button>
    <span class="filtro-count">{ventasFiltradas.length} de {ventas.length}</span>
  </div>

  <div class="qz-table-wrap">
    <table class="qz-table">
      <thead>
        <tr>
          <th>#</th><th>Fecha</th><th>Cliente</th><th>NIT</th><th>Empleado</th><th>Método pago</th><th>Descuento</th><th>Total</th>
        </tr>
      </thead>
      <tbody>
        {#if ventasFiltradas.length === 0}
          <tr class="empty-row"><td colspan="8">{busquedaVentas ? 'Sin coincidencias' : 'Sin ventas registradas'}</td></tr>
        {:else}
          {#each ventasFiltradas as v}
            <tr>
              <td><span class="cell-id">#{v.id}</span></td>
              <td>{fmtF(v.fecha)}</td>
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

{:else if activeTab === 'compras' && canCompras}
  <div class="filtros-bar">
    <input class="qz-input filtro-busqueda" placeholder="Buscar por factura o empleado…"
      bind:value={busquedaCompras} />
    <button class="btn btn-sm btn-ghost" on:click={exportCompras} disabled={comprasFiltradas.length === 0}>
      <Icon path={IC.down} size={13} /> Exportar CSV
    </button>
    <span class="filtro-count">{comprasFiltradas.length} de {compras.length}</span>
  </div>

  <div class="qz-table-wrap">
    <table class="qz-table">
      <thead>
        <tr>
          <th>#</th><th>Fecha</th><th>No. Factura</th><th>Empleado</th><th>Total</th>
        </tr>
      </thead>
      <tbody>
        {#if comprasFiltradas.length === 0}
          <tr class="empty-row"><td colspan="5">{busquedaCompras ? 'Sin coincidencias' : 'Sin compras registradas'}</td></tr>
        {:else}
          {#each comprasFiltradas as c}
            <tr>
              <td><span class="cell-id">#{c.id}</span></td>
              <td>{fmtF(c.fecha)}</td>
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

{/if}

