{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.modules.home.programs.hermes;
  # Hermes's browser: Helium, referenced by store path. Hermes never consults
  # PATH (resolution: AGENT_BROWSER_EXECUTABLE_PATH > PM's runtime download,
  # which is FHS-unsafe on NixOS), so the explicit path is what keeps the
  # browser tool working. `package.override { flags }` is the exact derivation
  # `programs.helium` puts on PATH (package + its flags) — reusing it means one
  # browser in the closure instead of two; pkgs.chromium falls out entirely.
  browserBin = "${
    config.programs.helium.package.override { inherit (config.programs.helium) flags; }
  }/bin/helium";
in
{
  imports = [ inputs.hermes-agent.homeManagerModules.default ];

  options.modules.home.programs.hermes = {
    enable = lib.mkEnableOption "Enable Hermes CLI configuration";

    desktop = {
      enable = lib.mkEnableOption "Enable the Hermes Desktop (Electron) application";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.hermes-agent.enable = true;

    # Hermes's browser is Helium, not Chromium: pkgs.chromium is out of the
    # closure entirely (see browserBin above). Both declarations below must
    # carry the same path — shells read home.sessionVariables, the gateway
    # unit reads services…environment, and neither inherits the other.
    home.sessionVariables.AGENT_BROWSER_EXECUTABLE_PATH = browserBin;

    # hermes-desktop on PATH + XDG launcher entry. The launcher carries
    # HERMES_HOME, so the app shares ~/.hermes with the CLI and the services.
    # It starts its own backend (HERMES_DESKTOP_HERMES pins the nix-built
    # `hermes`), so no `services.hermes-agent.backend` unit is required.
    programs.hermes-agent.desktop.enable = cfg.desktop.enable;

    # `settings` is deep-merged into ~/.hermes/config.yaml on every switch.
    # Keys Nix declares always win; keys it does not declare (e.g.
    # _config_version, onboarding state, runtime-written keys) are preserved.
    #
    # NOTE: enabling this writes ~/.hermes/.managed, which makes the CLI refuse
    # `hermes config set|edit` / `hermes setup` and point at `home-manager switch`.
    # Change configuration here from now on, not with the CLI.
    services.hermes-agent = {
      enable = true;

      # The gateway unit does not inherit shell session env; pin the same path.
      environment.AGENT_BROWSER_EXECUTABLE_PATH = browserBin;

      settings = {
        model = {
          default = "mimo-v2.6-flash";
          provider = "xiaomi";
        };

        fallback_providers = [
          {
            provider = "deepseek";
            model = "deepseek-flash";
          }
        ];

        # Allowlist of toolsets that load for the CLI. Keep sorted.
        platform_toolsets.cli = [
          "browser"
          "code_execution"
          "cronjob"
          "delegation"
          "file"
          "memory"
          "session_search"
          "skills"
          "terminal"
          "todo"
          "vision"
          "web"
        ];

        # Blank Slate preset wrote this list into config.yaml; Nix must declare
        # the whole key to override it (Nix-declared keys win on every switch).
        # Same list minus "browser" — browser automation stays available.
        agent.disabled_toolsets = [
          "a2a"
          "bot_room"
          "clarify"
          "computer_use"
          "connections"
          "context_engine"
          "desktop_ui"
          "discord"
          "discord_admin"
          "feishu_doc"
          "feishu_drive"
          "image_gen"
          "kanban"
          "project"
          "setup"
          "spotify"
          "stt"
          "tts"
          "video"
          "video_gen"
          "x_search"
          "yuanbao"
        ];

        # Built-in persistent memory (MEMORY.md / USER.md). Default is true, but
        # the "Blank Slate" setup preset writes false; pin it on here.
        memory = {
          memory_enabled = true;
          user_profile_enabled = true;
        };

        # MiMo is multimodal, so vision stays on the same provider/key instead of
        # Gemini. Revert to gemini/gemini-3.6-flash if MiMo vision misbehaves
        auxiliary = {
          vision = {
            provider = "xiaomi";
            model = "mimo-v2.5";
          };

          # High-frequency, low-stakes calls: MiMo Flash tier (0.14/0.28 per M).
          # Every other aux slot is "auto" and inherits the main model.
          title_generation = {
            provider = "xiaomi";
            model = "mimo-v2.6-flash";
          };
          memory_query_rewrite = {
            provider = "xiaomi";
            model = "mimo-v2.6-flash";
          };
        };

        # Bundled hook plugins. Keep sorted. A key here is what makes a
        # non-bundled plugin load; an extraPlugins symlink alone is inert.
        plugins.enabled = [
          "disk-cleanup"
          "security-guidance"
        ];

        providers.xiaomi = {
          api = "https://api.xiaomimimo.com/v1";
          key_env = "XIAOMI_API_KEY";
          models = {
            "mimo-v2.5".prompt_caching = true;
            "mimo-v2.6-flash".prompt_caching = true;
          };
        };
      };
    };

    sops = lib.mkIf config.modules.home.programs.sops.enable {
      secrets."hermes-env" = {
        path = "${config.home.homeDirectory}/.hermes/.env";
      };
      secrets."google-client-secret" = {
        path = "${config.home.homeDirectory}/.hermes/google_client_secret.json";
      };
      # google_api.py rewrites this file on every access-token refresh, so it
      # must not be the default read-only 0400.
      secrets."google-token" = {
        path = "${config.home.homeDirectory}/.hermes/google_token.json";
        mode = "0600";
      };
    };
  };
}
