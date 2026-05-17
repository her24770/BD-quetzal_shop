<script lang="ts">
  import { goto } from '$app/navigation';
  import { IC } from '$lib/icons';
  import { auth } from '$lib/stores/auth';
  import { loginRequest, apiFetch } from '$lib/api';
  import { permisos } from '$lib/stores/permisos';

  let email        = '';
  let password     = '';
  let showPassword = false;
  let loading      = false;
  let error        = '';

  async function handleSubmit() {
    if (!email || !password) {
      error = 'Completa todos los campos';
      return;
    }

    loading = true;
    error   = '';

    try {
      const data = await loginRequest(email, password);
      auth.login(data.access_token, data.user);
      const r = await apiFetch('/auth/me/permisos', data.access_token);
      if (r.ok) permisos.load(await r.json());
      goto('/dashboard');
    } catch (e: any) {
      error = e.message ?? 'Error al iniciar sesión';
    } finally {
      loading = false;
    }
  }
</script>

<div class="login-wrapper">
  <div class="login-card">

    <!-- Logo / Branding -->
    <div class="login-brand">
      <div class="brand-icon">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d={IC.cart} />
        </svg>
      </div>
      <h1 class="brand-name">QuetzalShop</h1>
      <p class="brand-sub">Gestor de tienda</p>
    </div>

    <!-- Error -->
    {#if error}
      <div class="login-error">{error}</div>
    {/if}

    <!-- Formulario -->
    <form class="login-form" on:submit|preventDefault={handleSubmit}>
      <div class="qz-field">
        <label class="qz-label" for="email">Correo electrónico</label>
        <div class="qz-input-wrap">
          <span class="qz-input-icon">
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d={IC.mail} />
            </svg>
          </span>
          <input
            id="email"
            type="email"
            class="qz-input has-icon"
            placeholder="usuario@quetzalshop.com"
            bind:value={email}
            disabled={loading}
          />
        </div>
      </div>

      <div class="qz-field">
        <label class="qz-label" for="password">Contraseña</label>
        <div class="qz-input-wrap">
          <span class="qz-input-icon">
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d={IC.lock} />
            </svg>
          </span>
          <!-- Dos inputs para evitar el error de bind:value con type dinámico -->
          {#if showPassword}
            <input
              id="password"
              type="text"
              class="qz-input has-icon"
              placeholder="••••••••"
              bind:value={password}
              disabled={loading}
            />
          {:else}
            <input
              id="password"
              type="password"
              class="qz-input has-icon"
              placeholder="••••••••"
              bind:value={password}
              disabled={loading}
            />
          {/if}
          <button
            type="button"
            class="toggle-pw"
            on:click={() => showPassword = !showPassword}
          >
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d={showPassword ? IC.eyeOff : IC.eye} />
            </svg>
          </button>
        </div>
      </div>

      <button
        type="submit"
        class="btn btn-purple btn-lg full"
        style="margin-top: 8px;"
        disabled={loading}
      >
        {#if loading}
          Ingresando...
        {:else}
          Ingresar
        {/if}
      </button>
    </form>

  </div>
</div>

<style>
  .login-wrapper {
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
    background: linear-gradient(135deg, var(--p-800) 0%, var(--p-600) 100%);
    padding: 20px;
  }

  .login-card {
    background: var(--surface);
    border-radius: 16px;
    padding: 40px 36px;
    width: 100%;
    max-width: 380px;
    box-shadow: 0 24px 64px rgba(0, 0, 0, 0.2);
  }

  .login-brand {
    text-align: center;
    margin-bottom: 32px;
  }

  .brand-icon {
    width: 52px;
    height: 52px;
    background: var(--p-600);
    border-radius: 14px;
    display: flex;
    align-items: center;
    justify-content: center;
    margin: 0 auto 14px;
    color: #fff;
  }

  .brand-icon svg {
    width: 26px;
    height: 26px;
  }

  .brand-name {
    font-size: 22px;
    font-weight: 700;
    color: var(--txt);
    margin: 0 0 4px;
    letter-spacing: -0.4px;
  }

  .brand-sub {
    font-size: 13px;
    color: var(--txt-4);
    margin: 0;
  }

  .login-error {
    background: var(--red-bg);
    border: 1px solid var(--red-border);
    color: var(--red-text);
    font-size: 13px;
    font-weight: 500;
    padding: 10px 14px;
    border-radius: 8px;
    margin-bottom: 16px;
  }

  .login-form {
    display: flex;
    flex-direction: column;
    gap: 16px;
  }

  .toggle-pw {
    position: absolute;
    right: 10px;
    top: 50%;
    transform: translateY(-50%);
    border: none;
    background: none;
    cursor: pointer;
    color: var(--g-400);
    display: flex;
    padding: 4px;
    border-radius: 4px;
    transition: color 0.15s;
  }

  .toggle-pw:hover {
    color: var(--txt-2);
  }
</style>
