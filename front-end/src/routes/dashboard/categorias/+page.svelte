<script lang="ts">
  import { onMount } from 'svelte';
  import Icon from '$lib/components/Icon.svelte';
  import Modal from '$lib/components/Modal.svelte';
  import DataTable from '$lib/components/DataTable.svelte';
  import FilterBar from '$lib/components/FilterBar.svelte';
  import { IC } from '$lib/icons';
  import { auth } from '$lib/stores/auth';
  import { filtrosCategorias } from '$lib/stores/filtros';
  import { requirePermiso } from '$lib/guards';
  import { permisos } from '$lib/stores/permisos';
  import { type Categoria, type CategoriaForm, categoriasApi } from '$lib/api/categorias';
  import { toast } from '$lib/stores/toast';

  let categorias: Categoria[] = [];
  let loading   = true;
  let errorMsg  = '';
  let saving    = false;
  let modalOpen = false;

  type Mode = 'add' | 'edit';
  let mode: Mode = 'add';
  let form = emptyForm();

  function emptyForm(): CategoriaForm & { id: number } { return { id: 0, nombre: '', descripcion: '' }; }

  $: token     = $auth.token ?? '';
  $: canCreate = ($permisos['categorias'] ?? []).includes('INSERT');
  $: canEdit   = ($permisos['categorias'] ?? []).includes('UPDATE');
  $: canDelete = ($permisos['categorias'] ?? []).includes('DELETE');

  $: categoriasFiltradas = categorias.filter(c => {
    const q = $filtrosCategorias.busqueda.toLowerCase();
    return !q || c.nombre.toLowerCase().includes(q);
  });
  $: hayFiltros = $filtrosCategorias.busqueda !== '';

  onMount(async () => {
    if (!requirePermiso('categorias')) return;
    try {
      categorias = await categoriasApi.getAll(token);
    } catch (e: any) {
      toast.push(e.message, 'error');
    } finally {
      loading = false;
    }
  });

  function openAdd() { form = emptyForm(); mode = 'add'; errorMsg = ''; modalOpen = true; }

  function startEdit(c: Categoria) {
    form = { id: c.id, nombre: c.nombre, descripcion: c.descripcion };
    mode = 'edit'; errorMsg = ''; modalOpen = true;
  }

  function closeModal() { modalOpen = false; form = emptyForm(); mode = 'add'; errorMsg = ''; }

  async function saveForm() {
    if (!form.nombre) { errorMsg = 'El nombre es requerido'; return; }
    saving = true; errorMsg = '';
    try {
      if (mode === 'edit') {
        await categoriasApi.update(token, form.id, { nombre: form.nombre, descripcion: form.descripcion });
      } else {
        await categoriasApi.create(token, { nombre: form.nombre, descripcion: form.descripcion });
      }
      categorias = await categoriasApi.getAll(token);
      closeModal();
      toast.push(mode === 'edit' ? 'Categoría actualizada' : 'Categoría creada', 'success');
    } catch (e: any) {
      errorMsg = e.message;
    } finally {
      saving = false;
    }
  }

  async function deleteItem(id: number) {
    try {
      await categoriasApi.delete(token, id);
      categorias = categorias.filter(c => c.id !== id);
      toast.push('Categoría eliminada', 'success');
    } catch (e: any) {
      toast.push(e.message, 'error');
    }
  }
</script>

<svelte:head><title>Categorías — QuetzalShop</title></svelte:head>

<Modal open={modalOpen} title={mode === 'add' ? 'Nueva categoría' : 'Editar categoría'} on:close={closeModal}>
  {#if errorMsg}<div class="form-error">{errorMsg}</div>{/if}

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
  {#if canCreate}
    <button class="btn btn-md btn-purple" on:click={openAdd}>
      <Icon path={IC.plus} size={13} /> Nueva categoría
    </button>
  {/if}
</div>

<FilterBar
  value={$filtrosCategorias.busqueda}
  placeholder="Buscar por nombre…"
  total={categorias.length}
  filtered={categoriasFiltradas.length}
  hasActive={hayFiltros}
  on:search={e => filtrosCategorias.set({ busqueda: e.detail })}
  on:clear={() => filtrosCategorias.reset()}
/>

{#if loading}
  <div class="loading-msg">Cargando categorías…</div>
{:else}
  <DataTable
    rows={categoriasFiltradas}
    {canEdit}
    {canDelete}
    colspan={2}
    emptyMsg={hayFiltros ? 'Sin coincidencias' : 'Sin categorías registradas'}
    on:edit={e => startEdit(e.detail)}
    on:delete={e => deleteItem(e.detail)}
  >
    <svelte:fragment slot="headers">
      <th>Nombre</th>
      <th>Descripción</th>
    </svelte:fragment>
    <svelte:fragment slot="row" let:row>
      <td><span class="cell-main">{row.nombre}</span></td>
      <td><span class="cell-sub">{row.descripcion}</span></td>
    </svelte:fragment>
  </DataTable>
{/if}
