# 💻 Laptop System Configuration Entrypoint
# Composes the system modules for the mobile workstation.

{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./core.nix
    ./hardware.nix
    ./desktop.nix
  ];
}
