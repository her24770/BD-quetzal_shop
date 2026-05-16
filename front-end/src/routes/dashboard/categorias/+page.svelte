<script lang="ts">
  import { onMount } from 'svelte';
  import Icon from '$lib/components/Icon.svelte';
  import Modal from '$lib/components/Modal.svelte';
  import { IC } from '$lib/icons';
  import { auth } from '$lib/stores/auth';
  import { apiFetch } from '$lib/api';
  import { filtrosCategorias } from '$lib/stores/filtros';
  import { requireRole } from '$lib/guards';

  interface Categoria { id: number; nombre: string; descripcion: string; }

  let categorias: Categoria[] = [];
  let loading = true;
  let errorMsg = '';
  let pageError = '';
  let saving = false;
  let modalOpen = false;

  type Mode = 'add' | 'edit';
  let mode: Mode = 'add';
  let form = emptyForm();

  function emptyForm() { return { id: 0, nombre: '', descripcion: '' }; }

  $: rolId   = $auth.user?.rol_id ?? 0;
  $: isAdmin = rolId === 1;
  $: token   = $auth.token ?? '';

  onMount(async () => {
    if (!requireRole([1, 3, 4])) return;
    const r = await apiFetch('/categorias', token);
    if (r.ok) categorias = await r.json();
    else pageError = 'Error al cargar categorías';
    loading = false;
  });

  async function reload() {
    const r = await apiFetch('/categorias', token);
    if (r.ok) categorias = await r.json();
  }

  function openAdd() {
    form = emptyForm();
    mode = 'add';
    errorMsg = '';
    modalOpen = true;
  }

  function startEdit(c: Categoria) {
    form = { id: c.id, nombre: c.nombre, descripcion: c.descripcion };
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
        closeModal();
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
    pageError = '';
    const res = await apiFetch(`/categorias/${id}`, token, { method: 'DELETE' });
    if (res.ok) {
      categorias = categorias.filter(c => c.id !== id);
    } else {
      const e = await res.json().catch(() => ({}));
      pageError = e.detail ?? 'Error al eliminar';
    }
  }
</script>

<svelte:head><title>Categorías — QuetzalShop</title></svelte:head>

<Modal open={modalOpen} title={mode === 'add' ? 'Nueva categoría' : 'Editar categoría'} on:close={closeModal}>
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
    <button class="btn btn-md btn-ghost" on:click={closeModal}>Cancelar</button>
    {#if mode === 'edit'}
      <button class="btn btn-md btn-blue" on:click={saveForm} disabled={saving}>
        <Icon path={IC.check} size={13} /> {saving ? 'Guardando…' : 'Guardar cambios'}
      </button>
    {:else}
      <button class="btn btn-md btn-purple" on:click={saveForm} disabled={saving}>
        <Icon path={IC.plus} size={13} /> {saving ? 'Agregando…' : 'Agregar categoría'}
      </button>
    {/if}
  </div>
</Modal>

<div class="section-header">
  <h2 class="page-title">Categorías</h2>
  {#if isAdmin}
    <button class="btn btn-md btn-purple" on:click={openAdd}>
      <Icon path={IC.plus} size={13} /> Nueva categoría
    </button>
  {/if}
</div>

{#if pageError}
  <div class="page-error">{pageError}</div>
{/if}

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
            <tr>
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
