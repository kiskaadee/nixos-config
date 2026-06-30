# 🖥️ Terminal Environment configuration
# Defines user-space preferences for Alacritty, Tmux, and Starship.

{ pkgs, ... }:

{
  # GPU-Accelerated Terminal Emulator (Alacritty)
  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        padding = { x = 10; y = 10; }; # Padding to avoid text hugging window borders
        decorations = "none";          # Frameless windows for clean tiling layouts
        opacity = 0.95;                # Subtle background translucency
      };
      font = {
        # Font settings. (Nerd Font version required for UI icons)
        normal = { family = "JetBrainsMono Nerd Font"; style = "Regular"; };
        size = 12.0;
      };
      colors = {
        primary = {
          background = "#1e1e2e"; # Catppuccin Mocha Base (Dark Theme)
          foreground = "#cdd6f4"; # Catppuccin Mocha Text (Light grey)
        };
      };
    };
  };

  # Terminal Multiplexer (Tmux)
  # Allows maintaining persistent shell sessions, window splitting, and tabs.
  programs.tmux = {
    enable = true;
    escapeTime = 0;     # Remove the default escape delay
    mouse = true;       # Enables scrollback navigation and pane resizing using the mouse pointer
    terminal = "tmux-256color";
    
    plugins = with pkgs.tmuxPlugins; [
      catppuccin          # Visual styling matching system theme
      vim-tmux-navigator  # Seamless navigation switching between Vim panes and Tmux splits (Ctrl+h/j/k/l)
    ];
    
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
