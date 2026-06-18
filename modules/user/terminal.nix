{ pkgs, ... }:

{
  # GPU-Accelerated Terminal Emulator
  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        padding = { x = 10; y = 10; };
        decorations = "none";
        opacity = 0.95;
      };
      font = {
        normal = { family = "JetBrainsMono Nerd Font"; style = "Regular"; };
        size = 12.0;
      };
      colors = {
        primary = {
          background = "#1e1e2e"; # Catppuccin Mocha Base
          foreground = "#cdd6f4"; # Catppuccin Mocha Text
        };
      };
    };
  };

  # Terminal Multiplexer
  programs.tmux = {
    enable = true;
    shortcut = "a"; # Maps prefix to Ctrl+a
    baseIndex = 1;
    newSession = true;
    escapeTime = 0;
    mouse = true;
    terminal = "tmux-256color";
    plugins = with pkgs.tmuxPlugins; [
      catppuccin
      vim-tmux-navigator
    ];
    extraConfig = ''
      # Enable True Color (24-bit) support for Neovim themes
      set -ag terminal-overrides ",xterm-256color:RGB"

      # Vim-style pane switching
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Status bar position
      set-option -g status-position top
    '';
  };

  # Cross-Shell Prompt
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      add_newline = false;
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
      directory = {
        style = "bold blue";
        truncate_to_repo = true;
      };
    };
  };
}
