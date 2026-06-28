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
  ] (name: { owner = "kiskaadee"; });

  # 2. Generate the unified environment file at runtime in /run/secrets/homeserver.env
  sops.templates."homeserver.env" = {
    owner = "kiskaadee";
    content = lib.generators.toKeyValue {} {
      DOMAIN = "arch-services.mywire.org";
      DOCKER_API_VERSION = "1.40";
      DYNU_API_KEY = config.sops.placeholder.dynu_api_key;
      ACME_EMAIL = config.sops.placeholder.acme_email;
      AUTHELIA_SESSION_SECRET = config.sops.placeholder.authelia_session_secret;
      AUTHELIA_STORAGE_ENCRYPTION_KEY = config.sops.placeholder.authelia_storage_encryption_key;
      AUTHELIA_IDENTITY_VALIDATION_RESET_PASSWORD_JWT_SECRET = config.sops.placeholder.authelia_identity_validation_reset_password_jwt_secret;
    };
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
      WorkingDirectory = "/home/kiskaadee/Deployments/homeserver";
      ExecStart = "${pkgs.docker-compose}/bin/docker-compose --env-file ${config.sops.templates."homeserver.env".path} up -d --remove-orphans";
      ExecStop = "${pkgs.docker-compose}/bin/docker-compose down";
    };
  };
}
