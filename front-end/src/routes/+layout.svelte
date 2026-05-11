<script lang="ts">
  import '../app.css';
  import { initTheme } from '$lib/stores/theme';
  import { browser } from '$app/environment';

  if (browser) initTheme();
</script>

<slot />
