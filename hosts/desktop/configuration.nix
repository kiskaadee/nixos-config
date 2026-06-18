{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/system/graphical.nix ## Inject native DMS configuration
    ];

  nix.settings.experimental-features = ["nix-command" "flakes" ];

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.roboto-mono
  ]; 

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;
  networking.hostName = "desktop";
  virtualisation.docker.enable = true;

  time.timeZone = "America/Bogota";
  i18n.defaultLocale = "en_US.UTF-8";

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  users.users.kiskaadee = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "networkmanager" ];
  }; 

  # programs.firefox.enable = true;
  programs = {
    firefox.enable = true;
    hyprland.enable = true;
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
 
 environment.systemPackages = with pkgs; [
   git
   gh
   vim
   docker
   uv
   neovim
   kitty
]; 

  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PermitRootLogin = "no";
    };
  };

  system.stateVersion = "26.05"; # Did you read the comment?

}


