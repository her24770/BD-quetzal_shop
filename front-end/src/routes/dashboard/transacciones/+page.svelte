<script lang="ts">
  import { onMount } from 'svelte';
  import Icon from '$lib/components/Icon.svelte';
  import { IC } from '$lib/icons';
  import { auth } from '$lib/stores/auth';
  import { requirePermisoAny } from '$lib/guards';
  import { permisos } from '$lib/stores/permisos';
  import { type Producto, productosApi } from '$lib/api/productos';
  import { type Cliente, clientesApi } from '$lib/api/clientes';
  import { type Proveedor, proveedoresApi } from '$lib/api/proveedores';
  import { type MetodoPago, ventasApi } from '$lib/api/ventas';
  import { comprasApi } from '$lib/api/compras';

  let productos:   Producto[]   = [];
  let clientes:    Cliente[]    = [];
  let proveedores: Proveedor[]  = [];
  let metodos:     MetodoPago[] = [];
  let loading = true;

  $: token      = $auth.token ?? '';
  $: canVentas  = ($permisos['ventas']  ?? []).includes('INSERT');
  $: canCompras = ($permisos['compras'] ?? []).includes('INSERT');

  let activeTab: 'ventas' | 'compras' = 'ventas';
  $: if (!canVentas && canCompras) activeTab = 'compras';

  // ─── formulario ventas ───────────────────────────────
  let vForm = { cliente_id: '', metodo_pago_id: '', descuento: '0' };
  let vItems: { producto_id: string; cantidad: string }[] = [{ producto_id: '', cantidad: '' }];
  let vError = '';
  let vSaving = false;

  function addVItem() { vItems = [...vItems, { producto_id: '', cantidad: '' }]; }
  function removeVItem(i: number) {
    if (vItems.length === 1) return;
    vItems = vItems.filter((_, idx) => idx !== i);
  }

  async function submitVenta() {
    if (!vForm.cliente_id || !vForm.metodo_pago_id || vItems.some(i => !i.producto_id || !i.cantidad)) {
      vError = 'Completa todos los campos y agrega al menos un producto'; return;
    }
    vSaving = true; vError = '';
    try {
      await ventasApi.create(token, {
        cliente_id:     parseInt(vForm.cliente_id),
        metodo_pago_id: parseInt(vForm.metodo_pago_id),
        descuento:      parseFloat(vForm.descuento) || 0,
        items: vItems.map(i => ({ producto_id: parseInt(i.producto_id), cantidad: parseInt(i.cantidad) })),
      });
      vForm  = { cliente_id: String(clientes[0]?.id ?? ''), metodo_pago_id: String(metodos[0]?.id ?? ''), descuento: '0' };
      vItems = [{ producto_id: String(productos[0]?.id ?? ''), cantidad: '' }];
      await reloadProductos();
    } catch (e: any) {
      vError = e.message;
    } finally { vSaving = false; }
  }

  // ─── formulario compras ──────────────────────────────
  let cForm = { numero_factura: '' };
  let cItems: { producto_id: string; proveedor_id: string; cantidad: string; precio_costo: string }[] = [
    { producto_id: '', proveedor_id: '', cantidad: '', precio_costo: '' },
  ];
  let cError = '';
  let cSaving = false;

  function addCItem() { cItems = [...cItems, { producto_id: '', proveedor_id: '', cantidad: '', precio_costo: '' }]; }
  function removeCItem(i: number) {
    if (cItems.length === 1) return;
    cItems = cItems.filter((_, idx) => idx !== i);
  }

  async function submitCompra() {
    if (!cForm.numero_factura || cItems.some(i => !i.producto_id || !i.proveedor_id || !i.cantidad || !i.precio_costo)) {
      cError = 'Completa todos los campos y agrega al menos un producto'; return;
    }
    cSaving = true; cError = '';
    try {
      await comprasApi.create(token, {
        numero_factura: cForm.numero_factura,
        items: cItems.map(i => ({
          producto_id:  parseInt(i.producto_id),
          proveedor_id: parseInt(i.proveedor_id),
          cantidad:     parseInt(i.cantidad),
          precio_costo: parseFloat(i.precio_costo),
        })),
      });
      cForm  = { numero_factura: '' };
      cItems = [{ producto_id: String(productos[0]?.id ?? ''), proveedor_id: String(proveedores[0]?.id ?? ''), cantidad: '', precio_costo: '' }];
      await reloadProductos();
    } catch (e: any) {
      cError = e.message;
    } finally { cSaving = false; }
  }

  async function reloadProductos() {
    productos = await productosApi.getAll(token);
  }

  onMount(async () => {
    if (!requirePermisoAny([['ventas', 'INSERT'], ['compras', 'INSERT']])) return;
    const calls: Promise<void>[] = [reloadProductos()];
    if (canVentas) {
      calls.push(
        clientesApi.getAll(token).then(d => { clientes = d; }),
        ventasApi.getMetodos(token).then(d => { metodos = d; }),
      );
    }
    if (canCompras) {
      calls.push(proveedoresApi.getAll(token).then(d => { proveedores = d; }));
    }
    await Promise.all(calls);

    if (clientes.length)    vForm.cliente_id       = String(clientes[0].id);
    if (metodos.length)     vForm.metodo_pago_id   = String(metodos[0].id);
    if (productos.length)   vItems[0].producto_id  = String(productos[0].id);
    if (proveedores.length) cItems[0].proveedor_id = String(proveedores[0].id);

    loading = false;
  });
</script>

<svelte:head><title>Transacciones — QuetzalShop</title></svelte:head>

<div class="page-header">
  <h2 class="page-title">Transacciones</h2>
  {#if canVentas && canCompras}
    <div class="tab-toggle">
      <button class="tab-btn" class:active={activeTab === 'ventas'}  on:click={() => activeTab = 'ventas'}>
        <Icon path={IC.cart} size={13} /> Ventas
      </button>
      <button class="tab-btn" class:active={activeTab === 'compras'} on:click={() => activeTab = 'compras'}>
        <Icon path={IC.pkg}  size={13} /> Compras
      </button>
    </div>
  {:else}
    <span class="tab-label">{canVentas ? 'Ventas' : 'Compras'}</span>
  {/if}
</div>

{#if loading}
  <div class="loading-msg">Cargando…</div>
{:else}

{#if activeTab === 'ventas' && canVentas}
  <div class="form-card">
    <h3 class="form-card__title">Nueva venta</h3>
    {#if vError}<div class="form-error">{vError}</div>{/if}

    <div class="form-grid">
      <div class="qz-field">
        <label class="qz-label" for="v-cliente">Cliente *</label>
        <select id="v-cliente" class="qz-input" bind:value={vForm.cliente_id}>
          {#each clientes as c}
            <option value={String(c.id)}>{c.nombre} — {c.nit}</option>
          {/each}
        </select>
      </div>
      <div class="qz-field">
        <label class="qz-label" for="v-metodo">Método de pago *</label>
        <select id="v-metodo" class="qz-input" bind:value={vForm.metodo_pago_id}>
          {#each metodos as m}
            <option value={String(m.id)}>{m.metodo}</option>
          {/each}
        </select>
      </div>
      <div class="qz-field">
        <label class="qz-label" for="v-desc">Descuento (Q)</label>
        <input id="v-desc" type="number" min="0" step="0.01" class="qz-input" bind:value={vForm.descuento} />
      </div>
    </div>

    <div class="items-section">
      <div class="items-header">
        <span class="items-title">Productos</span>
        <button class="btn btn-sm btn-ghost" on:click={addVItem}>
          <Icon path={IC.plus} size={12} /> Agregar fila
        </button>
      </div>
      <div class="items-grid items-grid--venta">
        <span class="col-label">Producto</span>
        <span class="col-label">Stock disp.</span>
        <span class="col-label">Cantidad</span>
        <span class="col-label"></span>
      </div>
      {#each vItems as item, i}
        <div class="items-grid items-grid--venta">
          <select class="qz-input" bind:value={item.producto_id}>
            {#each productos as p}
              <option value={String(p.id)}>{p.nombre}</option>
            {/each}
          </select>
          <span class="stock-disp">{productos.find(p => String(p.id) === item.producto_id)?.stock ?? '—'}</span>
          <input type="number" min="1" class="qz-input" bind:value={item.cantidad} placeholder="0" />
          <button class="btn btn-sm btn-ghost remove-btn" on:click={() => removeVItem(i)} disabled={vItems.length === 1}>
            <Icon path={IC.x} size={12} />
          </button>
        </div>
      {/each}
    </div>

    <div class="form-actions">
      <button class="btn btn-md btn-purple" on:click={submitVenta} disabled={vSaving}>
        <Icon path={IC.check} size={13} /> {vSaving ? 'Registrando…' : 'Registrar venta'}
      </button>
    </div>
  </div>

{:else if activeTab === 'compras' && canCompras}
  <div class="form-card">
    <h3 class="form-card__title">Nueva compra</h3>
    {#if cError}<div class="form-error">{cError}</div>{/if}

    <div class="form-grid">
      <div class="qz-field span-2">
        <label class="qz-label" for="c-factura">Número de factura *</label>
        <input id="c-factura" class="qz-input" bind:value={cForm.numero_factura} placeholder="FAC-2024-001" />
      </div>
    </div>

    <div class="items-section">
      <div class="items-header">
        <span class="items-title">Productos recibidos</span>
        <button class="btn btn-sm btn-ghost" on:click={addCItem}>
          <Icon path={IC.plus} size={12} /> Agregar fila
        </button>
      </div>
      <div class="items-grid items-grid--compra">
        <span class="col-label">Producto</span>
        <span class="col-label">Proveedor</span>
        <span class="col-label">Cantidad</span>
        <span class="col-label">Precio costo (Q)</span>
        <span class="col-label"></span>
      </div>
      {#each cItems as item, i}
        <div class="items-grid items-grid--compra">
          <select class="qz-input" bind:value={item.producto_id}>
            {#each productos as p}
              <option value={String(p.id)}>{p.nombre}</option>
            {/each}
          </select>
          <select class="qz-input" bind:value={item.proveedor_id}>
            {#each proveedores as p}
              <option value={String(p.id)}>{p.nombre}</option>
            {/each}
          </select>
          <input type="number" min="1" class="qz-input" bind:value={item.cantidad} placeholder="0" />
          <input type="number" min="0" step="0.01" class="qz-input" bind:value={item.precio_costo} placeholder="0.00" />
          <button class="btn btn-sm btn-ghost remove-btn" on:click={() => removeCItem(i)} disabled={cItems.length === 1}>
            <Icon path={IC.x} size={12} />
          </button>
        </div>
      {/each}
    </div>

    <div class="form-actions">
      <button class="btn btn-md btn-blue" on:click={submitCompra} disabled={cSaving}>
        <Icon path={IC.check} size={13} /> {cSaving ? 'Registrando…' : 'Registrar compra'}
      </button>
    </div>
  </div>
{/if}

{/if}

<style>
  .form-card        { background:var(--surface); border:1px solid var(--border); border-radius:10px; padding:20px 24px; margin-bottom:20px; }
  .form-card__title { font-size:15px; font-weight:600; color:var(--txt); margin:0 0 16px; }

  .items-section { margin-top:18px; }
  .items-header  { display:flex; align-items:center; justify-content:space-between; margin-bottom:8px; padding-bottom:8px; border-bottom:1px solid var(--border); }
  .items-title   { font-size:13px; font-weight:600; color:var(--txt-2); }
  .items-grid    { display:grid; gap:8px; align-items:center; margin-bottom:8px; }
  .items-grid--venta  { grid-template-columns: 3fr 1fr 1fr auto; }
  .items-grid--compra { grid-template-columns: 2fr 2fr 1fr 1fr auto; }
  .col-label  { font-size:11px; font-weight:600; color:var(--txt-4); text-transform:uppercase; letter-spacing:.04em; }
  .stock-disp { font-size:13px; font-weight:600; color:var(--txt-2); text-align:center; }
  .remove-btn { padding:4px 8px !important; color:var(--txt-4); }

  @media (max-width: 600px) {
    .items-grid--venta  { grid-template-columns: 1fr 1fr auto; }
    .items-grid--compra { grid-template-columns: 1fr 1fr auto; }
  }
</style>
