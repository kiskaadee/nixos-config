{ inputs, pkgs, ...}:
{
  home.packages = with pkgs; [
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    zed-editor
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    ## Core settings
    initLua = ''
      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.opt.shiftwidth = 2
      vim.opt.tabstop = 2
      vim.opt.expandtab = true
      vim.opt.smartindent = true
      vim.opt.wrap = false
      vim.opt.termguicolors = true
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

      # Advanced Syntax Highlighting for Python, Rust and Nix
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
