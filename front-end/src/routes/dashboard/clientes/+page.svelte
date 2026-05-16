<script lang="ts">
  import { onMount } from 'svelte';
  import Icon from '$lib/components/Icon.svelte';
  import Modal from '$lib/components/Modal.svelte';
  import { IC } from '$lib/icons';
  import { auth } from '$lib/stores/auth';
  import { apiFetch } from '$lib/api';
  import { requireRole } from '$lib/guards';
  import { exportCsv } from '$lib/csv';
  import { filtrosClientes } from '$lib/stores/filtros';

  interface Cliente { id: number; nombre: string; nit: string; telefono: string; direccion: string; }

  let clientes: Cliente[] = [];
  let loading = true;
  let errorMsg = '';
  let pageError = '';
  let saving = false;
  let modalOpen = false;

  type Mode = 'add' | 'edit';
  let mode: Mode = 'add';
  let form = emptyForm();

  function emptyForm() { return { id: 0, nombre: '', nit: '', telefono: '', direccion: '' }; }

  $: rolId    = $auth.user?.rol_id ?? 0;
  $: canEdit  = [1, 2].includes(rolId);
  $: token    = $auth.token ?? '';

  onMount(async () => {
    if (!requireRole([1, 2, 4])) return;
    const r = await apiFetch('/clientes', token);
    if (r.ok) clientes = await r.json();
    else pageError = 'Error al cargar clientes';
    loading = false;
  });

  async function reload() {
    const r = await apiFetch('/clientes', token);
    if (r.ok) clientes = await r.json();
  }

  function openAdd() {
    form = emptyForm();
    mode = 'add';
    errorMsg = '';
    modalOpen = true;
  }

  function startEdit(c: Cliente) {
    form = { id: c.id, nombre: c.nombre, nit: c.nit, telefono: c.telefono, direccion: c.direccion };
    mode = 'edit';
    errorMsg = '';
    modalOpen = true;
  }

  function closeModal() {
    modalOpen = false;
    form = emptyForm();
    mode = 'add';
    errorMsg = '';
  }

  async function saveForm() {
    if (!form.nombre || !form.nit) { errorMsg = 'Nombre y NIT son requeridos'; return; }
    saving = true;
    errorMsg = '';
    const body = { nombre: form.nombre, nit: form.nit, telefono: form.telefono, direccion: form.direccion };
    try {
      const res = mode === 'edit'
        ? await apiFetch(`/clientes/${form.id}`, token, { method: 'PATCH', body: JSON.stringify(body) })
        : await apiFetch('/clientes',            token, { method: 'POST',  body: JSON.stringify(body) });
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

  $: clientesFiltrados = clientes.filter(c => {
    const q = $filtrosClientes.busqueda.toLowerCase();
    return !q || c.nombre.toLowerCase().includes(q) || c.nit.toLowerCase().includes(q);
  });
  $: hayFiltros = $filtrosClientes.busqueda !== '';

  function onBusqueda(e: Event) { filtrosClientes.set({ busqueda: (e.target as HTMLInputElement).value }); }

  function exportarCSV() {
    exportCsv('clientes.csv',
      ['ID', 'Nombre', 'NIT', 'Telefono', 'Direccion'],
      clientesFiltrados.map(c => [c.id, c.nombre, c.nit, c.telefono, c.direccion])
    );
  }

  async function deleteItem(id: number) {
    pageError = '';
    const res = await apiFetch(`/clientes/${id}`, token, { method: 'DELETE' });
    if (res.ok) {
      clientes = clientes.filter(c => c.id !== id);
    } else {
      const e = await res.json().catch(() => ({}));
      pageError = e.detail ?? 'Error al eliminar';
    }
  }
</script>

<svelte:head><title>Clientes — QuetzalShop</title></svelte:head>

<Modal open={modalOpen} title={mode === 'add' ? 'Nuevo cliente' : 'Editar cliente'} on:close={closeModal}>
  {#if errorMsg}
    <div class="form-error">{errorMsg}</div>
  {/if}

  <div class="form-grid">
    <div class="qz-field">
      <label class="qz-label" for="cl-nombre">Nombre *</label>
      <input id="cl-nombre" class="qz-input" bind:value={form.nombre} placeholder="Nombre completo" />
    </div>
    <div class="qz-field">
      <label class="qz-label" for="cl-nit">NIT *</label>
      <input id="cl-nit" class="qz-input" bind:value={form.nit} placeholder="12345678-9" />
    </div>
    <div class="qz-field">
      <label class="qz-label" for="cl-tel">Teléfono</label>
      <input id="cl-tel" class="qz-input" bind:value={form.telefono} placeholder="5555-1234" />
    </div>
    <div class="qz-field">
      <label class="qz-label" for="cl-dir">Dirección</label>
      <input id="cl-dir" class="qz-input" bind:value={form.direccion} placeholder="Dirección" />
    </div>
  </div>

  <div class="form-actions">
    <button class="btn btn-md btn-ghost" on:click={closeModal}>Cancelar</button>
    {#if mode === 'edit'}
      <button class="btn btn-md btn-blue" on:click={saveForm} disabled={saving}>
        <Icon path={IC.check} size={13} /> {saving ? 'Guardando…' : 'Guardar cambios'}
      </button>
    {:else}
      <button class="btn btn-md btn-purple" on:click={saveForm} disabled={saving}>
        <Icon path={IC.plus} size={13} /> {saving ? 'Agregando…' : 'Agregar cliente'}
      </button>
    {/if}
  </div>
</Modal>

<div class="section-header">
  <h2 class="page-title">Clientes</h2>
  <div class="header-actions">
    {#if canEdit}
      <button class="btn btn-md btn-purple" on:click={openAdd}>
        <Icon path={IC.plus} size={13} /> Nuevo cliente
      </button>
    {/if}
    <button class="btn btn-sm btn-ghost" on:click={exportarCSV} disabled={clientesFiltrados.length === 0}>
      <Icon path={IC.down} size={13} /> Exportar CSV
    </button>
  </div>
</div>

{#if pageError}
  <div class="page-error">{pageError}</div>
{/if}

<div class="filtros-bar">
  <input class="qz-input filtro-busqueda" placeholder="Buscar por nombre o NIT…"
    value={$filtrosClientes.busqueda} on:input={onBusqueda} />
  {#if hayFiltros}
    <button class="btn btn-sm btn-ghost" on:click={() => filtrosClientes.reset()}>Limpiar</button>
  {/if}
  <span class="filtro-count">{clientesFiltrados.length} de {clientes.length}</span>
</div>

{#if loading}
  <div class="loading-msg">Cargando clientes…</div>
{:else}
  <div class="qz-table-wrap">
    <table class="qz-table">
      <thead>
        <tr>
          <th>Nombre</th>
          <th>NIT</th>
          <th>Teléfono</th>
          <th>Dirección</th>
          {#if canEdit}<th>Acciones</th>{/if}
        </tr>
      </thead>
      <tbody>
        {#if clientesFiltrados.length === 0}
          <tr class="empty-row"><td colspan={canEdit ? 5 : 4}>{hayFiltros ? 'Sin coincidencias' : 'Sin clientes registrados'}</td></tr>
        {:else}
          {#each clientesFiltrados as c}
            <tr>
              <td><span class="cell-main">{c.nombre}</span></td>
              <td><span class="cell-mono">{c.nit}</span></td>
              <td>{c.telefono}</td>
              <td><span class="cell-sub">{c.direccion}</span></td>
              {#if canEdit}
                <td>
                  <div class="row-actions">
                    <button class="btn btn-sm btn-blue" on:click={() => startEdit(c)}>
                      <Icon path={IC.edit} size={11} /> Editar
                    </button>
                    <button class="btn btn-sm btn-danger" on:click={() => deleteItem(c.id)}>
                      <Icon path={IC.trash} size={11} /> Eliminar
                    </button>
                  </div>
                </td>
              {/if}
            </tr>
          {/each}
        {/if}
      </tbody>
    </table>
  </div>
{/if}

