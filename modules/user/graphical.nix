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

      # Advanced Syntax Highlighting for developer workflows (Python, Rust, Java, Nix)
      (nvim-treesitter.withPlugins (p: with p; [
        python
        rust
        nix
        lua
        java
        javascript
        markdown
      ]))

      # LSP Configuration & Python Language Servers
      {
        plugin = nvim-lspconfig;
        type = "lua";
        config = builtins.readFile ./config/nvim/lsp.lua;
      }
    ];
  };

  # Declarative configuration files for Zed editor
  home.file.".config/zed/settings.json".source = ./config/zed/settings.json;
  home.file.".config/zed/themes".source = ./config/zed/themes;

  # ⚙️ Systemd user session targets for window managers
  # This target allows user services (like background daemons, screenshot helpers) to bind 
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
}
