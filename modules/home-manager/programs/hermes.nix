{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.modules.home.programs.hermes;
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
      };
    };

    sops = lib.mkIf config.modules.home.programs.sops.enable {
      secrets."hermes-env" = {
        path = "${config.home.homeDirectory}/.hermes/.env";
      };
    };
  };
}
