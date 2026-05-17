<script lang="ts">
  import { toast } from '$lib/stores/toast';
  import Icon from './Icon.svelte';
  import { IC } from '$lib/icons';
</script>

<div class="toast-container">
  {#each $toast as t (t.id)}
    <div class="toast {t.type}">
      <Icon path={t.type === 'error' ? IC.alert : IC.check} size={15} />
      <span class="toast-msg">{t.msg}</span>
      <button class="toast-close" on:click={() => toast.remove(t.id)}>
        <Icon path={IC.x} size={13} />
      </button>
    </div>
  {/each}
</div>
