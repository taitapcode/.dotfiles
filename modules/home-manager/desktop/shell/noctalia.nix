{
  config,
  lib,
  self,
  ...
}:
let
  cfg = config.modules.home.desktop.shell.noctalia;
  wallpaperPath = "${self}/assets/wallpapers";
  defaultWallpaper = "${wallpaperPath}/3.png";
in
{
  options.modules.home.desktop.shell.noctalia.enable =
    lib.mkEnableOption "Enable Noctalia shell configuration";

  config = lib.mkIf cfg.enable {
    programs.noctalia = {
      enable = true;
      systemd.enable = true;
      settings = {
        audio.enable_overdrive = true;

        backdrop.enabled = true;

        battery.warning_threshold = 20;

        bar = {
          order = [ "top" ];
          top = {
            background_opacity = 0.9;
            end = [
              "tray"
              "cpu"
              "ram"
              "brightness"
              "volume"
              "clipboard"
              "bluetooth"
              "network"
              "battery"
              "notifications"
              "session"
            ];
            margin_edge = 0;
            margin_ends = 0;
            radius = 0;
            shadow = false;
            start = [ "workspaces" ];
            widget_spacing = 8;
          };
        };

        control_center = {
          sidebar = "compact";
          sidebar_section = "none";
          calendar = {
            show_events_card = false;
          };
        };

        desktop_widgets.enabled = false;

        dock = {
          auto_hide = true;
          background_opacity = 0.85;
          cross_axis_padding = 0;
          enabled = true;
          icon_size = 70;
          inactive_opacity = 0.95;
          item_spacing = 0;
          main_axis_padding = 0;
          pinned = [
            "com.mitchellh.ghostty"
            "zen-beta"
            "org.gnome.Nautilus"
            "vesktop"
            "antigravity"
            "org.pwmt.zathura"
            "anki"
            "helium"
            "LocalSend"
            "com.obsproject.Studio"
          ];
          position = "bottom";
          reserve_space = false;
          show_dots = true;
          smart_auto_hide = true;
        };

        location.address = "Ho Chi Minh City, Vietnam";

        lockscreen = {
          blur_intensity = 0.1;
          tint_intensity = 0.1;
        };

        lockscreen_widgets = {
          enabled = true;
          schema_version = 2;
          widget_order = [
            "lockscreen-widget-0000000000000003"
            "lockscreen-widget-0000000000000001"
            "lockscreen-login-box@HDMI-A-1"
            "lockscreen-login-box@DP-9"
            "lockscreen-login-box@eDP-1"
            "lockscreen-widget-0000000000000002"
            "lockscreen-widget-0000000000000004"
          ];

          grid = {
            cell_size = 16;
            major_interval = 4;
            visible = true;
          };

          widget = {
            "lockscreen-login-box@DP-9" = {
              box_height = 196.0;
              box_width = 810.0;
              cx = 1280.0;
              cy = 1258.0;
              output = "DP-9";
              placement_height = 1440.0;
              placement_width = 2560.0;
              rotation = 0.0;
              type = "login_box";
              settings = {
                background_color = "surface_variant";
                background_opacity = 0.88;
                background_radius = 12.0;
                center_password_text = false;
                input_opacity = 1.0;
                input_radius = 6.0;
                layout = "regular";
                show_caps_lock = true;
                show_keyboard_layout = true;
                show_login_button = true;
                show_media = true;
                show_session_buttons = true;
                show_unlock_hint = true;
                show_weather = true;
              };
            };

            "lockscreen-login-box@HDMI-A-1" = {
              box_height = 196.0;
              box_width = 810.0;
              cx = 1280.0;
              cy = 1197.3333740234375;
              output = "HDMI-A-1";
              placement_height = 1440.0;
              placement_width = 2560.0;
              rotation = 0.0;
              type = "login_box";
              settings = {
                background_color = "surface_variant";
                background_opacity = 0.88;
                background_radius = 12.0;
                center_password_text = false;
                input_opacity = 1.0;
                input_radius = 6.0;
                layout = "regular";
                show_caps_lock = true;
                show_keyboard_layout = true;
                show_login_button = true;
                show_media = true;
                show_session_buttons = true;
                show_unlock_hint = true;
                show_weather = true;
              };
            };

            "lockscreen-login-box@eDP-1" = {
              box_height = 128.0;
              box_width = 720.0;
              cx = 960.0;
              cy = 844.0;
              output = "eDP-1";
              placement_height = 1080.0;
              placement_width = 1920.0;
              rotation = 0.0;
              type = "login_box";
              settings = {
                background_color = "surface_variant";
                background_opacity = 0.88;
                background_radius = 12.0;
                center_password_text = true;
                input_opacity = 1.0;
                input_radius = 6.0;
                layout = "regular";
                show_caps_lock = true;
                show_keyboard_layout = true;
                show_login_button = true;
                show_media = false;
                show_session_buttons = true;
                show_unlock_hint = false;
                show_weather = false;
              };
            };

            "lockscreen-widget-0000000000000001" = {
              box_height = 208.0;
              box_width = 464.0;
              cx = 960.0;
              cy = 212.0;
              output = "eDP-1";
              placement_height = 1080.0;
              placement_width = 1920.0;
              rotation = 0.0;
              type = "clock";
              settings = {
                background = false;
                background_opacity = 0.0;
                background_padding = 16;
                background_radius = 0;
                clock_style = "digital";
                font_family = "JetBrainsMono Nerd Font";
                format = "{:%H:%M}";
                shadow = true;
              };
            };

            "lockscreen-widget-0000000000000002" = {
              box_height = 32.0;
              box_width = 368.0;
              cx = 960.0;
              cy = 300.0;
              output = "eDP-1";
              placement_height = 1080.0;
              placement_width = 1920.0;
              rotation = 0.0;
              type = "clock";
              settings = {
                background = false;
                background_opacity = 0.0;
                background_padding = 16;
                background_radius = 0;
                clock_style = "digital";
                font_family = "";
                format = "{:%A, %d/%m/%Y}";
                shadow = true;
                timezone = "";
              };
            };

            "lockscreen-widget-0000000000000003" = {
              box_height = 224.0;
              box_width = 848.0;
              cx = 960.0;
              cy = 212.0;
              output = "eDP-1";
              placement_height = 1080.0;
              placement_width = 1920.0;
              rotation = 0.0;
              type = "audio_visualizer";
              settings = {
                background = false;
                bands = 24;
                centered = true;
                color_2 = "secondary";
                reversed = false;
                show_when_idle = false;
              };
            };

            "lockscreen-widget-0000000000000004" = {
              box_height = 144.0;
              box_width = 336.0;
              cx = 176.0;
              cy = 996.0;
              output = "eDP-1";
              placement_height = 1080.0;
              placement_width = 1920.0;
              rotation = 0.0;
              type = "media_player";
              settings = {
                background = true;
                hide_when_no_media = true;
                layout = "horizontal";
              };
            };
          };
        };

        notification = {
          history_retention_hours = 1;
          position = "top_center";
        };

        osd.kinds.keyboard_layout = false;

        plugins.enabled = [ ];

        shell = {
          avatar_path = "${self}/assets/profile.jpg";
          corner_radius_scale = 1.6;
          greeter_sync = {
            auto_sync = true;
          };
          lang = "en";
          niri_overview_type_to_launch_enabled = true;
          password_style = "random";
          screen_time_enabled = true;
          settings_show_advanced = true;
          show_location = true;

          launcher = {
            categories = false;
            providers = {
              emoji = {
                global = true;
                prefix = "";
              };
              session.global = false;
              wallpaper.global = false;
            };
          };

          panel = {
            clipboard_placement = "floating";
            polkit_placement = "attached";
          };

          screenshot.confirm_region = true;

          window_switcher = {
            mru = true;
          };
        };

        theme = {
          builtin = "Catppuccin";
          community_palette = "Oxocarbon";
          mode = "dark";
          source = "wallpaper";
          wallpaper_scheme = "m3-content";
          templates = {
            community_ids = [ ];
            enable_builtin_templates = false;
            enable_community_templates = false;
          };
        };

        wallpaper = {
          directory = wallpaperPath;
          transition_on_startup = true;
          default.path = defaultWallpaper;
          last.path = defaultWallpaper;
        };

        widget = {
          battery = {
            display_mode = "graphic";
            show_label = true;
          };
          clock = {
            color = "secondary";
            format = "{: %H:%M - %A, %d/%m/%Y }";
          };
          media.hide_when_no_media = true;
          network.show_label = false;
          workspaces = {
            hide_when_empty = true;
            show_labels = false;
          };
        };
      };
    };
  };
}
