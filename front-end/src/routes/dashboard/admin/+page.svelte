<script lang="ts">
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import { auth } from '$lib/stores/auth';
  import { toast } from '$lib/stores/toast';
  import { type Rol, type PermisosMap, adminApi } from '$lib/api/admin';

  const TABLAS = ['categorias', 'productos', 'proveedores', 'clientes', 'empleados', 'ventas', 'compras'];
  const OPS    = ['SELECT', 'INSERT', 'UPDATE', 'DELETE'] as const;

  let roles: Rol[]       = [];
  let activeRolId        = 0;
  let permisosMap: PermisosMap = {};
  let loading            = true;
  let toggling: string | null = null;

  $: token = $auth.token ?? '';

  onMount(async () => {
    if ($auth.user?.rol_id !== 1) { goto('/dashboard'); return; }
    try {
      const all = await adminApi.getRoles(token);
      roles = all.filter(r => r.id !== 1);
      if (roles.length) {
        activeRolId = roles[0].id;
        permisosMap = await adminApi.getPermisos(token, activeRolId);
      }
    } catch (e: any) {
      toast.push(e.message, 'error');
    } finally {
      loading = false;
    }
  });

  async function changeTab(rolId: number) {
    if (activeRolId === rolId || toggling) return;
    activeRolId = rolId;
    loading = true;
    try {
      permisosMap = await adminApi.getPermisos(token, rolId);
    } catch (e: any) {
      toast.push(e.message, 'error');
    } finally {
      loading = false;
    }
  }

  async function toggle(tabla: string, op: string) {
    const key  = `${tabla}-${op}`;
    if (toggling) return;
    const tiene = (permisosMap[tabla] ?? []).includes(op);
    toggling = key;
    try {
      if (tiene) {
        await adminApi.revoke(token, activeRolId, tabla, op);
        permisosMap = { ...permisosMap, [tabla]: (permisosMap[tabla] ?? []).filter(p => p !== op) };
      } else {
        await adminApi.grant(token, activeRolId, tabla, op);
        permisosMap = { ...permisosMap, [tabla]: [...(permisosMap[tabla] ?? []), op] };
      }
    } catch (e: any) {
      toast.push(e.message, 'error');
    } finally {
      toggling = null;
    }
  }
</script>

<svelte:head><title>Permisos — QuetzalShop</title></svelte:head>

<div class="section-header">
  <h2 class="page-title">Gestión de permisos</h2>
</div>

<div class="tab-bar">
  {#each roles as rol}
    <button
      class="tab-btn"
      class:active={activeRolId === rol.id}
      on:click={() => changeTab(rol.id)}
      disabled={!!toggling}
    >
      {rol.nombre}
    </button>
  {/each}
</div>

{#if loading}
  <div class="loading-msg">Cargando permisos…</div>
{:else}
  <div class="matrix-wrap">
    <table class="matrix">
      <thead>
        <tr>
          <th class="col-tabla">Tabla</th>
          {#each OPS as op}
            <th class="col-op">{op}</th>
          {/each}
        </tr>
      </thead>
      <tbody>
        {#each TABLAS as tabla}
          <tr>
            <td class="cell-tabla">{tabla}</td>
            {#each OPS as op}
              {@const key   = `${tabla}-${op}`}
              {@const tiene = (permisosMap[tabla] ?? []).includes(op)}
              {@const busy  = toggling === key}
              <td class="cell-toggle">
                <button
                  class="toggle"
                  class:on={tiene}
                  class:busy
                  on:click={() => toggle(tabla, op)}
                  disabled={!!toggling}
                  title="{tiene ? 'Revocar' : 'Otorgar'} {op} en {tabla}"
                >
                  {#if busy}
                    <span class="spinner"></span>
                  {:else}
                    <span class="dot"></span>
                  {/if}
                </button>
              </td>
            {/each}
          </tr>
        {/each}
      </tbody>
    </table>
  </div>
{/if}

<style>
  .tab-bar {
    display: flex;
    gap: 4px;
    margin-bottom: 20px;
    flex-wrap: wrap;
  }

  .tab-btn {
    padding: 7px 16px;
    border-radius: 8px;
    border: 1px solid var(--border);
    background: var(--surface);
    color: var(--txt-2);
    font-size: 13px;
    font-weight: 500;
    cursor: pointer;
    transition: background .15s, color .15s, border-color .15s;
  }
  .tab-btn:hover:not(:disabled):not(.active) {
    background: var(--bg);
    color: var(--txt);
  }
  .tab-btn.active {
    background: #7C3AED;
    color: #fff;
    border-color: #7C3AED;
  }
  .tab-btn:disabled { opacity: .5; cursor: not-allowed; }

  .matrix-wrap {
    overflow-x: auto;
    border: 1px solid var(--border);
    border-radius: 10px;
  }

  .matrix {
    width: 100%;
    border-collapse: collapse;
    font-size: 13px;
  }

  .matrix thead th {
    padding: 10px 16px;
    background: var(--surface);
    color: var(--txt-4);
    font-size: 11px;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: .05em;
    text-align: center;
    border-bottom: 1px solid var(--border);
  }
  .matrix thead .col-tabla { text-align: left; min-width: 140px; }

  .matrix tbody tr:not(:last-child) td {
    border-bottom: 1px solid var(--border);
  }
  .matrix tbody tr:hover { background: var(--bg); }

  .cell-tabla {
    padding: 12px 16px;
    font-weight: 500;
    color: var(--txt);
  }

  .cell-toggle {
    padding: 8px;
    text-align: center;
  }

  .toggle {
    width: 36px;
    height: 36px;
    border-radius: 8px;
    border: 1.5px solid var(--border);
    background: var(--bg);
    cursor: pointer;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    transition: background .15s, border-color .15s;
  }
  .toggle:hover:not(:disabled) { border-color: #7C3AED; }
  .toggle.on {
    background: #7C3AED;
    border-color: #7C3AED;
  }
  .toggle:disabled { cursor: not-allowed; opacity: .6; }

  .dot {
    width: 10px;
    height: 10px;
    border-radius: 50%;
    background: var(--txt-4);
    transition: background .15s;
  }
  .toggle.on .dot { background: #fff; }

  .spinner {
    width: 12px;
    height: 12px;
    border: 2px solid rgba(255,255,255,.3);
    border-top-color: #fff;
    border-radius: 50%;
    animation: spin .6s linear infinite;
  }
  .toggle:not(.on) .spinner {
    border-color: rgba(0,0,0,.15);
    border-top-color: #7C3AED;
  }

  @keyframes spin { to { transform: rotate(360deg); } }
</style>
