<script lang="ts">
  import { onMount } from 'svelte';
  import Icon from '$lib/components/Icon.svelte';
  import Modal from '$lib/components/Modal.svelte';
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
  let pageError = '';
  let saving = false;
  let modalOpen = false;

  function emptyForm() {
    return { nombre: '', email: '', password: '', dpi: '', telefono: '', cargo: '', fecha_contrato: '', rol_id: '2' };
  }
  let form = emptyForm();

  $: isAdmin = $auth.user?.rol_id === 1;
  $: token   = $auth.token ?? '';

  onMount(async () => {
    const r = await apiFetch('/empleados', token);
    if (r.ok) empleados = await r.json();
    else pageError = 'Error al cargar empleados';
    loading = false;
  });

  async function reload() {
    const r = await apiFetch('/empleados', token);
    if (r.ok) empleados = await r.json();
  }

  function openAdd() {
    form = emptyForm();
    errorMsg = '';
    modalOpen = true;
  }

  function closeModal() {
    modalOpen = false;
    form = emptyForm();
    errorMsg = '';
  }

  async function saveForm() {
    if (!form.nombre || !form.email || !form.password || !form.dpi || !form.telefono || !form.cargo || !form.fecha_contrato) {
      errorMsg = 'Completa todos los campos obligatorios';
      return;
    }
    saving = true;
    errorMsg = '';
    const body = {
      nombre:         form.nombre,
      email:          form.email,
      password:       form.password,
      dpi:            form.dpi,
      telefono:       form.telefono,
      cargo:          form.cargo,
      fecha_contrato: form.fecha_contrato,
      rol_id:         parseInt(form.rol_id),
    };
    try {
      const res = await apiFetch('/empleados', token, { method: 'POST', body: JSON.stringify(body) });
      if (!res.ok) {
        const e = await res.json().catch(() => ({}));
        errorMsg = e.detail ?? 'Error al guardar';
      } else {
        await reload();
        closeModal();
      }
    } finally {
      saving = false;
    }
  }

  $: empleadosFiltrados = empleados.filter(e => {
    const q   = $filtrosEmpleados.busqueda.toLowerCase();
    const est = $filtrosEmpleados.estado;
    const matchBusqueda = !q || e.nombre.toLowerCase().includes(q);
    const matchEstado   = est === 'todos' || e.estado === est;
    return matchBusqueda && matchEstado;
  });
  $: hayFiltros = $filtrosEmpleados.busqueda !== '' || $filtrosEmpleados.estado !== 'todos';

  function onBusqueda(e: Event) { filtrosEmpleados.set({ busqueda: (e.target as HTMLInputElement).value }); }
  function onEstado(e: Event)   { filtrosEmpleados.set({ estado: (e.target as HTMLSelectElement).value }); }

  async function deleteItem(id: number) {
    pageError = '';
    const res = await apiFetch(`/empleados/${id}`, token, { method: 'DELETE' });
    if (res.ok) {
      empleados = empleados.filter(e => e.id !== id);
    } else {
      const e = await res.json().catch(() => ({}));
      pageError = e.detail ?? 'Error al eliminar';
    }
  }

  function formatFecha(f: string) {
    return f ? new Date(f).toLocaleDateString('es-GT') : '—';
  }

  function exportarCSV() {
    exportCsv('empleados.csv',
      ['ID', 'Nombre', 'DPI', 'Cargo', 'Telefono', 'Email', 'Rol', 'Fecha Contrato', 'Estado'],
      empleadosFiltrados.map(e => [e.id, e.nombre, e.dpi, e.cargo, e.telefono, e.email, e.rol_nombre, e.fecha_contrato, e.estado])
    );
  }
</script>

<svelte:head><title>Empleados — QuetzalShop</title></svelte:head>

<Modal open={modalOpen} title="Nuevo empleado" on:close={closeModal}>
  {#if errorMsg}
    <div class="form-error">{errorMsg}</div>
  {/if}

  <div class="form-grid">
    <div class="qz-field span-2">
      <label class="qz-label" for="em-nombre">Nombre completo *</label>
      <input id="em-nombre" class="qz-input" bind:value={form.nombre} placeholder="Nombre del empleado" />
    </div>

    <div class="qz-field">
      <label class="qz-label" for="em-email">Email *</label>
      <input id="em-email" type="email" class="qz-input" bind:value={form.email} placeholder="correo@ejemplo.com" />
    </div>

    <div class="qz-field">
      <label class="qz-label" for="em-password">Contraseña *</label>
      <input id="em-password" type="password" class="qz-input" bind:value={form.password} placeholder="Mínimo 6 caracteres" />
    </div>

    <div class="qz-field">
      <label class="qz-label" for="em-dpi">DPI *</label>
      <input id="em-dpi" class="qz-input" bind:value={form.dpi} placeholder="1234567890101" />
    </div>

    <div class="qz-field">
      <label class="qz-label" for="em-tel">Teléfono *</label>
      <input id="em-tel" class="qz-input" bind:value={form.telefono} placeholder="5555-1234" />
    </div>

    <div class="qz-field">
      <label class="qz-label" for="em-cargo">Cargo *</label>
      <input id="em-cargo" class="qz-input" bind:value={form.cargo} placeholder="Ej: Cajero, Bodeguero" />
    </div>

    <div class="qz-field">
      <label class="qz-label" for="em-contrato">Fecha de contrato *</label>
      <input id="em-contrato" type="date" class="qz-input" bind:value={form.fecha_contrato} />
    </div>

    <div class="qz-field span-2">
      <label class="qz-label" for="em-rol">Rol *</label>
      <select id="em-rol" class="qz-input" bind:value={form.rol_id}>
        <option value="1">Admin</option>
        <option value="2">Cajero</option>
        <option value="3">Bodeguero</option>
      </select>
    </div>
  </div>

  <div class="form-actions">
    <button class="btn btn-md btn-ghost" on:click={closeModal}>Cancelar</button>
    <button class="btn btn-md btn-purple" on:click={saveForm} disabled={saving}>
      <Icon path={IC.plus} size={13} /> {saving ? 'Registrando…' : 'Registrar empleado'}
    </button>
  </div>
</Modal>

<div class="section-header">
  <h2 class="page-title">Empleados</h2>
  <div class="header-actions">
    {#if isAdmin}
      <button class="btn btn-md btn-purple" on:click={openAdd}>
        <Icon path={IC.plus} size={13} /> Nuevo empleado
      </button>
    {/if}
    <button class="btn btn-sm btn-ghost" on:click={exportarCSV} disabled={empleadosFiltrados.length === 0}>
      <Icon path={IC.down} size={13} /> Exportar CSV
    </button>
  </div>
</div>

{#if pageError}
  <div class="page-error">{pageError}</div>
{/if}

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

