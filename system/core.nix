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

  # 🛡️ Dynamic Firewall for Trusted Home Wi-Fi
  # Automatically marks the Wi-Fi interface as fully trusted (accepting all incoming ports)
  # ONLY when connected to the trusted home Wi-Fi network ("VICTORIA"), removing the friction of
  # managing arbitrary development ports. Restores the strict default firewall immediately upon
  # disconnecting or connecting to any public / untrusted network.
  networking.firewall.extraCommands = ''
    iptables -N nixos-fw-home 2>/dev/null || true
    iptables -C nixos-fw -j nixos-fw-home 2>/dev/null || iptables -I nixos-fw 1 -j nixos-fw-home
    ip6tables -N nixos-fw-home 2>/dev/null || true
    ip6tables -C nixos-fw -j nixos-fw-home 2>/dev/null || ip6tables -I nixos-fw 1 -j nixos-fw-home
  '';

  networking.networkmanager.dispatcherScripts = [
    {
      source = pkgs.writeShellScript "nm-trusted-wifi-firewall" ''
        IFACE="$1"
        ACTION="$2"
        TRUSTED_SSID="VICTORIA"

        IPT="${pkgs.iptables}/bin/iptables"
        IP6T="${pkgs.iptables}/bin/ip6tables"
        LOGGER="${pkgs.util-linux}/bin/logger"

        manage_chain() {
          local cmd="$1"
          $cmd -N nixos-fw-home 2>/dev/null || true
          $cmd -C nixos-fw -j nixos-fw-home 2>/dev/null || $cmd -I nixos-fw 1 -j nixos-fw-home
        }

        manage_chain "$IPT"
        manage_chain "$IP6T"

        if [ "$ACTION" = "up" ] && [ "$CONNECTION_ID" = "$TRUSTED_SSID" ]; then
          $IPT -F nixos-fw-home
          $IPT -A nixos-fw-home -i "$IFACE" -j ACCEPT

          $IP6T -F nixos-fw-home
          $IP6T -A nixos-fw-home -i "$IFACE" -j ACCEPT

          $LOGGER -t nm-firewall "Connected to trusted network $TRUSTED_SSID: trusted interface $IFACE (all incoming ports accepted)"
        elif [ "$ACTION" = "down" ] || [ -n "$CONNECTION_ID" -a "$CONNECTION_ID" != "$TRUSTED_SSID" ]; then
          $IPT -F nixos-fw-home
          $IP6T -F nixos-fw-home
          $LOGGER -t nm-firewall "Untrusted or disconnected network ($CONNECTION_ID): restored strict firewall"
        fi
      '';
      type = "basic";
    }
  ];

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
      openssl
    ];
  };

  # 🧠 Memory & Swap Management
  # Compressed in-RAM swap prevents synchronous page thrashing and lockups under high memory pressure.
  zramSwap = {
    enable = true;
  };

  # 🛡️ Early OOM Killer Daemon
  # Intervenes proactively before the kernel freezes, protecting compositor and core session services.
  services.earlyoom = {
    enable = true;
    enableNotifications = true;
    extraArgs = [
      "--avoid" "^(niri|dms|systemd|sshd)$"
    ];
  };

  # 🦠 ClamAV Antivirus Database Updater
  # Automatically keeps virus definitions updated in /var/lib/clamav via systemd timer
  # without running the continuous memory-heavy scanner daemon in RAM. Provides clamscan system-wide.
  services.clamav.updater.enable = true;

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
