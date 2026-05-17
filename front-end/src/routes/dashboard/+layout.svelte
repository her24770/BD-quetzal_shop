<script lang="ts">
  import { goto, afterNavigate } from '$app/navigation';
  import { onMount } from 'svelte';
  import { get } from 'svelte/store';
  import Navbar from '$lib/components/Navbar.svelte';
  import Sidebar from '$lib/components/Sidebar.svelte';
  import Toast from '$lib/components/Toast.svelte';
  import ConfirmModal from '$lib/components/ConfirmModal.svelte';
  import { auth } from '$lib/stores/auth';
  import { apiFetch } from '$lib/api';
  import { permisos } from '$lib/stores/permisos';

  let sidebarOpen = false;

  function toggleSidebar() { sidebarOpen = !sidebarOpen; }
  function closeSidebar()  { sidebarOpen = false; }

  afterNavigate(() => { sidebarOpen = false; });

  onMount(async () => {
    if (!$auth.token) {
      goto('/');
      return;
    }
    // Si el store de permisos está vacío (refresh de página), los recarga del API
    if (Object.keys(get(permisos)).length === 0) {
      const r = await apiFetch('/auth/me/permisos', $auth.token);
      if (r.ok) permisos.load(await r.json());
    }
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
