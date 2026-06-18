# This is the place for all hardware-agnostic OS settings

{ pkgs, ... }:

{
  time.timeZone = "America/Bogota";
  i18n.defaultLocale = "en_US.UTF-8";

  networking.networkmanager.enable = true;
  virtualisation.docker.enable = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings.PermitRootLogin = "no";
  };

  # Ensure Wayland variables are globally set
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
