# 📦 User Applications Configuration
# This file declares standalone user-space binaries managed by Home Manager.

{ inputs, pkgs, ... }:

{
  home.packages = with pkgs; [
    # Custom Flake injections: Google Antigravity CLI helper
    inputs.antigravity.packages.${pkgs.stdenv.hostPlatform.system}.google-antigravity-cli

    # Media & Image editing
    mpv         # Fast, scriptable, keyboard-driven CLI media player
    gimp        # GNU Image Manipulation Program for graphical assets

    # Cloud CLI, Database Management & Archive tools
    google-cloud-sdk # GCP administration utilities
    turso-cli        # Management interface for Turso libSQL cloud databases
    postgresql       # PostgreSQL client utilities (psql, pg_dump)
    pgcli            # Command-line client for Postgres with auto-completion
    wget             # Standard network file downloader
    zip              # File archiving utility
    unzip            # Extraction utility for .zip files
    rsync            # Efficient incremental file transfer tool
    aria2            # High-speed multi-protocol download utility

    # API Testing & Development
    httpie           # CLI alternative to curl for REST APIs
    bruno            # Open-source git-friendly GUI REST client

    # Python Tooling
    ruff             # Extremely fast Python linter and formatter
    mypy             # Static type checker for Python

    # Secrets Management
    rbw         # Unofficial command line client for Bitwarden
  ];
}
