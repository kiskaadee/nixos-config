# 🎨 User Graphical Module
# Configures graphical workspace tools, GUI applications, and window manager session unit targets.
# Only imported by desktop and laptop profiles.

{ inputs, pkgs, ... }:

let
  # Parse true ASCII Escape (0x1b) and DEL (0x7f) bytes so TOML serialization generates real escape sequences
  esc = builtins.fromJSON "\"\\u001b\"";
  del = builtins.fromJSON "\"\\u007f\"";
in
{
  # Graphical packages managed via Home Manager
  home.packages = with pkgs; [
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default # Modern browser build
    zed-editor # GPU-accelerated desktop text editor

    # Wayland Clipboard, Screenshot & Screen Capture Utilities
    wl-clipboard
    grim
    slurp
    swappy
    libnotify
    wf-recorder
    obs-studio

    # Language Servers for Zed (and general dev use)
    rust-analyzer
    pyright
    ruff
    nil
    nixd
    jdt-language-server
    typescript-language-server
    lua-language-server
    taplo
    marksman
    prettier
  ];

  # GPU-Accelerated Terminal Emulator (Alacritty)
  programs.alacritty = {
    enable = true;
    settings = {
      general = {
        import = [
          "~/.config/alacritty/dank-theme.toml"
        ];
      };

      font = {
        normal = { family = "FiraCode Nerd Font"; style = "Regular"; };
        bold = { family = "FiraCode Nerd Font"; style = "Bold"; };
        italic = { family = "FiraCode Nerd Font"; style = "Italic"; };
        bold_italic = { family = "FiraCode Nerd Font"; style = "Bold Italic"; };
        size = 11.0;
      };

      window = {
        decorations = "None";
        padding = { x = 12; y = 12; };
        opacity = 1.0;
      };

      scrolling = {
        history = 3023;
      };

      cursor = {
        style = { shape = "Block"; blinking = "On"; };
        blink_interval = 500;
        unfocused_hollow = true;
      };

      mouse = {
        hide_when_typing = true;
      };

      selection = {
        save_to_clipboard = false;
      };

      bell = {
        duration = 0;
      };

      keyboard = {
        bindings = [
          { key = "C";       mods = "Control|Shift"; action = "Copy";  }
          { key = "V";       mods = "Control|Shift"; action = "Paste"; }
          { key = "N";       mods = "Control|Shift"; action = "SpawnNewInstance"; }
          { key = "Equals";  mods = "Control|Shift"; action = "IncreaseFontSize"; }
          { key = "Minus";   mods = "Control";       action = "DecreaseFontSize"; }
          { key = "Key0";    mods = "Control";       action = "ResetFontSize";    }
          { key = "Enter";   mods = "Shift";         chars = "\n"; }
          { key = "Delete";  mods = "Control";       chars = "${esc}[3;5~"; }
          { key = "Back";    mods = "Control";       chars = "${esc}${del}"; }
        ];
      };
    };
  };

  # Firefox configuration
  programs.firefox = {
    enable = true;
    profiles.default = {
      settings = {
        # Force hardware acceleration
        "layers.acceleration.force-enabled" = true;
        "gfx.webrender.all" = true;

        # Disable pocket-telemetry
        "extensions.pocket.enabled" = false;
        "datareporting.healthreport.uploadEnabled" = false;
      };
    };
  };

  # Declarative configuration files for Zed editor
  home.file.".config/zed/settings.json".source = ./config/zed/settings.json;
  home.file.".config/zed/themes".source = ./config/zed/themes;

  # Declarative configuration files for Niri window manager
  home.file.".config/niri/config.kdl".source = ./config/niri/config.kdl;
  home.file.".config/niri/custom.kdl".source = ./config/niri/custom.kdl;

  # ⚙️ Systemd user session targets for window managers
  systemd.user.targets.hyprland-session = {
    Unit = {
      Description = "Hyprland graphical session";
      Documentation = [ "man:systemd.special(7)" ];
      BindsTo = [ "graphical-session.target" ];
      Wants = [ "graphical-session-pre.target" ];
      After = [ "graphical-session-pre.target" ];
    };
  };

  systemd.user.targets.niri-session = {
    Unit = {
      Description = "Niri graphical session";
      Documentation = [ "man:systemd.special(7)" ];
      BindsTo = [ "graphical-session.target" ];
      Wants = [ "graphical-session-pre.target" ];
      After = [ "graphical-session-pre.target" ];
    };
  };

  # 🔍 DankSearch - Fast Indexed Filesystem Search Service
  programs.dsearch = {
    enable = true;
    config = {
      listen_addr = "127.0.0.1:43654";
      max_file_bytes = 2097152;
      worker_count = 4;
      index_all_files = true;
      text_extensions = [
        ".txt" ".md" ".go" ".py" ".js" ".ts"
        ".jsx" ".tsx" ".json" ".yaml" ".yml"
        ".toml" ".html" ".css" ".rs" ".c"
        ".cpp" ".h" ".java" ".rb" ".php" ".sh" ".nix" ".kdl"
      ];
      index_paths = [
        {
          path = "/home/kiskaadee";
          max_depth = 5;
          exclude_hidden = true;
          extract_exif = true;
          exclude_dirs = [
            "node_modules" "bower_components" "__pycache__" "site-packages"
            "venv" ".venv" "target" "dist" "build" "vendor" ".cache"
          ];
        }
        {
          path = "/home/kiskaadee/Repos";
          max_depth = 6;
          exclude_hidden = true;
          extract_exif = false;
          exclude_dirs = [
            "node_modules" "bower_components" "__pycache__" "site-packages"
            "venv" ".venv" "target" "dist" "build" "vendor" ".cache"
            ".git" ".idea" ".vscode"
          ];
        }
        {
          path = "/home/kiskaadee/Config";
          max_depth = 6;
          exclude_hidden = false;
          extract_exif = false;
          merge_default_exclude_dirs = true;
          exclude_dirs = [ ".git" ];
        }
      ];
    };
  };
}
