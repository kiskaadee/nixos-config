# 🎨 Graphical Environment System Module
# Configures system-wide services and integrations for DankMaterialShell (DMS).

{inputs, pkgs, ...}:

{
  # Configure the DMS graphical helper/shell service daemon.
  # DMS handles background management, panels, and notifications.
  programs.dms-shell = {
    enable = true;

    # Override standard nixpkgs package binary with the bleeding-edge flake output.
    package = inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default;

    # Run the DMS daemon as a Systemd user service.
    # Automatically restarts the daemon whenever the NixOS configuration changes.
    systemd.enable = true;
    systemd.restartIfChanged = true;

    # DMS System Options
    # Refer to documentation: https://danklinux.com/docs/dgop/
    enableSystemMonitoring = true; # Enables daemon hooks for gathering memory, CPU, and disk metrics
    enableDynamicTheming    = true; # Automatically applies system-wide material palettes to shells and apps
    enableClipboardPaste    = true; # Bridges terminal and Wayland clipboard buffers seamlessly
  };

  # 🚪 Dank Material Shell Greeter (dank-greeter + greetd)
  # Uses niri as the compositor for rendering the login screen
  programs.dms-greeter = {
    enable = true;
    compositor.name = "niri";
    configHome = "/home/kiskaadee";
  };

  # 📅 DankCalendar Daemon & UI
  # Provides calendar integration (Local, CalDAV, Google, Microsoft) for DMS
  programs.dank-calendar = {
    enable = true;
    systemd.enable = true;
    systemd.target = "graphical-session.target";
  };
}

