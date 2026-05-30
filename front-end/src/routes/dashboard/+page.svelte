<script lang="ts">
  import { onMount } from 'svelte';
  import StatCard from '$lib/components/StatCard.svelte';
  import { IC } from '$lib/icons';
  import { auth } from '$lib/stores/auth';
  import { permisos } from '$lib/stores/permisos';
  import { formatCurrency, formatFecha } from '$lib/utils';
  import {
    type Stats, type TopProducto, type VentaMetodo, type ProductoBajo, type VentaReciente,
    reportesApi,
  } from '$lib/api/reportes';

  let stats: Stats | null = null;
  let topProductos:         TopProducto[]   = [];
  let ventasPorMetodo:      VentaMetodo[]   = [];
  let productosBajoVendidos: ProductoBajo[] = [];
  let ultimasVentas:        VentaReciente[] = [];
  let loading = true;

  $: token           = $auth.token ?? '';
  $: user            = $auth.user;
  $: canVerVentas    = ($permisos['ventas']    ?? []).includes('SELECT');
  $: canVerProductos = ($permisos['productos'] ?? []).includes('SELECT');
  $: canVerClientes  = ($permisos['clientes']  ?? []).includes('SELECT');
  $: canVerCompras   = ($permisos['compras']   ?? []).includes('SELECT');
  $: canVerEmpleados = ($permisos['empleados'] ?? []).includes('SELECT');

  onMount(async () => {
    const calls: Promise<void>[] = [
      reportesApi.getStats(token).then(d => { stats = d; }),
    ];
    if (canVerProductos) {
      calls.push(
        reportesApi.getTopProductos(token).then(d   => { topProductos          = d; }),
        reportesApi.getBajoVendidos(token).then(d   => { productosBajoVendidos = d; }),
      );
    }
    if (canVerVentas) {
      calls.push(
        reportesApi.getVentasPorMetodo(token).then(d => { ventasPorMetodo = d; }),
        reportesApi.getVentasRecientes(token).then(d => { ultimasVentas   = d; }),
      );
    }
    await Promise.all(calls);
    loading = false;
  });
</script>

<svelte:head><title>QuetzalShop</title></svelte:head>

<div class="page-header">
  <div>
    <h2 class="page-title">Dashboard</h2>
    <p class="page-sub">Bienvenido, {user?.nombre_empleado ?? user?.email}</p>
  </div>
</div>

{#if loading}
  <div class="loading-msg">Cargando datos…</div>
{:else}

<!-- ── Stats cards ── -->
<div class="stats-grid">
  {#if canVerVentas}
    <StatCard
      label="Ventas del día"
      value={stats ? formatCurrency(stats.ventas_hoy.total) : 'Q 0.00'}
      sub="{stats?.ventas_hoy.count ?? 0} transacciones"
      iconPath={IC.cart}
      iconBg="#EDE9FE" iconColor="#7C3AED"
    />
  {/if}
  {#if canVerProductos}
    <StatCard
      label="Stock bajo"
      value={stats?.stock_bajo ?? 0}
      sub="Productos con alerta"
      iconPath={IC.alert}
      iconBg="#FEF3C7" iconColor="#D97706"
    />
  {/if}
  {#if canVerCompras}
    <StatCard
      label="Compras del mes"
      value={stats ? formatCurrency(stats.compras_mes) : 'Q 0.00'}
      sub="Acumulado del mes"
      iconPath={IC.pkg}
      iconBg="#DBEAFE" iconColor="#2563EB"
    />
  {/if}
  {#if canVerEmpleados}
    <StatCard
      label="Empleados activos"
      value={stats?.empleados.activos ?? 0}
      sub="de {stats?.empleados.total ?? 0} registrados"
      iconPath={IC.person}
      iconBg="#D1FAE5" iconColor="#059669"
    />
  {/if}
</div>

<!-- ── Top 5 productos más vendidos ── -->
{#if canVerProductos && topProductos.length > 0}
  <div class="section-block">
    <div class="section-head">
      <h3 class="section-title">Top 5 productos más vendidos</h3>
      <span class="sql-badge">CTE + GROUP BY</span>
    </div>
    <div class="qz-table-wrap">
      <table class="qz-table">
        <thead>
          <tr><th>Producto</th><th>Categoría</th><th>Unidades vendidas</th><th>Total ingresos</th></tr>
        </thead>
        <tbody>
          {#each topProductos as p, i}
            <tr>
              <td>
                <div style="display:flex;align-items:center;gap:8px">
                  <span class="rank">#{i + 1}</span>
                  <span class="cell-main">{p.nombre}</span>
                </div>
              </td>
              <td>{p.categoria}</td>
              <td><span class="cell-num">{p.total_vendido}</span> uds.</td>
              <td><span class="cell-total">{formatCurrency(p.total_ingresos)}</span></td>
            </tr>
          {/each}
        </tbody>
      </table>
    </div>
  </div>
{/if}

<!-- ── Últimas ventas ── -->
{#if canVerVentas && ultimasVentas.length > 0}
  <div class="section-block">
    <div class="section-head">
      <h3 class="section-title">Últimas ventas</h3>
      <span class="sql-badge sql-badge--green">VIEW</span>
    </div>
    <div class="qz-table-wrap">
      <table class="qz-table">
        <thead>
          <tr><th>#</th><th>Fecha</th><th>Cliente</th><th>Empleado</th><th>Método</th><th>Total</th></tr>
        </thead>
        <tbody>
          {#each ultimasVentas as v}
            <tr>
              <td><span class="cell-id">#{v.id}</span></td>
              <td>{formatFecha(v.fecha)}</td>
              <td><span class="cell-main">{v.cliente}</span></td>
              <td><span class="cell-sub">{v.empleado}</span></td>
              <td>{v.metodo_pago}</td>
              <td><span class="cell-total">{formatCurrency(v.total)}</span></td>
            </tr>
          {/each}
        </tbody>
      </table>
    </div>
  </div>
{/if}

<!-- ── Ventas por método de pago ── -->
{#if canVerVentas && ventasPorMetodo.length > 0}
  <div class="section-block">
    <div class="section-head">
      <h3 class="section-title">Ventas por método de pago</h3>
      <span class="sql-badge">GROUP BY + HAVING</span>
    </div>
    <div class="qz-table-wrap">
      <table class="qz-table">
        <thead>
          <tr><th>Método</th><th>Cantidad</th><th>Total</th></tr>
        </thead>
        <tbody>
          {#each ventasPorMetodo as m}
            <tr>
              <td><span class="cell-main">{m.metodo}</span></td>
              <td>{m.cantidad}</td>
              <td><span class="cell-total">{formatCurrency(m.total)}</span></td>
            </tr>
          {/each}
        </tbody>
      </table>
    </div>
  </div>
{/if}

<!-- ── Productos con stock bajo y vendidos ── -->
{#if canVerProductos && productosBajoVendidos.length > 0}
  <div class="section-block">
    <div class="section-head">
      <h3 class="section-title">Stock bajo — productos populares</h3>
      <span class="sql-badge sql-badge--red">Subquery IN</span>
    </div>
    <p class="section-hint">Productos con stock crítico que han sido vendidos y requieren reabastecimiento urgente.</p>
    <div class="qz-table-wrap">
      <table class="qz-table">
        <thead>
          <tr><th>Producto</th><th>Categoría</th><th>Stock actual</th><th>Stock mínimo</th></tr>
        </thead>
        <tbody>
          {#each productosBajoVendidos as p}
            <tr>
              <td><span class="cell-main">{p.nombre}</span></td>
              <td>{p.categoria}</td>
              <td><span style="color:{p.stock === 0 ? '#DC2626' : '#D97706'};font-weight:600">{p.stock}</span></td>
              <td>{p.stock_minimo}</td>
            </tr>
          {/each}
        </tbody>
      </table>
    </div>
  </div>
{/if}

{/if}

<style>
  .page-header { margin-bottom:24px; }
  .page-title  { font-size:22px; font-weight:700; margin:0 0 2px; }
  .page-sub    { font-size:13px; color:var(--txt-4); margin:0; }

  .stats-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 14px;
    margin-bottom: 24px;
  }
  @media (max-width: 900px) { .stats-grid { grid-template-columns: repeat(2, 1fr); } }
  @media (max-width: 480px) { .stats-grid { grid-template-columns: 1fr 1fr; gap: 10px; } }

  .section-block { margin-bottom:24px; }
  .section-head  { display:flex; align-items:center; gap:10px; margin-bottom:10px; }
  .section-title { font-size:14px; font-weight:600; color:var(--txt-2); margin:0; }
  .section-hint  { font-size:12px; color:var(--txt-4); margin:-4px 0 10px; }

  .sql-badge       { font-size:10px; font-weight:700; padding:2px 8px; border-radius:10px; background:var(--p-100); color:var(--p-700); }
  .sql-badge--red  { background:var(--red-bg);   color:var(--red-text); }
  .sql-badge--green{ background:var(--green-bg); color:var(--green-text); }

  .rank { font-size:11px; font-weight:700; color:var(--p-600); background:var(--p-100); padding:1px 6px; border-radius:6px; }
</style>
