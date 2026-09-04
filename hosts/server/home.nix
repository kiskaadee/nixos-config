# 🏠 Server Host-Specific Home Manager Configuration
# Pure CLI environment for headless server operation.

{ config, pkgs, ... }:

{
  # Server CLI packages
  home.packages = with pkgs; [
    htop
    iotop
    iftop
    ncdu
  ];
}
