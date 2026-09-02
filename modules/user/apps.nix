{ inputs, pkgs, ... }:

let
  # Declaratively compile scripts as user utility packages using writeScriptBin
  bundleProject = pkgs.writeScriptBin "bundle-project" (builtins.readFile ./scripts/bundle_project.py);
  recordScript = pkgs.writeScriptBin "record" (builtins.readFile ./scripts/record.sh);
in
{
  home.packages = with pkgs; [
    # Custom Flake injections: Google Antigravity CLI helper
    inputs.antigravity.packages.${pkgs.stdenv.hostPlatform.system}.google-antigravity-cli

    # Local CLI & Workflow utilities
    bundleProject
    recordScript
    wf-recorder # Light recorder for Wayland-based window managers

    # Media, Note-taking & Graphical Tools
    mpv         # Fast, scriptable, keyboard-driven CLI media player
    gimp        # GNU Image Manipulation Program for graphical assets
    imagemagick # Software suite to create, edit, compose, or convert bitmap images
    eyed3       # CLI tool and Python library for working with ID3 tags
    nautilus    # Clean, modern GTK4 graphical file manager for GNOME
    yazi        # Blazing fast console file manager written in Rust
    obsidian    # Markdown-based personal knowledge wiki and note-taking app
    libreoffice # Comprehensive open-source office suite (Writer, Calc, Impress, Draw)

    # Cloud CLI, Database Management & Archive tools
    google-cloud-sdk # GCP administration utilities
    turso-cli        # Management interface for Turso libSQL cloud databases
    postgresql       # PostgreSQL client utilities (psql, pg_dump)
    pgcli            # Command-line client for Postgres with auto-completion
    wget             # Standard network file downloader
    zip              # File archiving utility
    unzip            # Extraction utility for .zip files
    unrar            # Extraction utility for .rar files
    rsync            # Efficient incremental file transfer tool
    aria2            # High-speed multi-protocol download utility

    # API Testing & Development
    httpie           # CLI alternative to curl for REST APIs
    bruno            # Open-source git-friendly GUI REST client
    websocat         # Command-line client for WebSockets (like netcat for ws://)
    grpcurl          # Command-line tool for interacting with gRPC servers

    # Network Diagnostics & Scanning
    openssh          # OpenSSH client and connectivity tools
    sshfs            # FUSE-based filesystem client for mounting remote directories over SSH
    nmap             # Network exploration tool and security / port scanner
    arp-scan         # Address Resolution Protocol packet scanner

    # Python Tooling
    ruff             # Extremely fast Python linter and formatter
    mypy             # Static type checker for Python

    # Rust Tooling
    cargo            # Rust package manager
    rustc            # Rust compiler
    gcc              # GNU Compiler Collection (provides cc linker)

    # Secrets Management
    rbw         # Unofficial command line client for Bitwarden
  ];
}
