# 🏠 Home Manager Workstation Profile Entrypoint
# User-level environment for kiskaadee on the laptop workstation.

{ ... }:

{
  imports = [
    ./desktop.nix
    ./dev.nix
    ./shell.nix
  ];

  # User identity & home path
  home.username = "kiskaadee";
  home.homeDirectory = "/home/kiskaadee";

  # User binary search paths
  home.sessionPath = [
    "$HOME/.cargo/bin"
    "$HOME/.local/bin"
  ];

  # Compatibility state version
  home.stateVersion = "26.05";

  # Enable Home Manager self-management
  programs.home-manager.enable = true;
}
