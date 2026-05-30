<script lang="ts">
  import { goto, afterNavigate } from '$app/navigation';
  import { onMount } from 'svelte';
  import { get } from 'svelte/store';
  import { page } from '$app/stores';
  import Navbar from '$lib/components/Navbar.svelte';
  import Sidebar from '$lib/components/Sidebar.svelte';
  import Toast from '$lib/components/Toast.svelte';
  import ConfirmModal from '$lib/components/ConfirmModal.svelte';
  import { auth } from '$lib/stores/auth';
  import { apiFetch } from '$lib/api';
  import { permisos } from '$lib/stores/permisos';

  let sidebarOpen = false;
  let permisosLoaded = false;

  // Mapa de rutas a los permisos necesarios para acceder
  const routeRules: Array<{ path: string; check?: [string, string][]; adminOnly?: boolean }> = [
    { path: '/dashboard/categorias',    check: [['categorias', 'SELECT']] },
    { path: '/dashboard/proveedores',   check: [['proveedores', 'SELECT']] },
    { path: '/dashboard/clientes',      check: [['clientes', 'SELECT']] },
    { path: '/dashboard/productos',     check: [['productos', 'SELECT']] },
    { path: '/dashboard/empleados',     check: [['empleados', 'SELECT']] },
    { path: '/dashboard/transacciones', check: [['ventas', 'INSERT'], ['compras', 'INSERT']] },
    { path: '/dashboard/historial',     check: [['ventas', 'SELECT'], ['compras', 'SELECT']] },
    { path: '/dashboard/ventas',        check: [['ventas', 'INSERT']] },
    { path: '/dashboard/compras',       check: [['compras', 'INSERT']] },
    { path: '/dashboard/admin',         adminOnly: true },
  ];

  function canAccess(pathname: string): boolean {
    if (pathname === '/dashboard/forbidden') return true;
    const rule = routeRules.find(r => pathname === r.path || pathname.startsWith(r.path + '/'));
    if (!rule) return true;
    if (rule.adminOnly) return $auth.user?.rol_id === 1;
    return rule.check!.some(([tabla, op]) => ($permisos[tabla] ?? []).includes(op));
  }

  function checkAccess(pathname: string) {
    if (!canAccess(pathname)) goto('/dashboard/forbidden');
  }

  function toggleSidebar() { sidebarOpen = !sidebarOpen; }
  function closeSidebar()  { sidebarOpen = false; }

  afterNavigate(({ to }) => {
    sidebarOpen = false;
    if (permisosLoaded && to?.url.pathname) checkAccess(to.url.pathname);
  });

  onMount(async () => {
    if (!$auth.token) {
      goto('/');
      return;
    }
    if (Object.keys(get(permisos)).length === 0) {
      const r = await apiFetch('/auth/me/permisos', $auth.token);
      if (r.ok) permisos.load(await r.json());
    }
    permisosLoaded = true;
    checkAccess($page.url.pathname);
  });
</script>

{#if $auth.token}
  <div class="shell">
    <Navbar on:toggleSidebar={toggleSidebar} />

    <div class="shell__body">
      <Sidebar open={sidebarOpen} />

      {#if sidebarOpen}
        <!-- svelte-ignore a11y-click-events-have-key-events a11y-no-static-element-interactions -->
        <div class="sidebar-backdrop" on:click={closeSidebar}></div>
      {/if}

      <main class="shell__main">
        <div class="shell__content">
          <slot />
        </div>
      </main>
    </div>
  </div>

  <Toast />
  <ConfirmModal />
{/if}

<style>
  .shell {
    display: flex;
    flex-direction: column;
    height: 100vh;
    overflow: hidden;
  }

  .shell__body {
    display: flex;
    flex: 1;
    overflow: hidden;
  }

  .shell__main {
    flex: 1;
    overflow-y: auto;
    background: var(--bg);
  }

  .shell__content {
    padding: 24px 28px;
    min-height: 100%;
  }

  .sidebar-backdrop {
    display: none;
  }

  @media (max-width: 768px) {
    .sidebar-backdrop {
      display: block;
      position: fixed;
      inset: 0;
      top: 52px;
      background: rgba(0, 0, 0, 0.5);
      z-index: 99;
    }

    .shell__content {
      padding: 16px;
    }
  }
</style>
