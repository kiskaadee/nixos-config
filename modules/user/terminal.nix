# 🖥️ Terminal Environment configuration
# Defines user-space preferences for Alacritty, Tmux, and Starship.

{ pkgs, ... }:

{
  # GPU-Accelerated Terminal Emulator (Alacritty)
  programs.alacritty = {
    enable = true;
    settings = {
      general = {
        import = [
          "~/.config/alacritty/dank-theme.toml"
        ];
      };

      font = {
        normal = { family = "FiraCode Nerd Font"; style = "Regular"; };
        bold = { family = "FiraCode Nerd Font"; style = "Bold"; };
        italic = { family = "FiraCode Nerd Font"; style = "Italic"; };
        bold_italic = { family = "FiraCode Nerd Font"; style = "Bold Italic"; };
        size = 11.0;
      };

      window = {
        decorations = "None";
        padding = { x = 12; y = 12; };
        opacity = 1.0;
      };

      scrolling = {
        history = 3023;
      };

      cursor = {
        style = { shape = "Block"; blinking = "On"; };
        blink_interval = 500;
        unfocused_hollow = true;
      };

      mouse = {
        hide_when_typing = true;
      };

      selection = {
        save_to_clipboard = false;
      };

      bell = {
        duration = 0;
      };

      keyboard = {
        bindings = [
          { key = "C";       mods = "Control|Shift"; action = "Copy";  }
          { key = "V";       mods = "Control|Shift"; action = "Paste"; }
          { key = "N";       mods = "Control|Shift"; action = "SpawnNewInstance"; }
          { key = "Equals";  mods = "Control|Shift"; action = "IncreaseFontSize"; }
          { key = "Minus";   mods = "Control";       action = "DecreaseFontSize"; }
          { key = "Key0";    mods = "Control";       action = "ResetFontSize";    }
          { key = "Enter";   mods = "Shift";         chars = "\n"; }
        ];
      };
    };
  };

  # Terminal Multiplexer (Tmux)
  # Allows maintaining persistent shell sessions, window splitting, and tabs.
  programs.tmux = {
    enable = true;

    baseIndex = 1;      # Number windows starting at 1
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
