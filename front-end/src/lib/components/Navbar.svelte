<script lang="ts">
  import { goto } from '$app/navigation';
  import Icon from './Icon.svelte';
  import { IC } from '$lib/icons';
  import { auth } from '$lib/stores/auth';

  $: displayName = $auth.user?.nombre_empleado ?? $auth.user?.email ?? 'Usuario';

  function handleLogout() {
    auth.logout();
    goto('/');
  }
</script>

<header class="navbar">
  <div class="navbar__brand">
    <div class="navbar__logo-icon">
      <Icon path={IC.cart} size={15} strokeWidth={2} />
    </div>
    <span class="navbar__name">QuetzalShop</span>
  </div>

  <div class="navbar__end">
    <div class="navbar__user">
      <div class="navbar__avatar">{displayName[0]?.toUpperCase() ?? 'U'}</div>
      <span class="navbar__username">{displayName}</span>
    </div>
    <button class="navbar__logout" on:click={handleLogout}>
      <Icon path={IC.logout} size={13} />
      Cerrar sesión
    </button>
  </div>
</header>

<style>
  .navbar {
    height: 52px;
    background: #4C1D95;
    display: flex;
    align-items: center;
    padding: 0 20px;
    justify-content: space-between;
    flex-shrink: 0;
    z-index: 50;
    box-shadow: 0 2px 8px rgba(0,0,0,.3);
  }

  .navbar__brand { display: flex; align-items: center; gap: 10px; color: #fff; }
  .navbar__logo-icon {
    width: 28px; height: 28px;
    background: rgba(255,255,255,.12);
    border-radius: 7px;
    display: flex; align-items: center; justify-content: center;
  }
  .navbar__name { font-weight: 700; font-size: 16px; letter-spacing: -.3px; }


  .navbar__end { display: flex; align-items: center; gap: 14px; }

  .navbar__user { display: flex; align-items: center; gap: 8px; }
  .navbar__avatar {
    width: 26px; height: 26px; border-radius: 50%;
    background: rgba(255,255,255,.15);
    display: flex; align-items: center; justify-content: center;
    font-size: 11px; font-weight: 700; color: #fff;
  }
  .navbar__username { font-size: 13px; color: rgba(255,255,255,.8); font-weight: 500; }

  .navbar__logout {
    display: flex;
    align-items: center;
    gap: 5px;
    padding: 5px 11px;
    border: 1px solid rgba(255,255,255,.2);
    border-radius: 6px;
    background: transparent;
    color: rgba(255,255,255,.7);
    font-size: 12px;
    cursor: pointer;
    text-decoration: none;
    transition: background .15s, color .15s;
  }
  .navbar__logout:hover {
    background: rgba(255,255,255,.1);
    color: #fff;
  }
</style>
