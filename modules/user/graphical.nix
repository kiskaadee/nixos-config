# 🎨 User Graphical Module
# Configures graphical workspace tools, text editors, and session unit targets.

{ inputs, pkgs, ...}:
{
  # Mount custom Hyprland configuration file declaratively
  home.file.".config/hypr/hyprland.conf".text = builtins.readFile ./config/hyprland.conf;

  # Graphical packages managed via Home Manager
  home.packages = with pkgs; [
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default # Modern browser build
    zed-editor # GPU-accelerated desktop text editor
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
    initLua = ''
      vim.opt.number = true          -- Show line numbers
      vim.opt.relativenumber = true  -- Relative line numbers for easier navigation jumps
      vim.opt.shiftwidth = 2         -- 2-space indents
      vim.opt.tabstop = 2            -- Tab spacing
      vim.opt.expandtab = true       -- Convert tabs to spaces
      vim.opt.smartindent = true     -- Intelligent auto-indenting based on file syntax
      vim.opt.wrap = false           -- Disable automatic line wrapping
      vim.opt.termguicolors = true   -- Enable 24-bit RGB terminal colors
    '';

    ## Declarative Plugin Management
    plugins = with pkgs.vimPlugins; [
      # Color scheme loaded dynamically
      {
        plugin = catppuccin-nvim;
        type = "lua";
        config = ''
          vim.cmd("packadd catppuccin-nvim")
          vim.cmd("colorscheme catppuccin-mocha")
        '';
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
    ];
  };

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
