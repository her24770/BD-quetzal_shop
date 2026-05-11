<script lang="ts">
  import { onMount } from 'svelte';
  import StatCard from '$lib/components/StatCard.svelte';
  import { IC } from '$lib/icons';
  import { auth } from '$lib/stores/auth';
  import { apiFetch } from '$lib/api';

  interface Stats {
    ventas_hoy:  { count: number; total: number };
    compras_mes: number;
    stock_bajo:  number;
    empleados:   { total: number; activos: number };
  }
  interface TopProducto  { nombre: string; categoria: string; total_vendido: number; total_ingresos: number; }
  interface VentaMetodo  { metodo: string; cantidad: number; total: number; }
  interface ClienteActivo { id: number; nombre: string; nit: string; }
  interface ProductoBajo { nombre: string; stock: number; stock_minimo: number; categoria: string; }
  interface VentaReciente { id: number; fecha: string; total: number; cliente: string; empleado: string; metodo_pago: string; }

  let stats: Stats | null = null;
  let topProductos:   TopProducto[]   = [];
  let ventasPorMetodo: VentaMetodo[]  = [];
  let clientesActivos: ClienteActivo[] = [];
  let productosBajoVendidos: ProductoBajo[] = [];
  let ultimasVentas: VentaReciente[] = [];
  let loading = true;

  $: rolId  = $auth.user?.rol_id ?? 0;
  $: token  = $auth.token ?? '';
  $: isAdmin  = rolId === 1;
  $: canVerVentas = [1, 2].includes(rolId);

  $: user = $auth.user;

  const fmt  = (n: number) => 'Q ' + Number(n).toLocaleString('es-GT', { minimumFractionDigits: 2 });
  const fmtF = (f: string) => new Date(f).toLocaleDateString('es-GT', { month: 'short', day: 'numeric' });

  onMount(async () => {
    const calls: Promise<any>[] = [
      apiFetch('/reportes/stats',                token).then(r => r.ok && r.json().then((d: Stats) => stats = d)),
      apiFetch('/reportes/top-productos',         token).then(r => r.ok && r.json().then((d: TopProducto[]) => topProductos = d)),
      apiFetch('/reportes/productos-bajo-vendidos', token).then(r => r.ok && r.json().then((d: ProductoBajo[]) => productosBajoVendidos = d)),
    ];

    if (canVerVentas) {
      calls.push(
        apiFetch('/reportes/ventas-por-metodo',  token).then(r => r.ok && r.json().then((d: VentaMetodo[]) => ventasPorMetodo = d)),
        apiFetch('/reportes/clientes-activos',   token).then(r => r.ok && r.json().then((d: ClienteActivo[]) => clientesActivos = d)),
        apiFetch('/ventas',                      token).then(r => r.ok && r.json().then((d: VentaReciente[]) => ultimasVentas = d.slice(0, 5))),
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
  <StatCard
    label="Ventas del día"
    value={stats ? fmt(stats.ventas_hoy.total) : 'Q 0.00'}
    sub="{stats?.ventas_hoy.count ?? 0} transacciones"
    iconPath={IC.cart}
    iconBg="#EDE9FE" iconColor="#7C3AED"
  />
  <StatCard
    label="Stock bajo"
    value={stats?.stock_bajo ?? 0}
    sub="Productos con alerta"
    iconPath={IC.alert}
    iconBg="#FEF3C7" iconColor="#D97706"
  />
  <StatCard
    label="Compras del mes"
    value={stats ? fmt(stats.compras_mes) : 'Q 0.00'}
    sub="Acumulado del mes"
    iconPath={IC.pkg}
    iconBg="#DBEAFE" iconColor="#2563EB"
  />
  <StatCard
    label="Empleados activos"
    value={stats?.empleados.activos ?? 0}
    sub="de {stats?.empleados.total ?? 0} registrados"
    iconPath={IC.person}
    iconBg="#D1FAE5" iconColor="#059669"
  />
</div>

<!-- ── Top 5 productos más vendidos (CTE + GROUP BY) ── -->
{#if topProductos.length > 0}
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
              <td><span class="cell-total">{fmt(p.total_ingresos)}</span></td>
            </tr>
          {/each}
        </tbody>
      </table>
    </div>
  </div>
{/if}

<!-- ── Últimas ventas (VIEW v_ventas_completo) ── -->
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
              <td>{fmtF(v.fecha)}</td>
              <td><span class="cell-main">{v.cliente}</span></td>
              <td><span class="cell-sub">{v.empleado}</span></td>
              <td>{v.metodo_pago}</td>
              <td><span class="cell-total">{fmt(v.total)}</span></td>
            </tr>
          {/each}
        </tbody>
      </table>
    </div>
  </div>
{/if}

<!-- ── Dos columnas: método de pago + clientes activos ── -->
{#if canVerVentas}
  <div class="two-col">

    <!-- Ventas por método de pago (GROUP BY + HAVING) -->
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
            {#if ventasPorMetodo.length === 0}
              <tr class="empty-row"><td colspan="3">Sin datos</td></tr>
            {:else}
              {#each ventasPorMetodo as m}
                <tr>
                  <td><span class="cell-main">{m.metodo}</span></td>
                  <td>{m.cantidad}</td>
                  <td><span class="cell-total">{fmt(m.total)}</span></td>
                </tr>
              {/each}
            {/if}
          </tbody>
        </table>
      </div>
    </div>

    <!-- Clientes que han comprado (EXISTS) -->
    <div class="section-block">
      <div class="section-head">
        <h3 class="section-title">Clientes con ventas</h3>
        <span class="sql-badge">Subquery EXISTS</span>
      </div>
      <div class="qz-table-wrap">
        <table class="qz-table">
          <thead>
            <tr><th>Cliente</th><th>NIT</th></tr>
          </thead>
          <tbody>
            {#if clientesActivos.length === 0}
              <tr class="empty-row"><td colspan="2">Sin datos</td></tr>
            {:else}
              {#each clientesActivos as c}
                <tr>
                  <td><span class="cell-main">{c.nombre}</span></td>
                  <td><span class="cell-mono">{c.nit}</span></td>
                </tr>
              {/each}
            {/if}
          </tbody>
        </table>
      </div>
    </div>

  </div>
{/if}

<!-- ── Productos con stock bajo y vendidos (IN subquery) ── -->
{#if productosBajoVendidos.length > 0}
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
  .page-title  { font-size:22px; font-weight:700; color:#111827; margin:0 0 2px; }
  .page-sub    { font-size:13px; color:#9CA3AF; margin:0; }
  .loading-msg { color:#9CA3AF; font-size:14px; padding:20px 0; }

  /* Stats grid */
  .stats-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 14px;
    margin-bottom: 24px;
  }

  /* Secciones */
  .section-block { margin-bottom:24px; }
  .section-head  { display:flex; align-items:center; gap:10px; margin-bottom:10px; }
  .section-title { font-size:14px; font-weight:600; color:#374151; margin:0; }
  .section-hint  { font-size:12px; color:#9CA3AF; margin:-4px 0 10px; }

  /* Badge SQL type */
  .sql-badge {
    font-size:10px; font-weight:700;
    padding:2px 8px; border-radius:10px;
    background:#EDE9FE; color:#7C3AED;
  }
  .sql-badge--red   { background:#FEE2E2; color:#DC2626; }
  .sql-badge--green { background:#D1FAE5; color:#065F46; }

  /* Dos columnas */
  .two-col {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 16px;
    margin-bottom: 24px;
  }

  /* Celdas */
  .rank      { font-size:11px; font-weight:700; color:#7C3AED; background:#EDE9FE; padding:1px 6px; border-radius:6px; }
  .cell-main { font-weight:500; color:#111827; }
  .cell-sub  { font-size:12px; color:#6B7280; }
  .cell-num  { font-weight:600; }
  .cell-mono { font-family:monospace; font-size:13px; }
  .cell-total { font-weight:700; color:#111827; }
  .cell-id   { font-family:monospace; color:#9CA3AF; font-size:12px; }
</style>
