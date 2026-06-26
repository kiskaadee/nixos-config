# 🌐 Traefik Deployments Environment Secrets configuration
# This NixOS module manages secrets and environment variables for the unified apps in /traefik-deployments

{ config, lib, pkgs, ... }:

{
  # Load the encrypted secrets file
  sops.defaultSopsFile = ./secrets.yaml;
  sops.defaultSopsFormat = "yaml";

  # Define the keys to decrypt from secrets.yaml (avoiding repeating the owner boilerplate)
  sops.secrets = lib.genAttrs [
    "learning_turso_db_url"
    "learning_turso_auth_token"
    "mongo_root_username"
    "mongo_root_password"
    "ollama_api_key"
    "postgres_user"
    "postgres_password"
    "postgres_db"
  ] (name: { owner = "kiskaadee"; });

  # Generate the unified environment file at runtime in /run/secrets/traefik-deployments.env
  sops.templates."traefik-deployments.env" = {
    owner = "kiskaadee";
    content = let
      coreConfig = {
        PROXY_NETWORK = "proxy-net";
        CERT_RESOLVER = "myresolver";
        DOMAIN_SUFFIX = "arch-services.mywire.org";
      };

      excalidrawConfig = {
        EXCALIDRAW_DOMAIN = "excalidraw.arch-services.mywire.org";
      };

      giteaConfig = {
        GITEA_DOMAIN = "gitea.arch-services.mywire.org";
        GITEA_SSH_DOMAIN = "gitea.arch-services.mywire.org";
        GITEA_AUTH_MIDDLEWARE = "https-redirect@docker";
      };

      jellyfinConfig = {
        JELLYFIN_SERVICE_NAME = "jellyfin";
        JELLYFIN_CONTAINER_NAME = "jellyfin";
        JELLYFIN_IMAGE_TAG = "latest";
        JELLYFIN_DOMAIN = "jellyfin.arch-services.mywire.org";
        JELLYFIN_TZ = "UTC";
        JELLYFIN_PUID = "1000";
        JELLYFIN_PGID = "1000";
        JELLYFIN_MEDIA_PATH = "/media";
        JELLYFIN_HTTP_ENTRYPOINT = "web";
        JELLYFIN_HTTPS_ENTRYPOINT = "websecure";
        JELLYFIN_RATE_LIMIT_AVG = "100";
        JELLYFIN_RATE_LIMIT_BURST = "50";
      };

      learningConfig = {
        LEARNING_SERVICE_NAME = "learning-hub";
        LEARNING_DOMAIN = "learning.arch-services.mywire.org";
        LEARNING_APP_PORT = "8000";
        LEARNING_SOCKET_PROXY_NETWORK = "socket-net";
        LEARNING_DOCKER_HOST = "tcp://socket-proxy:2375";
        TURSO_DATABASE_URL = config.sops.placeholder.learning_turso_db_url;
        TURSO_AUTH_TOKEN = config.sops.placeholder.learning_turso_auth_token;
      };

      mermaidConfig = {
        MERMAID_DOMAIN = "mermaid.arch-services.mywire.org";
        MERMAID_SERVICE_NAME = "mermaid";
      };

      mongoConfig = {
        MONGO_ROOT_USERNAME = config.sops.placeholder.mongo_root_username;
        MONGO_ROOT_PASSWORD = config.sops.placeholder.mongo_root_password;
        MONGO_DOMAIN = "mongodb.arch-services.mywire.org";
      };

      postgresConfig = {
        POSTGRES_USER = config.sops.placeholder.postgres_user;
        POSTGRES_PASSWORD = config.sops.placeholder.postgres_password;
        POSTGRES_DB = config.sops.placeholder.postgres_db;
        POSTGRES_DOMAIN = "pgsql.arch-services.mywire.org";
      };

      ollamaConfig = {
        OLLAMA_DOMAIN = "ollama.arch-services.mywire.org";
        OLLAMA_API_KEY = config.sops.placeholder.ollama_api_key;
        OLLAMA_REPLICAS = "1";
        OLLAMA_DATA_VOLUME = "ollama_data";
      };

      allConfig = coreConfig 
        // excalidrawConfig 
        // giteaConfig 
        // jellyfinConfig 
        // learningConfig 
        // mermaidConfig 
        // mongoConfig 
        // postgresConfig 
        // ollamaConfig;
    in
      lib.generators.toKeyValue {} allConfig;
  };
}
