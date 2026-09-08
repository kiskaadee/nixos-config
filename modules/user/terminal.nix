{ pkgs, ... }:

{
  # Terminal Multiplexer (Tmux)
  # Allows maintaining persistent shell sessions, window splitting, and tabs.
  programs.tmux = {
    enable = true;
    extraConfig = builtins.readFile ./config/tmux.conf;
  };

  # Cross-Shell Prompt (Starship)
  programs.starship = {
    enable = true;
    enableBashIntegration = true; # Mount prompt configuration inside Bash shells
    settings = builtins.fromTOML (builtins.readFile ./config/starship.toml);
  };
}
