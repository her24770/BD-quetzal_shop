<script lang="ts">
  import { onMount } from 'svelte';
  import Icon from '$lib/components/Icon.svelte';
  import Modal from '$lib/components/Modal.svelte';
  import { IC } from '$lib/icons';
  import { auth } from '$lib/stores/auth';
  import { filtrosProducto } from '$lib/stores/filtros';
  import { apiFetch } from '$lib/api';
  import { exportCsv } from '$lib/csv';
  import { requireRole } from '$lib/guards';

  interface Categoria { id: number; nombre: string; }
  interface Producto {
    id: number;
    nombre: string;
    descripcion: string;
    precio: number;
    stock: number;
    stock_minimo: number;
    categoria_id: number;
    categoria: string;
  }

  let productos: Producto[] = [];
  let categorias: Categoria[] = [];
  let loading = true;
  let errorMsg = '';
  let pageError = '';
  let saving = false;
  let modalOpen = false;

  type Mode = 'add' | 'edit';
  let mode: Mode = 'add';
  let form = emptyForm();

  function emptyForm() {
    return { id: 0, nombre: '', descripcion: '', precio: '', stock: '', stock_minimo: '', categoria_id: '' };
  }

  $: rolId    = $auth.user?.rol_id ?? 0;
  $: canEdit  = [1, 3].includes(rolId);
  $: token    = $auth.token ?? '';

  $: productosFiltrados = productos.filter(p => {
    const st = stockStatus(p);
    const matchBusqueda   = !$filtrosProducto.busqueda     || p.nombre.toLowerCase().includes($filtrosProducto.busqueda.toLowerCase());
    const matchCategoria  = !$filtrosProducto.categoria_id || p.categoria_id === Number($filtrosProducto.categoria_id);
    const matchStock      = $filtrosProducto.stock_status === 'todos' || st === $filtrosProducto.stock_status;
    return matchBusqueda && matchCategoria && matchStock;
  });

  $: hayFiltrosActivos = $filtrosProducto.busqueda !== '' ||
                         $filtrosProducto.categoria_id !== '' ||
                         $filtrosProducto.stock_status !== 'todos';

  onMount(async () => {
    if (!requireRole([1, 3, 4])) return;
    const [r1, r2] = await Promise.all([
      apiFetch('/productos',  token),
      apiFetch('/categorias', token),
    ]);
    if (r1.ok) productos  = await r1.json();
    if (r2.ok) categorias = await r2.json();
    if (categorias.length) form.categoria_id = String(categorias[0].id);
    loading = false;
  });

  async function reloadProductos() {
    const r = await apiFetch('/productos', token);
    if (r.ok) productos = await r.json();
  }

  function openAdd() {
    form = emptyForm();
    if (categorias.length) form.categoria_id = String(categorias[0].id);
    mode = 'add';
    errorMsg = '';
    modalOpen = true;
  }

  function startEdit(p: Producto) {
    form = {
      id:           p.id,
      nombre:       p.nombre,
      descripcion:  p.descripcion,
      precio:       String(p.precio),
      stock:        String(p.stock),
      stock_minimo: String(p.stock_minimo),
      categoria_id: String(p.categoria_id),
    };
    mode = 'edit';
    errorMsg = '';
    modalOpen = true;
  }

  function closeModal() {
    modalOpen = false;
    form = emptyForm();
    if (categorias.length) form.categoria_id = String(categorias[0].id);
    mode = 'add';
    errorMsg = '';
  }

  async function saveForm() {
    if (!form.nombre || !form.precio || !form.stock || !form.stock_minimo || !form.categoria_id) {
      errorMsg = 'Completa todos los campos obligatorios';
      return;
    }
    saving = true;
    errorMsg = '';
    const body = {
      nombre:       form.nombre,
      descripcion:  form.descripcion,
      precio:       parseFloat(form.precio),
      stock:        parseInt(form.stock),
      stock_minimo: parseInt(form.stock_minimo),
      categoria_id: parseInt(form.categoria_id),
    };
    try {
      const res = mode === 'edit'
        ? await apiFetch(`/productos/${form.id}`, token, { method: 'PATCH', body: JSON.stringify(body) })
        : await apiFetch('/productos',            token, { method: 'POST',  body: JSON.stringify(body) });
      if (!res.ok) {
        const e = await res.json().catch(() => ({}));
        errorMsg = e.detail ?? 'Error al guardar';
      } else {
        await reloadProductos();
        closeModal();
      }
    } finally {
      saving = false;
    }
  }

  async function deleteProducto(id: number) {
    pageError = '';
    const res = await apiFetch(`/productos/${id}`, token, { method: 'DELETE' });
    if (res.ok) {
      productos = productos.filter(p => p.id !== id);
    } else {
      const e = await res.json().catch(() => ({}));
      pageError = e.detail ?? 'Error al eliminar';
    }
  }

  function stockStatus(p: Producto) {
    if (p.stock === 0) return 'agotado';
    if (p.stock <= p.stock_minimo) return 'bajo';
    return 'ok';
  }

  const fmt = (n: number) => 'Q ' + n.toLocaleString('es-GT', { minimumFractionDigits: 2 });

  function exportarCSV() {
    exportCsv('productos.csv',
      ['ID', 'Nombre', 'Descripcion', 'Categoria', 'Precio', 'Stock', 'Stock Minimo'],
      productosFiltrados.map(p => [p.id, p.nombre, p.descripcion, p.categoria, p.precio, p.stock, p.stock_minimo])
    );
  }

  function onBusqueda(e: Event)    { filtrosProducto.setBusqueda((e.target as HTMLInputElement).value); }
  function onCategoria(e: Event)   { filtrosProducto.setCategoria((e.target as HTMLSelectElement).value); }
  function onStockStatus(e: Event) { filtrosProducto.setStockStatus((e.target as HTMLSelectElement).value as any); }
</script>

<svelte:head><title>Productos — QuetzalShop</title></svelte:head>

<!-- Modal formulario -->
<Modal open={modalOpen} title={mode === 'add' ? 'Nuevo producto' : 'Editar producto'} on:close={closeModal}>
  {#if errorMsg}
    <div class="form-error">{errorMsg}</div>
  {/if}

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
      <textarea id="p-desc" class="qz-input" bind:value={form.descripcion}
        rows={2} placeholder="Breve descripción…" style="resize:vertical"></textarea>
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
        <Icon path={IC.check} size={13} />
        {saving ? 'Guardando…' : 'Guardar cambios'}
      </button>
    {:else}
      <button class="btn btn-md btn-purple" on:click={saveForm} disabled={saving}>
        <Icon path={IC.plus} size={13} />
        {saving ? 'Agregando…' : 'Agregar producto'}
      </button>
    {/if}
  </div>
</Modal>

<!-- Encabezado -->
<div class="section-header">
  <h2 class="page-title">Productos</h2>
  <div class="header-actions">
    {#if canEdit}
      <button class="btn btn-md btn-purple" on:click={openAdd}>
        <Icon path={IC.plus} size={13} /> Nuevo producto
      </button>
    {/if}
    <button class="btn btn-sm btn-ghost" on:click={exportarCSV} disabled={productosFiltrados.length === 0}>
      <Icon path={IC.down} size={13} /> Exportar CSV
    </button>
  </div>
</div>

{#if pageError}
  <div class="page-error">{pageError}</div>
{/if}

<!-- Filtros -->
<div class="filtros-bar">
  <input
    class="qz-input filtro-busqueda"
    placeholder="Buscar por nombre…"
    value={$filtrosProducto.busqueda}
    on:input={onBusqueda}
  />
  <select class="qz-input filtro-select" value={$filtrosProducto.categoria_id} on:change={onCategoria}>
    <option value="">Todas las categorías</option>
    {#each categorias as c}
      <option value={String(c.id)}>{c.nombre}</option>
    {/each}
  </select>
  <select class="qz-input filtro-select" value={$filtrosProducto.stock_status} on:change={onStockStatus}>
    <option value="todos">Todo el stock</option>
    <option value="ok">Stock OK</option>
    <option value="bajo">Stock bajo</option>
    <option value="agotado">Agotado</option>
  </select>
  {#if hayFiltrosActivos}
    <button class="btn btn-sm btn-ghost" on:click={() => filtrosProducto.reset()}>Limpiar filtros</button>
  {/if}
  <span class="filtro-count">{productosFiltrados.length} de {productos.length}</span>
</div>

<!-- Tabla -->
{#if loading}
  <div class="loading-msg">Cargando productos…</div>
{:else}
  <div class="qz-table-wrap">
    <table class="qz-table">
      <thead>
        <tr>
          <th>Nombre</th>
          <th>Descripción</th>
          <th>Categoría</th>
          <th>Precio</th>
          <th>Stock</th>
          {#if canEdit}<th>Acciones</th>{/if}
        </tr>
      </thead>
      <tbody>
        {#if productosFiltrados.length === 0}
          <tr class="empty-row">
            <td colspan={canEdit ? 6 : 5}>
              {hayFiltrosActivos ? 'Sin productos que coincidan con los filtros' : 'Sin productos registrados'}
            </td>
          </tr>
        {:else}
          {#each productosFiltrados as p}
            {@const st = stockStatus(p)}
            <tr>
              <td><span class="cell-main">{p.nombre}</span></td>
              <td><span class="cell-sub">{p.descripcion}</span></td>
              <td>{p.categoria}</td>
              <td><span class="cell-num">{fmt(p.precio)}</span></td>
              <td>
                <div class="stock-cell">
                  <span class="cell-num" style="color:{st === 'ok' ? '#374151' : st === 'bajo' ? '#D97706' : '#DC2626'}">{p.stock}</span>
                  {#if st === 'agotado'}<span class="badge badge-red">Agotado</span>
                  {:else if st === 'bajo'}<span class="badge badge-amber">Stock bajo</span>
                  {/if}
                </div>
              </td>
              {#if canEdit}
                <td>
                  <div class="row-actions">
                    <button class="btn btn-sm btn-blue" on:click={() => startEdit(p)}>
                      <Icon path={IC.edit} size={11} /> Editar
                    </button>
                    <button class="btn btn-sm btn-danger" on:click={() => deleteProducto(p.id)}>
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
  .stock-cell { display:flex; align-items:center; gap:8px; }
</style>
