# 🎨 User Graphical Module
# Configures graphical workspace tools, text editors, and session unit targets.

{ inputs, pkgs, ...}:
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

  # Neovim configuration
  programs.neovim = {
    enable = true;
    defaultEditor = true; # Make neovim the default `$EDITOR`
    viAlias = true;       # Symlink `vi` to `nvim`
    vimAlias = true;      # Symlink `vim` to `nvim`

    ## Core Editor Settings (Lua-based)
    initLua = builtins.readFile ./config/nvim/init.lua;

    ## Declarative Plugin Management
    plugins = with pkgs.vimPlugins; [
      # Color scheme loaded dynamically
      {
        plugin = catppuccin-nvim;
        type = "lua";
        config = builtins.readFile ./config/nvim/catppuccin.lua;
      }

      # Advanced Syntax Highlighting for developer workflows (Python, Rust, Java, Nix, KDL)
      (nvim-treesitter.withPlugins (p: with p; [
        python
        rust
        nix
        lua
        java
        javascript
        typescript
        markdown
        kdl
        toml
        bash
      ]))

      # LSP Configuration & Language Servers
      {
        plugin = nvim-lspconfig;
        type = "lua";
      }

      # DAP (Debug Adapter Protocol)
      {
        plugin = nvim-dap;
      }
      {
        plugin = nvim-dap-ui;
      }
    ];
  };

  # Declarative configuration files for Neovim (lsp.lua & dap.lua loaded dynamically via init.lua)
  home.file.".config/nvim/lsp.lua".source = ./config/nvim/lsp.lua;
  home.file.".config/nvim/dap.lua".source = ./config/nvim/dap.lua;

  # Declarative configuration files for Zed editor
  home.file.".config/zed/settings.json".source = ./config/zed/settings.json;
  home.file.".config/zed/themes".source = ./config/zed/themes;

  # Declarative configuration files for Niri window manager
  home.file.".config/niri/config.kdl".source = ./config/niri/config.kdl;
  home.file.".config/niri/custom.kdl".source = ./config/niri/custom.kdl;

  # ⚙️ Systemd user session targets for window managers
  # These targets allow user services (like DMS daemons, screenshot helpers) to bind 
  # to the graphical workspace startup cycle correctly.
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
