# ⚙️ Core System Configuration
# Foundational OS settings, bootloader, networking, users, and base system tools.

{ pkgs, inputs, ... }:

{
  # Nix settings & Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.registry.nixpkgs.flake = inputs.nixpkgs;

  # Allow installation of unfree packages
  nixpkgs.config.allowUnfree = true;

  # EFI bootloader configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Host identity & networking
  networking.hostName = "laptop";
  networking.networkmanager.enable = true;

  # Regional and language settings
  time.timeZone = "America/Bogota";
  i18n.defaultLocale = "en_US.UTF-8";

  # Primary user account definition
  users.users.kiskaadee = {
    isNormalUser = true;
    extraGroups = [
      "wheel"           # Administrative access (sudo)
      "docker"          # Container management without sudo
      "networkmanager"  # Network configuration
      "lp"              # Printer management
      "scanner"         # Scanner access
    ];
  };

  # SSH daemon settings
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings.PermitRootLogin = "no";
  };

  # Dynamic binary execution support (for unpatched binaries, language servers, VS Code server)
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib
      zlib
      glib
    ];
  };

  # System-wide administrative tools
  environment.systemPackages = with pkgs; [
    cups-pk-helper
    system-config-printer
    simple-scan
    rclone
    sops
    age
  ];

  # Compatibility state version
  system.stateVersion = "26.05";
}
