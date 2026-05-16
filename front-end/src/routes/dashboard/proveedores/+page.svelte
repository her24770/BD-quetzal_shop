<script lang="ts">
  import { onMount } from 'svelte';
  import Icon from '$lib/components/Icon.svelte';
  import Modal from '$lib/components/Modal.svelte';
  import { IC } from '$lib/icons';
  import { auth } from '$lib/stores/auth';
  import { apiFetch } from '$lib/api';
  import { exportCsv } from '$lib/csv';
  import { filtrosProveedores } from '$lib/stores/filtros';
  import { requireRole } from '$lib/guards';

  interface Proveedor { id: number; nombre: string; telefono: string; email: string; direccion: string; }

  let proveedores: Proveedor[] = [];
  let loading = true;
  let errorMsg = '';
  let pageError = '';
  let saving = false;
  let modalOpen = false;

  type Mode = 'add' | 'edit';
  let mode: Mode = 'add';
  let form = emptyForm();

  function emptyForm() { return { id: 0, nombre: '', telefono: '', email: '', direccion: '' }; }

  $: rolId    = $auth.user?.rol_id ?? 0;
  $: canEdit  = [1, 3].includes(rolId);
  $: token    = $auth.token ?? '';

  onMount(async () => {
    if (!requireRole([1, 3, 4])) return;
    const r = await apiFetch('/proveedores', token);
    if (r.ok) proveedores = await r.json();
    else pageError = 'Error al cargar proveedores';
    loading = false;
  });

  async function reload() {
    const r = await apiFetch('/proveedores', token);
    if (r.ok) proveedores = await r.json();
  }

  function openAdd() {
    form = emptyForm();
    mode = 'add';
    errorMsg = '';
    modalOpen = true;
  }

  function startEdit(p: Proveedor) {
    form = { id: p.id, nombre: p.nombre, telefono: p.telefono, email: p.email, direccion: p.direccion };
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
    if (!form.nombre || !form.telefono || !form.email) { errorMsg = 'Completa los campos obligatorios'; return; }
    saving = true;
    errorMsg = '';
    const body = { nombre: form.nombre, telefono: form.telefono, email: form.email, direccion: form.direccion };
    try {
      const res = mode === 'edit'
        ? await apiFetch(`/proveedores/${form.id}`, token, { method: 'PATCH', body: JSON.stringify(body) })
        : await apiFetch('/proveedores',            token, { method: 'POST',  body: JSON.stringify(body) });
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

  $: proveedoresFiltrados = proveedores.filter(p => {
    const q = $filtrosProveedores.busqueda.toLowerCase();
    return !q || p.nombre.toLowerCase().includes(q) || p.email.toLowerCase().includes(q);
  });
  $: hayFiltros = $filtrosProveedores.busqueda !== '';

  function onBusqueda(e: Event) { filtrosProveedores.set({ busqueda: (e.target as HTMLInputElement).value }); }

  function exportarCSV() {
    exportCsv('proveedores.csv',
      ['ID', 'Nombre', 'Telefono', 'Email', 'Direccion'],
      proveedoresFiltrados.map(p => [p.id, p.nombre, p.telefono, p.email, p.direccion])
    );
  }

  async function deleteItem(id: number) {
    pageError = '';
    const res = await apiFetch(`/proveedores/${id}`, token, { method: 'DELETE' });
    if (res.ok) {
      proveedores = proveedores.filter(p => p.id !== id);
    } else {
      const e = await res.json().catch(() => ({}));
      pageError = e.detail ?? 'Error al eliminar';
    }
  }
</script>

<svelte:head><title>Proveedores — QuetzalShop</title></svelte:head>

<Modal open={modalOpen} title={mode === 'add' ? 'Nuevo proveedor' : 'Editar proveedor'} on:close={closeModal}>
  {#if errorMsg}
    <div class="form-error">{errorMsg}</div>
  {/if}

  <div class="form-grid">
    <div class="qz-field">
      <label class="qz-label" for="pv-nombre">Nombre *</label>
      <input id="pv-nombre" class="qz-input" bind:value={form.nombre} placeholder="Nombre del proveedor" />
    </div>
    <div class="qz-field">
      <label class="qz-label" for="pv-tel">Teléfono *</label>
      <input id="pv-tel" class="qz-input" bind:value={form.telefono} placeholder="5555-1234" />
    </div>
    <div class="qz-field">
      <label class="qz-label" for="pv-email">Email *</label>
      <input id="pv-email" type="email" class="qz-input" bind:value={form.email} placeholder="contacto@proveedor.com" />
    </div>
    <div class="qz-field">
      <label class="qz-label" for="pv-dir">Dirección</label>
      <input id="pv-dir" class="qz-input" bind:value={form.direccion} placeholder="Dirección" />
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
        <Icon path={IC.plus} size={13} /> {saving ? 'Agregando…' : 'Agregar proveedor'}
      </button>
    {/if}
  </div>
</Modal>

<div class="section-header">
  <h2 class="page-title">Proveedores</h2>
  <div class="header-actions">
    {#if canEdit}
      <button class="btn btn-md btn-purple" on:click={openAdd}>
        <Icon path={IC.plus} size={13} /> Nuevo proveedor
      </button>
    {/if}
    <button class="btn btn-sm btn-ghost" on:click={exportarCSV} disabled={proveedoresFiltrados.length === 0}>
      <Icon path={IC.down} size={13} /> Exportar CSV
    </button>
  </div>
</div>

{#if pageError}
  <div class="page-error">{pageError}</div>
{/if}

<div class="filtros-bar">
  <input class="qz-input filtro-busqueda" placeholder="Buscar por nombre o email…"
    value={$filtrosProveedores.busqueda} on:input={onBusqueda} />
  {#if hayFiltros}
    <button class="btn btn-sm btn-ghost" on:click={() => filtrosProveedores.reset()}>Limpiar</button>
  {/if}
  <span class="filtro-count">{proveedoresFiltrados.length} de {proveedores.length}</span>
</div>

{#if loading}
  <div class="loading-msg">Cargando proveedores…</div>
{:else}
  <div class="qz-table-wrap">
    <table class="qz-table">
      <thead>
        <tr>
          <th>Nombre</th>
          <th>Teléfono</th>
          <th>Email</th>
          <th>Dirección</th>
          {#if canEdit}<th>Acciones</th>{/if}
        </tr>
      </thead>
      <tbody>
        {#if proveedoresFiltrados.length === 0}
          <tr class="empty-row"><td colspan={canEdit ? 5 : 4}>{hayFiltros ? 'Sin coincidencias' : 'Sin proveedores registrados'}</td></tr>
        {:else}
          {#each proveedoresFiltrados as p}
            <tr>
              <td><span class="cell-main">{p.nombre}</span></td>
              <td>{p.telefono}</td>
              <td><span class="cell-sub">{p.email}</span></td>
              <td><span class="cell-sub">{p.direccion}</span></td>
              {#if canEdit}
                <td>
                  <div class="row-actions">
                    <button class="btn btn-sm btn-blue" on:click={() => startEdit(p)}>
                      <Icon path={IC.edit} size={11} /> Editar
                    </button>
                    <button class="btn btn-sm btn-danger" on:click={() => deleteItem(p.id)}>
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

