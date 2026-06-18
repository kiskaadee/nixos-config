{ config, pkgs, ... }:

{
  imports = [
    ./modules/user/base.nix
    ./modules/user/apps.nix
    ./modules/user/graphical.nix
    ./modules/user/terminal.nix
  ];

  home.username = "kiskaadee";
  home.homeDirectory = "/home/kiskaadee";
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;
}
