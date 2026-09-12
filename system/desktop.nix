# 🎨 System Desktop Environment & Graphical Stack
# Niri window manager, DankMaterialShell (DMS), greetd login, fonts, and Wayland session flags.

{ pkgs, inputs, ... }:

{
  # Graphical Compositor (Niri window manager)
  programs.niri.enable = true;

  # DankMaterialShell (DMS) graphical helper/shell daemon
  programs.dms-shell = {
    enable = true;
    package = inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default;
    systemd.enable = true;
    systemd.restartIfChanged = true;
    enableSystemMonitoring = true;
    enableDynamicTheming = true;
    enableClipboardPaste = true;
  };

  # DMS Greeter (dank-greeter + greetd)
  programs.dms-greeter = {
    enable = true;
    compositor.name = "niri";
    configHome = "/home/kiskaadee";
  };

  # DankCalendar Daemon & UI
  programs.dank-calendar = {
    enable = true;
    systemd.enable = true;
    systemd.target = "graphical-session.target";
  };

  # Greetd base service configuration
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        user = "kiskaadee";
      };
    };
  };

  # Clean boot configuration for the greeter (suppresses tty1 diagnostic messages)
  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal";
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };

  # System-wide typography & fonts
  fonts.packages = with pkgs; [
    inter
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.roboto-mono
  ];

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [ "Fira Code" ];
      sansSerif = [ "Inter" ];
    };
  };

  # Wayland execution flags for Electron / Chromium applications
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
