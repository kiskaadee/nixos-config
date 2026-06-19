# ⚙️ Hardware-Agnostic Base System Configuration
# This file contains common system configurations shared by all machines (desktop, laptop).

{ pkgs, ... }:

{
  # Regional and Language settings
  time.timeZone = "America/Bogota";
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable network management daemon
  networking.networkmanager.enable = true;

  # Enable virtualisation / Docker container daemon
  virtualisation.docker.enable = true;

  # Sound daemon configuration using modern Pipewire backend
  services.pipewire = {
    enable = true;
    pulse.enable = true; # Enable legacy PulseAudio emulation wrapper
  };

  # Enable printing service
  services.printing.enable = true;

  # Install cups-pk-helper to register PolicyKit and DBus printer configuration policies
  environment.systemPackages = with pkgs; [
    cups-pk-helper
  ];

  # SSH daemon settings for secure remote command execution
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings.PermitRootLogin = "no"; # Security: disable root ssh login
  };

  # 📶 Bluetooth Configuration
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true; # Automatically power on the Bluetooth adapter at boot
  };
  services.blueman.enable = true; # Enable Blueman DBus/Applet service integrations

  # 🚪 Wayland Native TUI Greeter (greetd + tuigreet)
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        # Command executed when the system displays the login prompt.
        # Customized with flags (remember user, asterisks, custom header greeting) for a cleaner login UI.
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --asterisks --greeting '❄️ Declarative NixOS Workstation' --cmd start-hyprland";
      };
    };
  };

  # Clean boot configuration for the greeter
  # Suppresses systemd diagnostic messages on tty1 so the greeter loads cleanly.
  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal";
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };

  # Global environment variables
  # NIXOS_OZONE_WL forces Electron / Chromium applications (like Discord or VSCode)
  # to natively execute under Wayland instead of fallback XWayland.
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
