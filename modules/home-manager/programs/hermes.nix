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

      # Catalog plugins, pinned to the sha published in
      # https://hermes-agent.nousresearch.com/docs/api/plugin-catalog.json .
      # `name` is mandatory: fetchFromGitHub is otherwise named "source", which
      # both collides across entries (asserted) and names the symlink
      # nix-managed-source. Each package lands in ~/.hermes/plugins as
      # nix-managed-<name> and still needs its key in settings.plugins.enabled.
      extraPlugins = [
        (pkgs.fetchFromGitHub {
          name = "anysearch";
          owner = "vollegrewar";
          repo = "hermes-plugin-anysearch";
          rev = "43c1757a5d12d4d7adb4e74326c99182f4957b6f";
          hash = "sha256-Aj/GG+beauiokshbD2g3YivLP81otOOuomHdzgz8cNU=";
        })
        (pkgs.fetchFromGitHub {
          name = "diff-review";
          owner = "sprmn24";
          repo = "hermes-plugin-diff-review";
          rev = "f238271c1f63ac59b43b99290ec6143f50b780f3";
          hash = "sha256-obiH3ON/WGZ1JcU+uIAF8NX/PywU3Y0jBMMKHaA02Ak=";
        })
      ];

      settings = {
        model = {
          default = "deepseek-flash";
          provider = "deepseek";
        };

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

        # DeepSeek is text-only; route image/OCR work to Gemini.
        auxiliary.vision = {
          provider = "gemini";
          model = "gemini-3.6-flash";
        };

        # Bundled hook plugins plus the catalog plugins fetched above. Keep
        # sorted. A key here is what makes a non-bundled plugin load; the
        # extraPlugins symlink alone is inert.
        plugins.enabled = [
          "anysearch"
          "diff-review"
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
