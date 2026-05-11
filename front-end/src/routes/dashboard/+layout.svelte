<script lang="ts">
  import { goto } from '$app/navigation';
  import { onMount } from 'svelte';
  import Navbar from '$lib/components/Navbar.svelte';
  import Sidebar from '$lib/components/Sidebar.svelte';
  import Toast from '$lib/components/Toast.svelte';
  import { auth } from '$lib/stores/auth';

  let toasts: { id: number; msg: string; type: 'success' | 'error' }[] = [];

  onMount(() => {
    if (!$auth.token) {
      goto('/');
    }
  });
</script>

{#if $auth.token}
  <div class="shell">
    <Navbar />

    <div class="shell__body">
      <Sidebar />

      <main class="shell__main">
        <div class="shell__content">
          <slot />
        </div>
      </main>
    </div>
  </div>

  <Toast {toasts} />
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
</style>
