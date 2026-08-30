# 🖥️ Terminal Environment configuration
# Defines user-space preferences for Alacritty, Tmux, and Starship.

{ pkgs, ... }:

let
  # Parse true ASCII Escape (0x1b) and DEL (0x7f) bytes so TOML serialization generates real escape sequences
  esc = builtins.fromJSON "\"\\u001b\"";
  del = builtins.fromJSON "\"\\u007f\"";
in
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
          { key = "Delete";  mods = "Control";       chars = "${esc}[3;5~"; }
          { key = "Back";    mods = "Control";       chars = "${esc}${del}"; }
        ];
      };
    };
  };

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
