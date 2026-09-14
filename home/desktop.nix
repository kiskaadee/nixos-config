# 🎨 User Desktop & Graphical Applications
# GUI applications, Wayland capture tools, Alacritty, Firefox, DankSearch, and Niri/Zed dotfiles.

{ inputs, pkgs, ... }:

let
  # Declaratively compile local scripts as user utility packages
  bundleProject = pkgs.writeScriptBin "bundle-project" (builtins.readFile ./scripts/bundle_project.py);
  recordScript = pkgs.writeScriptBin "record" (builtins.readFile ./scripts/record.sh);
in
{
  home.packages = with pkgs; [
    # Custom scripts
    bundleProject
    recordScript

    # Modern Web Browser
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default

    # Graphical Applications & Editors
    zed-editor
    obsidian
    libreoffice
    nautilus
    yazi
    mpv
    gimp
    imagemagick
    eyed3

    # Wayland Clipboard, Screenshot & Screen Capture Utilities
    wl-clipboard
    grim
    slurp
    swappy
    libnotify
    wf-recorder
    obs-studio
  ];

  # GPU-Accelerated Terminal Emulator (Alacritty)
  programs.alacritty = {
    enable = true;
    settings = builtins.fromTOML (builtins.readFile ./config/alacritty/alacritty.toml);
  };

  # Firefox configuration with hardware acceleration
  programs.firefox = {
    enable = true;
    profiles.default = {
      settings = {
        "layers.acceleration.force-enabled" = true;
        "gfx.webrender.all" = true;
        "extensions.pocket.enabled" = false;
        "datareporting.healthreport.uploadEnabled" = false;
      };
    };
  };

  # GTK & Icon Theme Configuration
  gtk = {
    enable = true;
    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
  };

  # Declarative configuration files for Zed editor
  home.file.".config/zed/settings.json".source = ./config/zed/settings.json;
  home.file.".config/zed/themes".source = ./config/zed/themes;

  # Declarative configuration files for Niri window manager
  home.file.".config/niri/config.kdl".source = ./config/niri/config.kdl;
  home.file.".config/niri/custom.kdl".source = ./config/niri/custom.kdl;

  # Systemd user session target for Niri window manager

  systemd.user.targets.niri-session = {
    Unit = {
      Description = "Niri graphical session";
      Documentation = [ "man:systemd.special(7)" ];
      BindsTo = [ "graphical-session.target" ];
      Wants = [ "graphical-session-pre.target" ];
      After = [ "graphical-session-pre.target" ];
    };
  };

  # DankSearch - Fast Indexed Filesystem Search Service
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
