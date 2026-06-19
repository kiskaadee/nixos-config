# 🏠 Home Manager Configuration Entrypoint
# This module defines the user-space environment config for 'kiskaadee'
# across all systems (desktop and laptop).

{ config, pkgs, ... }:

{
  # Import user-specific modules
  imports = [
    ./modules/user/base.nix       # Core shell configurations, utilities, git aliases
    ./modules/user/apps.nix       # User applications (e.g. Zen Browser, media players, SDKs)
    ./modules/user/graphical.nix  # Graphical user apps (Neovim configuration, window manager targets)
    ./modules/user/terminal.nix   # Terminal emulators and multiplexers (Alacritty, Tmux, Starship)
  ];

  # Home directory settings
  home.username = "kiskaadee";
  home.homeDirectory = "/home/kiskaadee";

  # The state version of Home Manager that this configuration is compatible with.
  # Avoid changing this value even if you upgrade NixOS.
  home.stateVersion = "26.05";

  # Enable Home Manager to manage itself (creates `home-manager` command)
  programs.home-manager.enable = true;
}
