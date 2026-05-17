<script lang="ts">
  import { onMount } from 'svelte';
  import Icon from '$lib/components/Icon.svelte';
  import Modal from '$lib/components/Modal.svelte';
  import DataTable from '$lib/components/DataTable.svelte';
  import FilterBar from '$lib/components/FilterBar.svelte';
  import { IC } from '$lib/icons';
  import { auth } from '$lib/stores/auth';
  import { exportCsv } from '$lib/csv';
  import { filtrosProducto } from '$lib/stores/filtros';
  import { requirePermiso } from '$lib/guards';
  import { permisos } from '$lib/stores/permisos';
  import { formatCurrency, stockStatus } from '$lib/utils';
  import { type Producto, productosApi } from '$lib/api/productos';
  import { type Categoria, categoriasApi } from '$lib/api/categorias';
  import { toast } from '$lib/stores/toast';

  let productos:  Producto[]  = [];
  let categorias: Categoria[] = [];
  let loading   = true;
  let errorMsg  = '';
  let saving    = false;
  let modalOpen = false;

  type Mode = 'add' | 'edit';
  let mode: Mode = 'add';
  let form = emptyForm();

  function emptyForm() {
    return { id: 0, nombre: '', descripcion: '', precio: '', stock: '', stock_minimo: '', categoria_id: '' };
  }

  $: token     = $auth.token ?? '';
  $: canCreate = ($permisos['productos'] ?? []).includes('INSERT');
  $: canEdit   = ($permisos['productos'] ?? []).includes('UPDATE');
  $: canDelete = ($permisos['productos'] ?? []).includes('DELETE');

  $: productosFiltrados = productos.filter(p => {
    const st = stockStatus(p.stock, p.stock_minimo);
    const matchBusqueda  = !$filtrosProducto.busqueda    || p.nombre.toLowerCase().includes($filtrosProducto.busqueda.toLowerCase());
    const matchCategoria = !$filtrosProducto.categoria_id || p.categoria_id === Number($filtrosProducto.categoria_id);
    const matchStock     = $filtrosProducto.stock_status === 'todos' || st === $filtrosProducto.stock_status;
    return matchBusqueda && matchCategoria && matchStock;
  });
  $: hayFiltros = $filtrosProducto.busqueda !== '' || $filtrosProducto.categoria_id !== '' || $filtrosProducto.stock_status !== 'todos';

  onMount(async () => {
    if (!requirePermiso('productos')) return;
    try {
      [productos, categorias] = await Promise.all([
        productosApi.getAll(token),
        categoriasApi.getAll(token),
      ]);
      if (categorias.length) form.categoria_id = String(categorias[0].id);
    } catch (e: any) {
      toast.push(e.message, 'error');
    } finally {
      loading = false;
    }
  });

  function openAdd() {
    form = emptyForm();
    if (categorias.length) form.categoria_id = String(categorias[0].id);
    mode = 'add'; errorMsg = ''; modalOpen = true;
  }

  function startEdit(p: Producto) {
    form = { id: p.id, nombre: p.nombre, descripcion: p.descripcion,
             precio: String(p.precio), stock: String(p.stock),
             stock_minimo: String(p.stock_minimo), categoria_id: String(p.categoria_id) };
    mode = 'edit'; errorMsg = ''; modalOpen = true;
  }

  function closeModal() {
    modalOpen = false; form = emptyForm();
    if (categorias.length) form.categoria_id = String(categorias[0].id);
    mode = 'add'; errorMsg = '';
  }

  async function saveForm() {
    if (!form.nombre || !form.precio || !form.stock || !form.stock_minimo || !form.categoria_id) {
      errorMsg = 'Completa todos los campos obligatorios'; return;
    }
    saving = true; errorMsg = '';
    const data = {
      nombre:       form.nombre,
      descripcion:  form.descripcion,
      precio:       parseFloat(form.precio),
      stock:        parseInt(form.stock),
      stock_minimo: parseInt(form.stock_minimo),
      categoria_id: parseInt(form.categoria_id),
    };
    try {
      if (mode === 'edit') {
        await productosApi.update(token, form.id, data);
      } else {
        await productosApi.create(token, data);
      }
      productos = await productosApi.getAll(token);
      closeModal();
      toast.push(mode === 'edit' ? 'Producto actualizado' : 'Producto creado', 'success');
    } catch (e: any) {
      errorMsg = e.message;
    } finally {
      saving = false;
    }
  }

  async function deleteItem(id: number) {
    try {
      await productosApi.delete(token, id);
      productos = productos.filter(p => p.id !== id);
      toast.push('Producto eliminado', 'success');
    } catch (e: any) {
      toast.push(e.message, 'error');
    }
  }

  type StockStatus = 'todos' | 'ok' | 'bajo' | 'agotado';
  function onStockChange(e: Event) {
    filtrosProducto.set({ stock_status: (e.currentTarget as HTMLSelectElement).value as StockStatus });
  }

  function exportarCSV() {
    exportCsv('productos.csv',
      ['ID', 'Nombre', 'Descripcion', 'Categoria', 'Precio', 'Stock', 'Stock Minimo'],
      productosFiltrados.map(p => [p.id, p.nombre, p.descripcion, p.categoria, p.precio, p.stock, p.stock_minimo])
    );
  }
</script>

<svelte:head><title>Productos — QuetzalShop</title></svelte:head>

<Modal open={modalOpen} title={mode === 'add' ? 'Nuevo producto' : 'Editar producto'} on:close={closeModal}>
  {#if errorMsg}<div class="form-error">{errorMsg}</div>{/if}

  <div class="form-grid">
    <div class="qz-field">
      <label class="qz-label" for="p-nombre">Nombre *</label>
      <input id="p-nombre" class="qz-input" bind:value={form.nombre} placeholder="Nombre del producto" />
    </div>
    <div class="qz-field">
      <label class="qz-label" for="p-cat">Categoría *</label>
      <select id="p-cat" class="qz-input" bind:value={form.categoria_id}>
        {#each categorias as c}
          <option value={String(c.id)}>{c.nombre}</option>
        {/each}
      </select>
    </div>
    <div class="qz-field span-2">
      <label class="qz-label" for="p-desc">Descripción</label>
      <textarea id="p-desc" class="qz-input" bind:value={form.descripcion} rows={2} placeholder="Breve descripción…" style="resize:vertical"></textarea>
    </div>
    <div class="qz-field">
      <label class="qz-label" for="p-precio">Precio (Q) *</label>
      <input id="p-precio" type="number" min="0" step="0.01" class="qz-input" bind:value={form.precio} />
    </div>
    <div class="qz-field">
      <label class="qz-label" for="p-stock">Stock actual *</label>
      <input id="p-stock" type="number" min="0" class="qz-input" bind:value={form.stock} />
    </div>
    <div class="qz-field">
      <label class="qz-label" for="p-stock-min">Stock mínimo *</label>
      <input id="p-stock-min" type="number" min="0" class="qz-input" bind:value={form.stock_minimo} />
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
        <Icon path={IC.plus} size={13} /> {saving ? 'Agregando…' : 'Agregar producto'}
      </button>
    {/if}
  </div>
</Modal>

<div class="section-header">
  <h2 class="page-title">Productos</h2>
  <div class="header-actions">
    {#if canCreate}
      <button class="btn btn-md btn-purple" on:click={openAdd}>
        <Icon path={IC.plus} size={13} /> Nuevo producto
      </button>
    {/if}
    <button class="btn btn-sm btn-ghost" on:click={exportarCSV} disabled={productosFiltrados.length === 0}>
      <Icon path={IC.down} size={13} /> Exportar CSV
    </button>
  </div>
</div>


<FilterBar
  value={$filtrosProducto.busqueda}
  placeholder="Buscar por nombre…"
  total={productos.length}
  filtered={productosFiltrados.length}
  hasActive={hayFiltros}
  on:search={e => filtrosProducto.set({ busqueda: e.detail })}
  on:clear={() => filtrosProducto.reset()}
>
  <select class="qz-input filtro-select" value={$filtrosProducto.categoria_id}
    on:change={e => filtrosProducto.set({ categoria_id: e.currentTarget.value })}>
    <option value="">Todas las categorías</option>
    {#each categorias as c}
      <option value={String(c.id)}>{c.nombre}</option>
    {/each}
  </select>
  <select class="qz-input filtro-select" value={$filtrosProducto.stock_status}
    on:change={onStockChange}>
    <option value="todos">Todo el stock</option>
    <option value="ok">Stock OK</option>
    <option value="bajo">Stock bajo</option>
    <option value="agotado">Agotado</option>
  </select>
</FilterBar>

{#if loading}
  <div class="loading-msg">Cargando productos…</div>
{:else}
  <DataTable
    rows={productosFiltrados}
    {canEdit}
    {canDelete}
    colspan={5}
    emptyMsg={hayFiltros ? 'Sin productos que coincidan con los filtros' : 'Sin productos registrados'}
    on:edit={e => startEdit(e.detail)}
    on:delete={e => deleteItem(e.detail)}
  >
    <svelte:fragment slot="headers">
      <th>Nombre</th><th>Descripción</th><th>Categoría</th><th>Precio</th><th>Stock</th>
    </svelte:fragment>
    <svelte:fragment slot="row" let:row>
      {@const st = stockStatus(row.stock, row.stock_minimo)}
      <td><span class="cell-main">{row.nombre}</span></td>
      <td><span class="cell-sub">{row.descripcion}</span></td>
      <td>{row.categoria}</td>
      <td><span class="cell-num">{formatCurrency(row.precio)}</span></td>
      <td>
        <div class="stock-cell">
          <span class="cell-num" style="color:{st === 'ok' ? '#374151' : st === 'bajo' ? '#D97706' : '#DC2626'}">{row.stock}</span>
          {#if st === 'agotado'}<span class="badge badge-red">Agotado</span>
          {:else if st === 'bajo'}<span class="badge badge-amber">Stock bajo</span>
          {/if}
        </div>
      </td>
    </svelte:fragment>
  </DataTable>
{/if}

<style>
  .stock-cell { display: flex; align-items: center; gap: 6px; }
</style>
