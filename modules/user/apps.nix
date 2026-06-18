{ inputs, pkgs, ... }:

{
  home.packages = with pkgs; [
    # Custom Flake injections
    inputs.antigravity.packages.${pkgs.stdenv.hostPlatform.system}.google-antigravity-cli

    # Media & Editing
    mpv gimp

    # Cloud & Archiving
    google-cloud-sdk turso-cli wget zip unzip rsync aria2

    # Secrets
    rbw
  ];
}
