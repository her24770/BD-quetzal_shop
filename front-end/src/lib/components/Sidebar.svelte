<script lang="ts">
  import { page } from '$app/stores';
  import Icon from './Icon.svelte';
  import { IC } from '$lib/icons';
  import { auth } from '$lib/stores/auth';

  export let lowStockCount: number = 0;

  const allNavItems = [
    { label: 'Dashboard',      href: '/dashboard',                   icon: IC.home,     exact: true, roles: [1, 2, 3] },
    { label: 'Productos',      href: '/dashboard/productos',         icon: IC.box,      badge: true, roles: [1, 3] },
    { label: 'Categorías',     href: '/dashboard/categorias',        icon: IC.tag,                   roles: [1, 3] },
    { label: 'Proveedores',    href: '/dashboard/proveedores',       icon: IC.truck,                 roles: [1, 3] },
    { label: 'Clientes',       href: '/dashboard/clientes',          icon: IC.users,                 roles: [1, 2] },
    { label: 'Transacciones',  href: '/dashboard/transacciones',     icon: IC.transfer,              roles: [1, 2, 3] },
    { label: 'Historial',      href: '/dashboard/historial',         icon: IC.chart,                 roles: [1, 2, 3] },
    { label: 'Empleados',      href: '/dashboard/empleados',         icon: IC.person,                roles: [1] },
  ];

  $: rolId    = $auth.user?.rol_id ?? 0;
  $: navItems = allNavItems.filter(item => item.roles.includes(rolId));
</script>

<aside class="sidebar">
  <nav class="sidebar__nav">
    <div class="sidebar__section-label">Menú</div>

    {#each navItems as item}
      {@const active = item.exact
        ? $page.url.pathname === item.href
        : $page.url.pathname === item.href || $page.url.pathname.startsWith(item.href + '/')}
      <a href={item.href} class="sidebar__item" class:active>
        {#if active}
          <div class="sidebar__active-bar"></div>
        {/if}
        <Icon path={item.icon} size={15} strokeWidth={active ? 2 : 1.6} />
        <span>{item.label}</span>
        {#if item.badge && lowStockCount > 0}
          <span class="sidebar__badge">{lowStockCount}</span>
        {/if}
      </a>
    {/each}
  </nav>
</aside>

<style>
  .sidebar {
    width: 210px;
    background: #4C1D95;
    display: flex;
    flex-direction: column;
    flex-shrink: 0;
    overflow-y: auto;
  }

  .sidebar__nav { padding: 8px; flex: 1; }

  .sidebar__section-label {
    font-size: 9px;
    font-weight: 600;
    color: rgba(255,255,255,.25);
    text-transform: uppercase;
    letter-spacing: .1em;
    padding: 10px 10px 6px;
  }

  .sidebar__item {
    position: relative;
    display: flex;
    align-items: center;
    gap: 9px;
    width: 100%;
    padding: 9px 10px;
    border-radius: 7px;
    cursor: pointer;
    margin-bottom: 1px;
    background: transparent;
    color: rgba(255,255,255,.55);
    font-weight: 400;
    font-size: 13px;
    text-decoration: none;
    transition: background .15s, color .15s;
  }
  .sidebar__item:hover:not(.active) {
    background: rgba(255,255,255,.07);
    color: rgba(255,255,255,.75);
  }
  .sidebar__item.active {
    background: rgba(255,255,255,.15);
    color: #fff;
    font-weight: 500;
  }

  .sidebar__active-bar {
    position: absolute;
    left: 0;
    top: 50%;
    transform: translateY(-50%);
    width: 3px;
    height: 16px;
    background: #C4B5FD;
    border-radius: 0 2px 2px 0;
  }

  .sidebar__badge {
    margin-left: auto;
    background: #F59E0B;
    color: #fff;
    font-size: 10px;
    font-weight: 700;
    padding: 1px 6px;
    border-radius: 10px;
  }
</style>
