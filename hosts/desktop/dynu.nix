# 🌐 Dynu DDNS IP Monitor & Updater Service
# This NixOS module configures a smart, local-first IP change detector.
# It queries public IP providers, maintains a history log of WAN IP rotations,
# and triggers ddclient only when an actual change is detected to prevent API rate limits.

{ config, lib, pkgs, ... }:

let
  # Declaratively read the external Python script into the Nix store at evaluation time
  ipMonitorScript = pkgs.writers.writePython3Bin "dynu-ip-monitor" { } (builtins.readFile ./monitor.py);
in
{
  # 1. Load the encrypted secrets file
  sops.defaultSopsFile = ./secrets.yaml;
  sops.defaultSopsFormat = "yaml";

  # Define the keys to decrypt
  sops.secrets.dynu_user = { };
  sops.secrets.dynu_domain = { };
  sops.secrets.dynu_password = { };

  # Assemble the ddclient config file securely at boot time in /run/secrets/
  # Defaults to owner root:root (which avoids dynamic user evaluation issues)
  sops.templates."ddclient.conf" = {
    content = ''
      # General configuration
      daemon=0
      syslog=yes
      pid=/run/ddclient/ddclient.pid

      # Provider definition using credentials decrypted at runtime
      protocol=dyndns2
      server=api.dynu.com
      login=${config.sops.placeholder.dynu_user}
      password=${config.sops.placeholder.dynu_password}
      ${config.sops.placeholder.dynu_domain}
    '';
  };

  # 2. Enable ddclient and feed it the decrypted configuration template via systemd credentials
  services.ddclient = {
    enable = true;
    configFile = "/run/credentials/ddclient.service/ddclient.conf";
  };

  systemd.services.ddclient = {
    serviceConfig = {
      # Securely load the root-owned secret file into the dynamic ddclient service
      LoadCredential = [ "ddclient.conf:${config.sops.templates."ddclient.conf".path}" ];
    };
  };

  # 3. Disable ddclient's automatic timer.
  # This stops ddclient from polling every 10 minutes on its own.
  systemd.timers.ddclient.enable = false;

  # 4. Define the smart IP change detector service
  systemd.services.dynu-monitor = {
    description = "Dynu DDNS Smart IP Change Monitor";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    path = with pkgs; [
      systemd     # Required for systemctl
    ];
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      Group = "root";
      StateDirectory = "dynu";
      Environment = "HISTORY_FILE=/var/lib/dynu/ip_history.jsonl";
      ExecStart = "${ipMonitorScript}/bin/dynu-ip-monitor";
      TimeoutSec = 30;
      
      # Hardening
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      ReadWritePaths = "/var/lib/dynu";
    };
  };

  # 5. Run the smart IP change monitor periodically (every 30 minutes)
  systemd.timers.dynu-monitor = {
    description = "Run Dynu IP monitor periodically";
    timerConfig = {
      OnBootSec = "5min";
      OnUnitActiveSec = "30min";
      AccuracySec = "1min";
      Persistent = true;
    };
    wantedBy = [ "timers.target" ];
  };
}
