<script lang="ts">
  import { onMount } from 'svelte';
  import Icon from '$lib/components/Icon.svelte';
  import { IC } from '$lib/icons';
  import { auth } from '$lib/stores/auth';
  import { apiFetch } from '$lib/api';
  import { exportCsv } from '$lib/csv';
  import { filtrosEmpleados } from '$lib/stores/filtros';

  interface Empleado {
    id: number; usuario_id: number; dpi: string; nombre: string;
    telefono: string; cargo: string; fecha_contrato: string;
    estado: string; email: string; rol_nombre: string;
  }

  let empleados: Empleado[] = [];
  let loading = true;
  let errorMsg = '';

  $: isAdmin = $auth.user?.rol_id === 1;
  $: token   = $auth.token ?? '';

  onMount(async () => {
    const r = await apiFetch('/empleados', token);
    if (r.ok) empleados = await r.json();
    else errorMsg = 'Error al cargar empleados';
    loading = false;
  });

  $: empleadosFiltrados = empleados.filter(e => {
    const q   = $filtrosEmpleados.busqueda.toLowerCase();
    const est = $filtrosEmpleados.estado;
    const matchBusqueda = !q || e.nombre.toLowerCase().includes(q);
    const matchEstado   = est === 'todos' || e.estado === est;
    return matchBusqueda && matchEstado;
  });
  $: hayFiltros = $filtrosEmpleados.busqueda !== '' || $filtrosEmpleados.estado !== 'todos';

  function onBusqueda(e: Event)  { filtrosEmpleados.set({ busqueda: (e.target as HTMLInputElement).value }); }
  function onEstado(e: Event)    { filtrosEmpleados.set({ estado: (e.target as HTMLSelectElement).value }); }

  async function deleteItem(id: number) {
    errorMsg = '';
    const res = await apiFetch(`/empleados/${id}`, token, { method: 'DELETE' });
    if (res.ok) {
      empleados = empleados.filter(e => e.id !== id);
    } else {
      const e = await res.json().catch(() => ({}));
      errorMsg = e.detail ?? 'Error al eliminar';
    }
  }

  function formatFecha(f: string) {
    return f ? new Date(f).toLocaleDateString('es-GT') : '—';
  }

  function exportarCSV() {
    exportCsv('empleados.csv',
      ['ID', 'Nombre', 'DPI', 'Cargo', 'Telefono', 'Email', 'Rol', 'Fecha Contrato', 'Estado'],
      empleados.map(e => [e.id, e.nombre, e.dpi, e.cargo, e.telefono, e.email, e.rol_nombre, e.fecha_contrato, e.estado])
    );
  }
</script>

<svelte:head><title>Empleados — QuetzalShop</title></svelte:head>

<div class="section-header">
  <h2 class="page-title">Empleados</h2>
  <button class="btn btn-sm btn-ghost" on:click={exportarCSV} disabled={empleadosFiltrados.length === 0}>
    <Icon path={IC.down} size={13} /> Exportar CSV
  </button>
</div>

<div class="filtros-bar">
  <input class="qz-input filtro-busqueda" placeholder="Buscar por nombre…"
    value={$filtrosEmpleados.busqueda} on:input={onBusqueda} />
  <select class="qz-input filtro-select" value={$filtrosEmpleados.estado} on:change={onEstado}>
    <option value="todos">Todos los estados</option>
    <option value="activo">Activo</option>
    <option value="inactivo">Inactivo</option>
  </select>
  {#if hayFiltros}
    <button class="btn btn-sm btn-ghost" on:click={() => filtrosEmpleados.reset()}>Limpiar</button>
  {/if}
  <span class="filtro-count">{empleadosFiltrados.length} de {empleados.length}</span>
</div>

{#if errorMsg}
  <div class="form-error">{errorMsg}</div>
{/if}

{#if loading}
  <div class="loading-msg">Cargando empleados…</div>
{:else}
  <div class="qz-table-wrap">
    <table class="qz-table">
      <thead>
        <tr>
          <th>Nombre</th>
          <th>DPI</th>
          <th>Cargo</th>
          <th>Teléfono</th>
          <th>Email</th>
          <th>Rol</th>
          <th>Contrato</th>
          <th>Estado</th>
          {#if isAdmin}<th>Acciones</th>{/if}
        </tr>
      </thead>
      <tbody>
        {#if empleadosFiltrados.length === 0}
          <tr class="empty-row"><td colspan="9">{hayFiltros ? 'Sin coincidencias' : 'Sin empleados registrados'}</td></tr>
        {:else}
          {#each empleadosFiltrados as e}
            <tr>
              <td><span class="cell-main">{e.nombre}</span></td>
              <td><span class="cell-mono">{e.dpi}</span></td>
              <td>{e.cargo}</td>
              <td>{e.telefono}</td>
              <td><span class="cell-sub">{e.email}</span></td>
              <td>{e.rol_nombre}</td>
              <td>{formatFecha(e.fecha_contrato)}</td>
              <td>
                <span class="badge" class:badge-green={e.estado === 'activo'} class:badge-gray={e.estado !== 'activo'}>
                  {e.estado}
                </span>
              </td>
              {#if isAdmin}
                <td>
                  <button class="btn btn-sm btn-danger" on:click={() => deleteItem(e.id)}>
                    <Icon path={IC.trash} size={11} /> Eliminar
                  </button>
                </td>
              {/if}
            </tr>
          {/each}
        {/if}
      </tbody>
    </table>
  </div>
{/if}

<style>
  .filtros-bar { display:flex; align-items:center; gap:10px; flex-wrap:wrap; margin-bottom:16px; }
  .filtro-busqueda { flex:1; min-width:180px; max-width:260px; }
  .filtro-select { min-width:160px; }
  .filtro-count { font-size:12px; color:#9CA3AF; margin-left:auto; white-space:nowrap; }
  .section-header { display:flex; align-items:center; justify-content:space-between; margin-bottom:14px; }
  .page-title { font-size:20px; font-weight:700; color:#111827; margin:0; }
  .form-error { background:#FEF2F2; border:1px solid #FECACA; color:#DC2626; font-size:13px; padding:8px 12px; border-radius:6px; margin-bottom:14px; }
  .loading-msg { color:#9CA3AF; font-size:14px; padding:20px 0; }
  .cell-main { font-weight:500; color:#111827; }
  .cell-sub  { font-size:12px; color:#6B7280; }
  .cell-mono { font-family:monospace; font-size:13px; }
  .badge { font-size:10px; font-weight:700; padding:2px 8px; border-radius:10px; }
  .badge-green { background:#D1FAE5; color:#065F46; }
  .badge-gray  { background:#F3F4F6; color:#6B7280; }
</style>
