# ⚙️ Hardware-Agnostic Base System Configuration
# This file contains common system configurations shared by all machines (desktop, laptop).

{ pkgs, ... }:

{
  # Regional and Language settings
  time.timeZone = "America/Bogota";
  i18n.defaultLocale = "en_US.UTF-8";

  # Allow installation of unfree packages (e.g., Obsidian)
  nixpkgs.config.allowUnfree = true;

  # Enable network management daemon
  networking.networkmanager.enable = true;

  # Enable virtualisation / Docker container daemon
  virtualisation.docker.enable = true;

  # Sound daemon configuration using modern Pipewire backend
  services.pipewire = {
    enable = true;
    pulse.enable = true; # Enable legacy PulseAudio emulation wrapper
  };

  # 🖨️ Printing & Scanning configuration (with Epson drivers & Avahi network discovery)
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      epson-escpr
      epson-escpr2
      gutenprint
      gutenprintBin
    ];
  };

  # Enable mDNS / Zeroconf discovery for Wi-Fi printers
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # SANE scanner support (includes Epson scanner backend)
  hardware.sane = {
    enable = true;
    extraBackends = [ pkgs.epsonscan2 ];
  };

  # System-wide packages
  environment.systemPackages = with pkgs; [
    cups-pk-helper
    system-config-printer
    simple-scan
    rclone
    sops
    age
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

  # 🚪 Greetd base configuration
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        user = "kiskaadee";
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
