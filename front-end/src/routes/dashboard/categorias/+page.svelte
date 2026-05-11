<script lang="ts">
  import { onMount } from 'svelte';
  import Icon from '$lib/components/Icon.svelte';
  import { IC } from '$lib/icons';
  import { auth } from '$lib/stores/auth';
  import { apiFetch } from '$lib/api';
  import { filtrosCategorias } from '$lib/stores/filtros';

  interface Categoria { id: number; nombre: string; descripcion: string; }

  let categorias: Categoria[] = [];
  let loading = true;
  let errorMsg = '';
  let saving = false;
  let formEl: HTMLElement;

  type Mode = 'add' | 'edit';
  let mode: Mode = 'add';
  let form = emptyForm();

  function emptyForm() { return { id: 0, nombre: '', descripcion: '' }; }

  $: isAdmin = $auth.user?.rol_id === 1;
  $: token   = $auth.token ?? '';

  onMount(async () => {
    const r = await apiFetch('/categorias', token);
    if (r.ok) categorias = await r.json();
    else errorMsg = 'Error al cargar categorías';
    loading = false;
  });

  async function reload() {
    const r = await apiFetch('/categorias', token);
    if (r.ok) categorias = await r.json();
  }

  function startEdit(c: Categoria) {
    form = { id: c.id, nombre: c.nombre, descripcion: c.descripcion };
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
    if (!form.nombre) { errorMsg = 'El nombre es requerido'; return; }
    saving = true;
    errorMsg = '';
    const body = { nombre: form.nombre, descripcion: form.descripcion };
    try {
      const res = mode === 'edit'
        ? await apiFetch(`/categorias/${form.id}`, token, { method: 'PATCH', body: JSON.stringify(body) })
        : await apiFetch('/categorias',            token, { method: 'POST',  body: JSON.stringify(body) });
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

  $: categoriasFiltradas = categorias.filter(c => {
    const q = $filtrosCategorias.busqueda.toLowerCase();
    return !q || c.nombre.toLowerCase().includes(q);
  });
  $: hayFiltros = $filtrosCategorias.busqueda !== '';

  function onBusqueda(e: Event) { filtrosCategorias.set({ busqueda: (e.target as HTMLInputElement).value }); }

  async function deleteItem(id: number) {
    errorMsg = '';
    const res = await apiFetch(`/categorias/${id}`, token, { method: 'DELETE' });
    if (res.ok) {
      categorias = categorias.filter(c => c.id !== id);
      if (form.id === id) cancelForm();
    } else {
      const e = await res.json().catch(() => ({}));
      errorMsg = e.detail ?? 'Error al eliminar';
      setTimeout(() => formEl?.scrollIntoView({ behavior: 'smooth', block: 'start' }), 0);
    }
  }
</script>

<svelte:head><title>Categorías — QuetzalShop</title></svelte:head>

{#if isAdmin}
  <div class="form-card" bind:this={formEl}>
    <div class="form-card__header">
      <h3 class="form-card__title">{mode === 'add' ? 'Nueva categoría' : 'Editar categoría'}</h3>
    </div>

    {#if errorMsg}
      <div class="form-error">{errorMsg}</div>
    {/if}

    <div class="form-grid">
      <div class="qz-field">
        <label class="qz-label" for="c-nombre">Nombre *</label>
        <input id="c-nombre" class="qz-input" bind:value={form.nombre} placeholder="Nombre de la categoría" />
      </div>

      <div class="qz-field">
        <label class="qz-label" for="c-desc">Descripción</label>
        <input id="c-desc" class="qz-input" bind:value={form.descripcion} placeholder="Descripción breve" />
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
          <Icon path={IC.plus} size={13} /> {saving ? 'Agregando…' : 'Agregar categoría'}
        </button>
      {/if}
    </div>
  </div>
{/if}

<div class="section-header">
  <h2 class="page-title">Categorías</h2>
</div>

<div class="filtros-bar">
  <input class="qz-input filtro-busqueda" placeholder="Buscar por nombre…"
    value={$filtrosCategorias.busqueda} on:input={onBusqueda} />
  {#if hayFiltros}
    <button class="btn btn-sm btn-ghost" on:click={() => filtrosCategorias.reset()}>Limpiar</button>
  {/if}
  <span class="filtro-count">{categoriasFiltradas.length} de {categorias.length}</span>
</div>

{#if loading}
  <div class="loading-msg">Cargando categorías…</div>
{:else}
  <div class="qz-table-wrap">
    <table class="qz-table">
      <thead>
        <tr>
          <th>Nombre</th>
          <th>Descripción</th>
          {#if isAdmin}<th>Acciones</th>{/if}
        </tr>
      </thead>
      <tbody>
        {#if categoriasFiltradas.length === 0}
          <tr class="empty-row"><td colspan={isAdmin ? 3 : 2}>{hayFiltros ? 'Sin coincidencias' : 'Sin categorías registradas'}</td></tr>
        {:else}
          {#each categoriasFiltradas as c}
            <tr class:row-selected={form.id === c.id && mode === 'edit'}>
              <td><span class="cell-main">{c.nombre}</span></td>
              <td><span class="cell-sub">{c.descripcion}</span></td>
              {#if isAdmin}
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
  .section-header { margin-bottom:14px; }
  .page-title { font-size:20px; font-weight:700; color:#111827; margin:0; }
  .loading-msg { color:#9CA3AF; font-size:14px; padding:20px 0; }
  .cell-main { font-weight:500; color:#111827; }
  .cell-sub { font-size:12px; color:#6B7280; }
  .row-actions { display:flex; gap:6px; }
  .row-selected td { background:#F5F3FF; }
</style>
