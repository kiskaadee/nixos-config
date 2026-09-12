# 🔋 Laptop Hardware, Power & Peripheral Management
# Manages audio (PipeWire), power daemons, Bluetooth, printing, scanning, and virtualization.

{ pkgs, ... }:

{
  # Sound daemon configuration (PipeWire backend with PulseAudio emulation)
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # 🔋 Laptop Power & Battery Management
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;

  # Backlight brightness control utility
  environment.systemPackages = with pkgs; [
    brightnessctl
  ];

  # 📶 Bluetooth Configuration
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  # 🖨️ Printing & Scanning (Epson drivers & Avahi network discovery)
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      epson-escpr
      epson-escpr2
      gutenprint
      gutenprintBin
    ];
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  hardware.sane = {
    enable = true;
    extraBackends = [ pkgs.epsonscan2 ];
  };

  # 🐳 Virtualisation / Docker container daemon
  virtualisation.docker.enable = true;
}
