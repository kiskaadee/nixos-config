# 🎨 User Graphical Module
# Configures graphical workspace tools, GUI applications, and window manager session unit targets.
# Only imported by desktop and laptop profiles.

{ inputs, pkgs, ... }:

{
  # Graphical packages managed via Home Manager
  home.packages = with pkgs; [
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default # Modern browser build
    zed-editor # GPU-accelerated desktop text editor

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
