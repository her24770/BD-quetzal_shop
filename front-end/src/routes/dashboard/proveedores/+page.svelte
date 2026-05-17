<script lang="ts">
  import { onMount } from 'svelte';
  import Icon from '$lib/components/Icon.svelte';
  import Modal from '$lib/components/Modal.svelte';
  import DataTable from '$lib/components/DataTable.svelte';
  import FilterBar from '$lib/components/FilterBar.svelte';
  import { IC } from '$lib/icons';
  import { auth } from '$lib/stores/auth';
  import { exportCsv } from '$lib/csv';
  import { filtrosProveedores } from '$lib/stores/filtros';
  import { requirePermiso } from '$lib/guards';
  import { permisos } from '$lib/stores/permisos';
  import { type Proveedor, type ProveedorForm, proveedoresApi } from '$lib/api/proveedores';
  import { toast } from '$lib/stores/toast';

  let proveedores: Proveedor[] = [];
  let loading   = true;
  let errorMsg  = '';
  let saving    = false;
  let modalOpen = false;

  type Mode = 'add' | 'edit';
  let mode: Mode = 'add';
  let form = emptyForm();

  function emptyForm(): ProveedorForm & { id: number } { return { id: 0, nombre: '', telefono: '', email: '', direccion: '' }; }

  $: token     = $auth.token ?? '';
  $: canCreate = ($permisos['proveedores'] ?? []).includes('INSERT');
  $: canEdit   = ($permisos['proveedores'] ?? []).includes('UPDATE');
  $: canDelete = ($permisos['proveedores'] ?? []).includes('DELETE');

  $: proveedoresFiltrados = proveedores.filter(p => {
    const q = $filtrosProveedores.busqueda.toLowerCase();
    return !q || p.nombre.toLowerCase().includes(q) || p.email.toLowerCase().includes(q);
  });
  $: hayFiltros = $filtrosProveedores.busqueda !== '';

  onMount(async () => {
    if (!requirePermiso('proveedores')) return;
    try {
      proveedores = await proveedoresApi.getAll(token);
    } catch (e: any) {
      toast.push(e.message, 'error');
    } finally {
      loading = false;
    }
  });

  function openAdd() { form = emptyForm(); mode = 'add'; errorMsg = ''; modalOpen = true; }

  function startEdit(p: Proveedor) {
    form = { id: p.id, nombre: p.nombre, telefono: p.telefono, email: p.email, direccion: p.direccion };
    mode = 'edit'; errorMsg = ''; modalOpen = true;
  }

  function closeModal() { modalOpen = false; form = emptyForm(); mode = 'add'; errorMsg = ''; }

  async function saveForm() {
    if (!form.nombre || !form.telefono || !form.email) { errorMsg = 'Completa los campos obligatorios'; return; }
    saving = true; errorMsg = '';
    try {
      if (mode === 'edit') {
        await proveedoresApi.update(token, form.id, { nombre: form.nombre, telefono: form.telefono, email: form.email, direccion: form.direccion });
      } else {
        await proveedoresApi.create(token, { nombre: form.nombre, telefono: form.telefono, email: form.email, direccion: form.direccion });
      }
      proveedores = await proveedoresApi.getAll(token);
      closeModal();
      toast.push(mode === 'edit' ? 'Proveedor actualizado' : 'Proveedor creado', 'success');
    } catch (e: any) {
      errorMsg = e.message;
    } finally {
      saving = false;
    }
  }

  async function deleteItem(id: number) {
    try {
      await proveedoresApi.delete(token, id);
      proveedores = proveedores.filter(p => p.id !== id);
      toast.push('Proveedor eliminado', 'success');
    } catch (e: any) {
      toast.push(e.message, 'error');
    }
  }

  function exportarCSV() {
    exportCsv('proveedores.csv',
      ['ID', 'Nombre', 'Telefono', 'Email', 'Direccion'],
      proveedoresFiltrados.map(p => [p.id, p.nombre, p.telefono, p.email, p.direccion])
    );
  }
</script>

<svelte:head><title>Proveedores — QuetzalShop</title></svelte:head>

<Modal open={modalOpen} title={mode === 'add' ? 'Nuevo proveedor' : 'Editar proveedor'} on:close={closeModal}>
  {#if errorMsg}<div class="form-error">{errorMsg}</div>{/if}

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
    {#if canCreate}
      <button class="btn btn-md btn-purple" on:click={openAdd}>
        <Icon path={IC.plus} size={13} /> Nuevo proveedor
      </button>
    {/if}
    <button class="btn btn-sm btn-ghost" on:click={exportarCSV} disabled={proveedoresFiltrados.length === 0}>
      <Icon path={IC.down} size={13} /> Exportar CSV
    </button>
  </div>
</div>


<FilterBar
  value={$filtrosProveedores.busqueda}
  placeholder="Buscar por nombre o email…"
  total={proveedores.length}
  filtered={proveedoresFiltrados.length}
  hasActive={hayFiltros}
  on:search={e => filtrosProveedores.set({ busqueda: e.detail })}
  on:clear={() => filtrosProveedores.reset()}
/>

{#if loading}
  <div class="loading-msg">Cargando proveedores…</div>
{:else}
  <DataTable
    rows={proveedoresFiltrados}
    {canEdit}
    {canDelete}
    colspan={4}
    emptyMsg={hayFiltros ? 'Sin coincidencias' : 'Sin proveedores registrados'}
    on:edit={e => startEdit(e.detail)}
    on:delete={e => deleteItem(e.detail)}
  >
    <svelte:fragment slot="headers">
      <th>Nombre</th><th>Teléfono</th><th>Email</th><th>Dirección</th>
    </svelte:fragment>
    <svelte:fragment slot="row" let:row>
      <td><span class="cell-main">{row.nombre}</span></td>
      <td>{row.telefono}</td>
      <td><span class="cell-sub">{row.email}</span></td>
      <td><span class="cell-sub">{row.direccion}</span></td>
    </svelte:fragment>
  </DataTable>
{/if}
