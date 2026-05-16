<script lang="ts">
  import { page } from '$app/stores';
  import Icon from './Icon.svelte';
  import { IC } from '$lib/icons';
  import { permisos } from '$lib/stores/permisos';

  export let lowStockCount: number = 0;
  export let open: boolean = false;

  // check: null = siempre visible | array de [tabla, op] = OR entre ellos
  const allNavItems = [
    { label: 'Dashboard',     href: '/dashboard',               icon: IC.home,     exact: true, check: null },
    { label: 'Productos',     href: '/dashboard/productos',     icon: IC.box,      badge: true, check: [['productos',   'SELECT']] },
    { label: 'Categorías',    href: '/dashboard/categorias',    icon: IC.tag,                   check: [['categorias',  'SELECT']] },
    { label: 'Proveedores',   href: '/dashboard/proveedores',   icon: IC.truck,                 check: [['proveedores', 'SELECT']] },
    { label: 'Clientes',      href: '/dashboard/clientes',      icon: IC.users,                 check: [['clientes',    'SELECT']] },
    { label: 'Transacciones', href: '/dashboard/transacciones', icon: IC.transfer,              check: [['ventas', 'INSERT'], ['compras', 'INSERT']] },
    { label: 'Historial',     href: '/dashboard/historial',     icon: IC.chart,                 check: [['ventas', 'SELECT'], ['compras', 'SELECT']] },
    { label: 'Empleados',     href: '/dashboard/empleados',     icon: IC.person,                check: [['empleados',   'SELECT']] },
  ];

  $: navItems = allNavItems.filter(item => {
    if (!item.check) return true;
    return item.check.some(([tabla, op]) => ($permisos[tabla] ?? []).includes(op));
  });
</script>

<aside class="sidebar" class:open>
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

  @media (max-width: 768px) {
    .sidebar {
      position: fixed;
      left: 0;
      top: 52px;
      height: calc(100vh - 52px);
      z-index: 100;
      transform: translateX(-100%);
      transition: transform .25s ease;
      box-shadow: 4px 0 20px rgba(0,0,0,.3);
    }
    .sidebar.open {
      transform: translateX(0);
    }
  }
</style>
