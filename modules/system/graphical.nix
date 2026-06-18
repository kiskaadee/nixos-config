{inputs, pkgs, ...}:

{
  # Enable the native NixOS module
  programs.dms-shell = {
    enable = true;

    # Override the package binary with the latest build from the flake input
    package = inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default;

    # Autostart daemon configuration
    systemd.enable = true;
    systemd.restartIfChanged = true;


    ## see: https://danklinux.com/docs/dgop/
    # dgop.package = inputs.dgop.packages.${pkgs.stdenv.hostPlatform.system}.default;
    enableSystemMonitoring = true;
    enableDynamicTheming = true;
    enableClipboardPaste = true;
  };
}
