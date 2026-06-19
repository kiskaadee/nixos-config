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
    shortcut = "a";     # Remaps Tmux prefix key to `Ctrl+a` (similar to GNU Screen)
    baseIndex = 1;      # Sets starting window index to 1 (matching keyboard layout)
    newSession = true;  # Spawns a new session automatically when calling tmux attach
    escapeTime = 0;     # Zero latency for Vim mode transitions (removes Esc lag)
    mouse = true;       # Enables scrollback navigation and pane resizing using the mouse pointer
    terminal = "tmux-256color";
    
    plugins = with pkgs.tmuxPlugins; [
      catppuccin          # Visual styling matching system theme
      vim-tmux-navigator  # Seamless navigation switching between Vim panes and Tmux splits (Ctrl+h/j/k/l)
    ];
    
    extraConfig = ''
      # Enable True Color (24-bit RGB) support inside Tmux for editor colorschemes
      set -ag terminal-overrides ",xterm-256color:RGB"

      # Vim-style bindings for switching between active Tmux panes
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Place status bar at the top of the terminal screen rather than the bottom
      set-option -g status-position top
    '';
  };

  # Cross-Shell Prompt (Starship)
  # A highly customizable, language-aware shell status prompt.
  programs.starship = {
    enable = true;
    enableBashIntegration = true; # Mount prompt configuration inside Bash shells
    settings = {
      add_newline = false; # Do not add empty lines before the prompt line
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
