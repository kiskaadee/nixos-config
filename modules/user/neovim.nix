# 🖋️ Neovim CLI & IDE Editor Configuration
# Shared across all host profiles (server, desktop, laptop).

{ pkgs, ... }:

{
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
}
