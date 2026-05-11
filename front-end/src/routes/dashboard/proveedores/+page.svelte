<script lang="ts">
  import { onMount } from 'svelte';
  import Icon from '$lib/components/Icon.svelte';
  import { IC } from '$lib/icons';
  import { auth } from '$lib/stores/auth';
  import { apiFetch } from '$lib/api';
  import { exportCsv } from '$lib/csv';
  import { filtrosProveedores } from '$lib/stores/filtros';

  interface Proveedor { id: number; nombre: string; telefono: string; email: string; direccion: string; }

  let proveedores: Proveedor[] = [];
  let loading = true;
  let errorMsg = '';
  let saving = false;
  let formEl: HTMLElement;

  type Mode = 'add' | 'edit';
  let mode: Mode = 'add';
  let form = emptyForm();

  function emptyForm() { return { id: 0, nombre: '', telefono: '', email: '', direccion: '' }; }

  $: isAdmin = $auth.user?.rol_id === 1;
  $: token   = $auth.token ?? '';

  onMount(async () => {
    const r = await apiFetch('/proveedores', token);
    if (r.ok) proveedores = await r.json();
    else errorMsg = 'Error al cargar proveedores';
    loading = false;
  });

  async function reload() {
    const r = await apiFetch('/proveedores', token);
    if (r.ok) proveedores = await r.json();
  }

  function startEdit(p: Proveedor) {
    form = { id: p.id, nombre: p.nombre, telefono: p.telefono, email: p.email, direccion: p.direccion };
    mode = 'edit';
    errorMsg = '';
    setTimeout(() => formEl?.scrollIntoView({ behavior: 'smooth', block: 'start' }), 0);
  }

  function cancelForm() {
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
        cancelForm();
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
    errorMsg = '';
    const res = await apiFetch(`/proveedores/${id}`, token, { method: 'DELETE' });
    if (res.ok) {
      proveedores = proveedores.filter(p => p.id !== id);
      if (form.id === id) cancelForm();
    } else {
      const e = await res.json().catch(() => ({}));
      errorMsg = e.detail ?? 'Error al eliminar';
      setTimeout(() => formEl?.scrollIntoView({ behavior: 'smooth', block: 'start' }), 0);
    }
  }
</script>

<svelte:head><title>Proveedores — QuetzalShop</title></svelte:head>

{#if isAdmin}
  <div class="form-card" bind:this={formEl}>
    <div class="form-card__header">
      <h3 class="form-card__title">{mode === 'add' ? 'Nuevo proveedor' : 'Editar proveedor'}</h3>
    </div>

    {#if errorMsg}
      <div class="form-error">{errorMsg}</div>
    {/if}

    <div class="form-grid">
      <div class="qz-field">
        <label class="qz-label" for="p-nombre">Nombre *</label>
        <input id="p-nombre" class="qz-input" bind:value={form.nombre} placeholder="Nombre del proveedor" />
      </div>
      <div class="qz-field">
        <label class="qz-label" for="p-tel">Teléfono *</label>
        <input id="p-tel" class="qz-input" bind:value={form.telefono} placeholder="5555-1234" />
      </div>
      <div class="qz-field">
        <label class="qz-label" for="p-email">Email *</label>
        <input id="p-email" type="email" class="qz-input" bind:value={form.email} placeholder="contacto@proveedor.com" />
      </div>
      <div class="qz-field">
        <label class="qz-label" for="p-dir">Dirección</label>
        <input id="p-dir" class="qz-input" bind:value={form.direccion} placeholder="Dirección" />
      </div>
    </div>

    <div class="form-actions">
      {#if mode === 'edit'}
        <button class="btn btn-md btn-ghost" on:click={cancelForm}>Cancelar</button>
        <button class="btn btn-md btn-blue" on:click={saveForm} disabled={saving}>
          <Icon path={IC.check} size={13} /> {saving ? 'Guardando…' : 'Guardar cambios'}
        </button>
      {:else}
        <button class="btn btn-md btn-purple" on:click={saveForm} disabled={saving}>
          <Icon path={IC.plus} size={13} /> {saving ? 'Agregando…' : 'Agregar proveedor'}
        </button>
      {/if}
    </div>
  </div>
{/if}

<div class="section-header">
  <h2 class="page-title">Proveedores</h2>
  <button class="btn btn-sm btn-ghost" on:click={exportarCSV} disabled={proveedoresFiltrados.length === 0}>
    <Icon path={IC.down} size={13} /> Exportar CSV
  </button>
</div>

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
          {#if isAdmin}<th>Acciones</th>{/if}
        </tr>
      </thead>
      <tbody>
        {#if proveedoresFiltrados.length === 0}
          <tr class="empty-row"><td colspan={isAdmin ? 5 : 4}>{hayFiltros ? 'Sin coincidencias' : 'Sin proveedores registrados'}</td></tr>
        {:else}
          {#each proveedoresFiltrados as p}
            <tr class:row-selected={form.id === p.id && mode === 'edit'}>
              <td><span class="cell-main">{p.nombre}</span></td>
              <td>{p.telefono}</td>
              <td><span class="cell-sub">{p.email}</span></td>
              <td><span class="cell-sub">{p.direccion}</span></td>
              {#if isAdmin}
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

<style>
  .form-card { background:#fff; border:1px solid #E5E7EB; border-radius:10px; padding:20px 24px; margin-bottom:24px; }
  .form-card__header { display:flex; align-items:center; justify-content:space-between; margin-bottom:16px; }
  .form-card__title { font-size:15px; font-weight:600; color:#111827; margin:0; }
  .form-error { background:#FEF2F2; border:1px solid #FECACA; color:#DC2626; font-size:13px; padding:8px 12px; border-radius:6px; margin-bottom:14px; }
  .form-grid { display:grid; grid-template-columns:1fr 1fr; gap:14px 20px; }
  .form-actions { display:flex; justify-content:flex-end; gap:10px; margin-top:16px; padding-top:14px; border-top:1px solid #F3F4F6; }
  .filtros-bar { display:flex; align-items:center; gap:10px; flex-wrap:wrap; margin-bottom:16px; }
  .filtro-busqueda { flex:1; min-width:180px; max-width:300px; }
  .filtro-count { font-size:12px; color:#9CA3AF; margin-left:auto; white-space:nowrap; }
  .section-header { display:flex; align-items:center; justify-content:space-between; margin-bottom:14px; }
  .page-title { font-size:20px; font-weight:700; color:#111827; margin:0; }
  .loading-msg { color:#9CA3AF; font-size:14px; padding:20px 0; }
  .cell-main { font-weight:500; color:#111827; }
  .cell-sub { font-size:12px; color:#6B7280; }
  .row-actions { display:flex; gap:6px; }
  .row-selected td { background:#F5F3FF; }
</style>
