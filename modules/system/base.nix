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

  # Wayland Native TUI Greeter
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          # This will default to Hyprland. We will override this on the laptop later.
          command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd start-hyprland";
        };
      };
    };

    # Suppress greeter startup messages for a clean boot
    systemd.services.greetd.serviceConfig = {
      Type = "idle";
      StandardInput = "tty";
      StandardOutput = "tty";
      StandardError = "journal";
      TTYReset = true;
      TTYVHangup = true;
      TTYVTDisallocate = true;
    };

  # Ensure Wayland variables are globally set
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
