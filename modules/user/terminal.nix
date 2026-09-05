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
    settings = {
      add_newline = true;
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
      directory = {
        style = "bold blue";
        truncate_to_repo = true; # Hides directory path prefixes when navigating inside Git repositories
      };
    };
  };
}
