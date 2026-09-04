# 🏠 Home Manager Base Configuration Entrypoint
# Shared user environment foundations (Git, Shell, Neovim, Terminal) across all systems.

{ config, pkgs, ... }:

{
  # Import core user-specific modules
  imports = [
    ./modules/user/base.nix       # Core shell configurations, utilities, git aliases, SOPS & age
    ./modules/user/neovim.nix     # Neovim configuration, plugins, tree-sitter, LSP, DAP
    ./modules/user/terminal.nix   # Terminal emulators and multiplexers (Alacritty, Tmux, Starship)
  ];

  # Home directory settings
  home.username = "kiskaadee";
  home.homeDirectory = "/home/kiskaadee";

  # Ensure cargo/bin (and other user binaries) are in the system PATH
  home.sessionPath = [
    "$HOME/.cargo/bin"
  ];

  # The state version of Home Manager that this configuration is compatible with.
  home.stateVersion = "26.05";

  # Enable Home Manager to manage itself
  programs.home-manager.enable = true;
}
