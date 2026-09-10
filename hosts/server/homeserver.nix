# 🌐 Homeserver Core Environment Secrets & Systemd service configuration
# This NixOS module manages secrets and the systemd lifecycle for the core homeserver stack.

{ config, lib, pkgs, ... }:

{
  # 1. Load the encrypted secrets file
  sops.defaultSopsFile = ./secrets.yaml;
  sops.defaultSopsFormat = "yaml";

  # Define the keys to decrypt from secrets.yaml
  sops.secrets = lib.genAttrs [
    "dynu_api_key"
    "acme_email"
    "authelia_session_secret"
    "authelia_storage_encryption_key"
    "authelia_identity_validation_reset_password_jwt_secret"
    "authelia_user_kiskaadee_password_hash"
  ] (name: { owner = "kiskaadee"; });

  # 2. Generate the unified environment file at runtime in /run/secrets/homeserver.env
  sops.templates."homeserver.env" = {
    owner = "kiskaadee";
    content = lib.generators.toKeyValue {} {
      DOMAIN = "roadtotech.me";
      DOCKER_API_VERSION = "1.40";
      DYNU_API_KEY = config.sops.placeholder.dynu_api_key;
      ACME_EMAIL = config.sops.placeholder.acme_email;
      AUTHELIA_SESSION_SECRET = config.sops.placeholder.authelia_session_secret;
      AUTHELIA_STORAGE_ENCRYPTION_KEY = config.sops.placeholder.authelia_storage_encryption_key;
      AUTHELIA_IDENTITY_VALIDATION_RESET_PASSWORD_JWT_SECRET = config.sops.placeholder.authelia_identity_validation_reset_password_jwt_secret;
    };
  };

  # Generate the declarative Authelia user database file at runtime in /run/secrets/users.yml
  sops.templates."users.yml" = {
    owner = "kiskaadee";
    content = ''
      users:
        kiskaadee:
          displayname: "Kiskaadee"
          password: "${config.sops.placeholder.authelia_user_kiskaadee_password_hash}"
          email: "fcortesbio@gmail.com"
          groups:
            - admins
            - dev
    '';
  };

  # 3. Define the declarative systemd service to manage the homeserver container stack
  systemd.services.homeserver-core = {
    description = "Homeserver Core Stack (Traefik, Authelia, Homepage, etc.)";
    after = [ "network-online.target" "docker.service" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      WorkingDirectory = "/home/kiskaadee/Core";
      ExecStart = "${pkgs.docker-compose}/bin/docker-compose --env-file ${config.sops.templates."homeserver.env".path} up -d --remove-orphans";
      ExecStop = "${pkgs.docker-compose}/bin/docker-compose down";
    };
  };

  # 4. Declarative Dynamic GitOps Webhook Service (Internal Port 9000)
  systemd.services.homelab-gitops = {
    description = "Dynamic Homelab GitOps Webhook Dispatcher";
    after = [ "network-online.target" "docker.service" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    path = with pkgs; [ git docker docker-compose python3 coreutils bash openssh ];

    serviceConfig = {
      Type = "simple";
      User = "kiskaadee";
      WorkingDirectory = "/home/kiskaadee/Core";
      ExecStart = "${pkgs.webhook}/bin/webhook -hooks ${pkgs.writeText "hooks.json" (builtins.toJSON [
        {
          id = "deploy";
          execute-command = "/home/kiskaadee/Core/scripts/gitops_dispatcher.py";
          pass-arguments-to-command = [
            { source = "entire-payload"; }
          ];
          command-working-directory = "/home/kiskaadee/Core";
          response-message = "Deployment payload dispatched successfully.";
        }
      ])} -port 9000 -verbose";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };

  # 5. Open ports in the firewall for Traefik, Gitea SSH, and GitOps Webhook Receiver
  networking.firewall.allowedTCPPorts = [ 80 443 2223 9000 ];
}
