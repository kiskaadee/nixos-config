# 🏠 Laptop Host-Specific Home Manager Configuration
# Graphical workstation environment for Niri-powered mobile laptop.

{ config, pkgs, ... }:

{
  imports = [
    ../../modules/user/apps.nix
    ../../modules/user/graphical.nix
  ];
}
