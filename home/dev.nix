# 🛠️ Developer Environment, Toolchains & Neovim
# Compilers, SDKs, language servers, API testing tools, and modular Neovim configuration.

{ inputs, pkgs, ... }:

{
  # Neovim CLI & IDE Editor Configuration
  programs.neovim = {
    enable = true;
    defaultEditor = true; # Make neovim the default $EDITOR
    viAlias = true;       # Symlink vi -> nvim
    vimAlias = true;      # Symlink vim -> nvim

    # Core Editor Settings (Lua-based)
    initLua = builtins.readFile ./config/nvim/init.lua;

    # Declarative Plugin Management
    plugins = with pkgs.vimPlugins; [
      {
        plugin = catppuccin-nvim;
        type = "lua";
        config = builtins.readFile ./config/nvim/catppuccin.lua;
      }
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
      {
        plugin = nvim-lspconfig;
        type = "lua";
      }
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

  # Developer packages & Toolchains
  home.packages = with pkgs; [
    # AI Assistant Companion
    inputs.antigravity.packages.${pkgs.stdenv.hostPlatform.system}.google-antigravity-cli

    # Rust Toolchain & Language Server
    cargo
    rustc
    rustfmt
    clippy
    rust-analyzer
    gcc

    # Python Toolchain & Language Server
    python3
    uv
    ruff
    mypy
    pyright

    # Node.js, Web & Formatter Tooling
    nodejs
    prettier

    # Language Servers, Linters & Diagnostics (Zed, Neovim, General)
    nil
    nixd
    jdt-language-server
    typescript-language-server
    lua-language-server
    luaPackages.luacheck
    taplo
    marksman
    shellcheck

    # Cloud CLI, Git Forge & Database Management
    tea              # Gitea official CLI client
    google-cloud-sdk # GCP administration utilities
    turso-cli        # Turso libSQL management CLI
    postgresql       # PostgreSQL client utilities (psql, pg_dump)
    pgcli            # Postgres client with auto-completion

    # API Testing & Networking
    httpie           # User-friendly HTTP/REST client
    bruno            # Fast, git-friendly GUI API client
    websocat         # WebSocket client
    grpcurl          # gRPC command-line tool
    bind.dnsutils    # DNS lookup tools (dig, nslookup)
    openssh          # SSH client tools
    sshfs            # FUSE-based SSH filesystem mount
    nmap             # Network scanner
    arp-scan         # ARP packet scanner

    # File & Archive Utilities
    wget
    zip
    unzip
    unrar
    rsync
    aria2

    # CLI Productivity & Text Processing
    ripgrep
    fd
    glow
    jq
    tree
    sqlite
    bc
    qpdf
    tty-clock
    curl
    parallel
    tuxedo

    # Secrets Management
    rbw              # Bitwarden CLI client
    sops             # Mozilla SOPS CLI
    age              # File encryption tool
  ];
}
