{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Media & Editing
    mpv gimp

    # Cloud & Archiving
    google-cloud-sdk turso-cli wget zip unzip rsync aria2

    # Secrets
    rbw
  ];
}

