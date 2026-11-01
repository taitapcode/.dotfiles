{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.modules.home.programs.hermes;
  # Hermes's browser: stock Chromium from nixpkgs, referenced by store path.
  # Hermes never consults PATH (resolution: AGENT_BROWSER_EXECUTABLE_PATH >
  # PM's runtime download, which is FHS-unsafe on NixOS), so the explicit path
  # is what keeps the browser tool working. Chromium stays out of
  # home.packages on purpose — the interpolated path already pins it in the
  # closure, and putting it on PATH would shadow the user's default browser.
  browserBin = "${pkgs.chromium}/bin/chromium";
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

    # Hermes drives stock pkgs.chromium (see browserBin above), not a second
    # browser build. Both declarations below must carry the same path — shells
    # read home.sessionVariables, the gateway unit reads services…environment,
    # and neither inherits the other.
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
          default = "deepseek-ai/DeepSeek-V4.1-Flash-1017";
          provider = "deepinfra";
        };

        # Runtime default is "high"; pin the cheaper tier here.
        agent.reasoning_effort = "low";

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

        # Voice off. The Desktop renderer derives its voice.enabled flag from
        # stt.enabled, so this disables the mic button, dictation and voice
        # chat — the stt/tts entries in agent.disabled_toolsets above only drop
        # the agent's tools, never that UI. wake_word defaults to off already.
        stt.enabled = false;

        # Built-in persistent memory (MEMORY.md / USER.md). Default is true, but
        # the "Blank Slate" setup preset writes false; pin it on here.
        memory = {
          memory_enabled = true;
          user_profile_enabled = true;
        };

        # No auxiliary overrides: every aux slot stays "auto" and inherits the
        # main model. deepseek-flash is natively multimodal (V4.1-Flash,
        # supports_vision=True), so vision rides on the main provider/key.

        # The flake ships every binary Hermes needs, so PM must never provision
        # its own: a lazy install recreates ~/.hermes/tools/facts.json, and any
        # facts file that exists while packages are missing turns the startup
        # check into "⚠ install out of sync (node; npm; ffmpeg; ripgrep)". No
        # facts file → pm.drift() returns {} and the line cannot come back.
        # Explicit `hermes pm install` still works (explicit bypasses this).
        # This is a config.yaml key, so it lives under `settings` — putting it
        # directly under `services.hermes-agent` fails as an unknown option.
        security.allow_lazy_installs = false;

        # Bundled hook plugins. Keep sorted. A key here is what makes a
        # non-bundled plugin load; an extraPlugins symlink alone is inert.
        plugins.enabled = [
          "disk-cleanup"
          "security-guidance"
        ];
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
