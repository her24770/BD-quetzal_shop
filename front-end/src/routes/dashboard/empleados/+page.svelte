<script lang="ts">
  import { onMount } from 'svelte';
  import Icon from '$lib/components/Icon.svelte';
  import Modal from '$lib/components/Modal.svelte';
  import DataTable from '$lib/components/DataTable.svelte';
  import FilterBar from '$lib/components/FilterBar.svelte';
  import { IC } from '$lib/icons';
  import { auth } from '$lib/stores/auth';
  import { exportCsv } from '$lib/csv';
  import { filtrosEmpleados } from '$lib/stores/filtros';
  import { requirePermiso } from '$lib/guards';
  import { permisos } from '$lib/stores/permisos';
  import { formatFecha } from '$lib/utils';
  import { type Empleado, type EmpleadoForm, empleadosApi } from '$lib/api/empleados';

  let empleados: Empleado[] = [];
  let loading   = true;
  let pageError = '';
  let errorMsg  = '';
  let saving    = false;
  let modalOpen = false;
  let form = emptyForm();

  function emptyForm(): EmpleadoForm {
    return { nombre: '', email: '', password: '', dpi: '', telefono: '', cargo: '', fecha_contrato: '', rol_id: '2' };
  }

  $: token     = $auth.token ?? '';
  $: canDelete = ($permisos['empleados'] ?? []).includes('DELETE');
  $: canWrite  = ($permisos['empleados'] ?? []).includes('INSERT');

  $: empleadosFiltrados = empleados.filter(e => {
    const q   = $filtrosEmpleados.busqueda.toLowerCase();
    const est = $filtrosEmpleados.estado;
    return (!q || e.nombre.toLowerCase().includes(q)) && (est === 'todos' || e.estado === est);
  });
  $: hayFiltros = $filtrosEmpleados.busqueda !== '' || $filtrosEmpleados.estado !== 'todos';

  onMount(async () => {
    if (!requirePermiso('empleados')) return;
    try {
      empleados = await empleadosApi.getAll(token);
    } catch (e: any) {
      pageError = e.message;
    } finally {
      loading = false;
    }
  });

  function openAdd() { form = emptyForm(); errorMsg = ''; modalOpen = true; }
  function closeModal() { modalOpen = false; form = emptyForm(); errorMsg = ''; }

  async function saveForm() {
    if (!form.nombre || !form.email || !form.password || !form.dpi || !form.telefono || !form.cargo || !form.fecha_contrato) {
      errorMsg = 'Completa todos los campos obligatorios'; return;
    }
    saving = true; errorMsg = '';
    try {
      await empleadosApi.create(token, form);
      empleados = await empleadosApi.getAll(token);
      closeModal();
    } catch (e: any) {
      errorMsg = e.message;
    } finally {
      saving = false;
    }
  }

  async function deleteItem(id: number) {
    pageError = '';
    try {
      await empleadosApi.delete(token, id);
      empleados = empleados.filter(e => e.id !== id);
    } catch (e: any) {
      pageError = e.message;
    }
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
  {#if errorMsg}<div class="form-error">{errorMsg}</div>{/if}

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
    {#if canWrite}
      <button class="btn btn-md btn-purple" on:click={openAdd}>
        <Icon path={IC.plus} size={13} /> Nuevo empleado
      </button>
    {/if}
    <button class="btn btn-sm btn-ghost" on:click={exportarCSV} disabled={empleadosFiltrados.length === 0}>
      <Icon path={IC.down} size={13} /> Exportar CSV
    </button>
  </div>
</div>

{#if pageError}<div class="page-error">{pageError}</div>{/if}

<FilterBar
  value={$filtrosEmpleados.busqueda}
  placeholder="Buscar por nombre…"
  total={empleados.length}
  filtered={empleadosFiltrados.length}
  hasActive={hayFiltros}
  on:search={e => filtrosEmpleados.set({ busqueda: e.detail })}
  on:clear={() => filtrosEmpleados.reset()}
>
  <select class="qz-input filtro-select" value={$filtrosEmpleados.estado}
    on:change={e => filtrosEmpleados.set({ estado: e.currentTarget.value })}>
    <option value="todos">Todos los estados</option>
    <option value="activo">Activo</option>
    <option value="inactivo">Inactivo</option>
  </select>
</FilterBar>

{#if loading}
  <div class="loading-msg">Cargando empleados…</div>
{:else}
  <DataTable
    rows={empleadosFiltrados}
    canWrite={false}
    {canDelete}
    colspan={8}
    emptyMsg={hayFiltros ? 'Sin coincidencias' : 'Sin empleados registrados'}
    on:delete={e => deleteItem(e.detail)}
  >
    <svelte:fragment slot="headers">
      <th>Nombre</th><th>DPI</th><th>Cargo</th><th>Teléfono</th>
      <th>Email</th><th>Rol</th><th>Contrato</th><th>Estado</th>
    </svelte:fragment>
    <svelte:fragment slot="row" let:row>
      <td><span class="cell-main">{row.nombre}</span></td>
      <td><span class="cell-mono">{row.dpi}</span></td>
      <td>{row.cargo}</td>
      <td>{row.telefono}</td>
      <td><span class="cell-sub">{row.email}</span></td>
      <td>{row.rol_nombre}</td>
      <td>{formatFecha(row.fecha_contrato)}</td>
      <td>
        <span class="badge" class:badge-green={row.estado === 'activo'} class:badge-gray={row.estado !== 'activo'}>
          {row.estado}
        </span>
      </td>
    </svelte:fragment>
  </DataTable>
{/if}
