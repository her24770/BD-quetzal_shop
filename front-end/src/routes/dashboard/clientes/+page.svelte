<script lang="ts">
  import { onMount } from 'svelte';
  import Icon from '$lib/components/Icon.svelte';
  import Modal from '$lib/components/Modal.svelte';
  import DataTable from '$lib/components/DataTable.svelte';
  import FilterBar from '$lib/components/FilterBar.svelte';
  import { IC } from '$lib/icons';
  import { auth } from '$lib/stores/auth';
  import { exportCsv } from '$lib/csv';
  import { filtrosClientes } from '$lib/stores/filtros';
  import { requirePermiso } from '$lib/guards';
  import { permisos } from '$lib/stores/permisos';
  import { type Cliente, type ClienteForm, clientesApi } from '$lib/api/clientes';
  import { toast } from '$lib/stores/toast';

  let clientes: Cliente[] = [];
  let loading   = true;
  let errorMsg  = '';
  let saving    = false;
  let modalOpen = false;

  type Mode = 'add' | 'edit';
  let mode: Mode = 'add';
  let form = emptyForm();

  function emptyForm(): ClienteForm & { id: number } { return { id: 0, nombre: '', nit: '', telefono: '', direccion: '' }; }

  $: token     = $auth.token ?? '';
  $: canWrite  = ($permisos['clientes'] ?? []).includes('INSERT');
  $: canDelete = ($permisos['clientes'] ?? []).includes('DELETE');

  $: clientesFiltrados = clientes.filter(c => {
    const q = $filtrosClientes.busqueda.toLowerCase();
    return !q || c.nombre.toLowerCase().includes(q) || c.nit.toLowerCase().includes(q);
  });
  $: hayFiltros = $filtrosClientes.busqueda !== '';

  onMount(async () => {
    if (!requirePermiso('clientes')) return;
    try {
      clientes = await clientesApi.getAll(token);
    } catch (e: any) {
      toast.push(e.message, 'error');
    } finally {
      loading = false;
    }
  });

  function openAdd() { form = emptyForm(); mode = 'add'; errorMsg = ''; modalOpen = true; }

  function startEdit(c: Cliente) {
    form = { id: c.id, nombre: c.nombre, nit: c.nit, telefono: c.telefono, direccion: c.direccion };
    mode = 'edit'; errorMsg = ''; modalOpen = true;
  }

  function closeModal() { modalOpen = false; form = emptyForm(); mode = 'add'; errorMsg = ''; }

  async function saveForm() {
    if (!form.nombre || !form.nit) { errorMsg = 'Nombre y NIT son requeridos'; return; }
    saving = true; errorMsg = '';
    try {
      if (mode === 'edit') {
        await clientesApi.update(token, form.id, { nombre: form.nombre, nit: form.nit, telefono: form.telefono, direccion: form.direccion });
      } else {
        await clientesApi.create(token, { nombre: form.nombre, nit: form.nit, telefono: form.telefono, direccion: form.direccion });
      }
      clientes = await clientesApi.getAll(token);
      closeModal();
      toast.push(mode === 'edit' ? 'Cliente actualizado' : 'Cliente creado', 'success');
    } catch (e: any) {
      errorMsg = e.message;
    } finally {
      saving = false;
    }
  }

  async function deleteItem(id: number) {
    try {
      await clientesApi.delete(token, id);
      clientes = clientes.filter(c => c.id !== id);
      toast.push('Cliente eliminado', 'success');
    } catch (e: any) {
      toast.push(e.message, 'error');
    }
  }

  function exportarCSV() {
    exportCsv('clientes.csv',
      ['ID', 'Nombre', 'NIT', 'Telefono', 'Direccion'],
      clientesFiltrados.map(c => [c.id, c.nombre, c.nit, c.telefono, c.direccion])
    );
  }
</script>

<svelte:head><title>Clientes — QuetzalShop</title></svelte:head>

<Modal open={modalOpen} title={mode === 'add' ? 'Nuevo cliente' : 'Editar cliente'} on:close={closeModal}>
  {#if errorMsg}<div class="form-error">{errorMsg}</div>{/if}

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
    {#if canWrite}
      <button class="btn btn-md btn-purple" on:click={openAdd}>
        <Icon path={IC.plus} size={13} /> Nuevo cliente
      </button>
    {/if}
    <button class="btn btn-sm btn-ghost" on:click={exportarCSV} disabled={clientesFiltrados.length === 0}>
      <Icon path={IC.down} size={13} /> Exportar CSV
    </button>
  </div>
</div>


<FilterBar
  value={$filtrosClientes.busqueda}
  placeholder="Buscar por nombre o NIT…"
  total={clientes.length}
  filtered={clientesFiltrados.length}
  hasActive={hayFiltros}
  on:search={e => filtrosClientes.set({ busqueda: e.detail })}
  on:clear={() => filtrosClientes.reset()}
/>

{#if loading}
  <div class="loading-msg">Cargando clientes…</div>
{:else}
  <DataTable
    rows={clientesFiltrados}
    {canWrite}
    {canDelete}
    colspan={4}
    emptyMsg={hayFiltros ? 'Sin coincidencias' : 'Sin clientes registrados'}
    on:edit={e => startEdit(e.detail)}
    on:delete={e => deleteItem(e.detail)}
  >
    <svelte:fragment slot="headers">
      <th>Nombre</th><th>NIT</th><th>Teléfono</th><th>Dirección</th>
    </svelte:fragment>
    <svelte:fragment slot="row" let:row>
      <td><span class="cell-main">{row.nombre}</span></td>
      <td><span class="cell-mono">{row.nit}</span></td>
      <td>{row.telefono}</td>
      <td><span class="cell-sub">{row.direccion}</span></td>
    </svelte:fragment>
  </DataTable>
{/if}
