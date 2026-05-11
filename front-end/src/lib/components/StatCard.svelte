<script lang="ts">
  import Icon from './Icon.svelte';

  export let label: string = '';
  export let value: string | number = '';
  export let sub: string = '';
  export let iconPath: string = '';
  export let iconBg: string = '#EDE9FE';
  export let iconColor: string = '#7C3AED';
</script>

<div class="stat-card">
  <div class="stat-card__top">
    <span class="stat-card__label">{label}</span>
    <div class="stat-card__icon" style="background:{iconBg};color:{iconColor}">
      <Icon path={iconPath} size={17} color={iconColor} />
    </div>
  </div>
  <div class="stat-card__value">{value}</div>
  {#if sub}
    <div class="stat-card__sub">{sub}</div>
  {/if}
</div>

<style>
  .stat-card {
    background: var(--surface);
    border-radius: 12px;
    padding: 18px 20px;
    border: 1px solid var(--border);
    transition: transform .2s, box-shadow .2s, background .2s;
  }
  .stat-card:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 20px rgba(0,0,0,.12);
  }
  .stat-card__top {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    margin-bottom: 12px;
  }
  .stat-card__label {
    font-size: 11px;
    font-weight: 500;
    color: var(--txt-4);
    text-transform: uppercase;
    letter-spacing: .05em;
  }
  .stat-card__icon {
    width: 34px; height: 34px;
    border-radius: 8px;
    display: flex; align-items: center; justify-content: center;
    flex-shrink: 0;
  }
  .stat-card__value {
    font-size: 26px;
    font-weight: 700;
    color: var(--txt);
    letter-spacing: -.5px;
    line-height: 1;
  }
  .stat-card__sub {
    font-size: 11px;
    color: var(--txt-4);
    margin-top: 6px;
  }
</style>
