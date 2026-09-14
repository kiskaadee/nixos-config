# 🐚 User Shell, Terminal Multiplexing & Git Environment
# Bash aliases, modular shell scripts, Git, Delta, Gh, Direnv, SSH client, Tmux, Starship, and Fastfetch.

{ pkgs, ... }:

let
  # Hermetic packaging for project-driven persistent terminal workspaces
  tmuxSessionizer = pkgs.writeShellApplication {
    name = "tmux-sessionizer";
    runtimeInputs = with pkgs; [
      bash
      coreutils
      gnused
      gawk
      gnugrep
      fd
      fzf
      tmux
    ];
    text = builtins.readFile ./scripts/tmux-sessionizer.sh;
  };
in
{
  home.packages = [
    tmuxSessionizer
  ];

  programs = {
    # 🌟 Git Version Control Configuration
    git = {
      enable = true;
      settings = {
        user = {
          name = "kiskaadee";
          email = "fcortesbio@gmail.com";
        };
        alias = {
          st = "status";
          co = "checkout";
          br = "branch";

          # Undo/Modify
          unstage = "reset HEAD --";
          amend = "commit --amend --no-edit";
          undo = "reset --soft HEAD~1";

          # Workflow
          sync = "!git fetch -p && git pull";
          main = "checkout main";
          last = "log -1 HEAD";

          # Extra aliases from legacy git-ready
          dc = "!f() { git diff \"$@\" | wl-copy; }; f";
          acp = "!f() { git add -A && git commit -m \"$2\" && git push origin \"$1\"; }; f";
          nuke = "!f() { git reset --hard origin/$(git rev-parse --abbrev-ref HEAD) && git clean -fd; }; f";
          lg = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all";
          standup = "!git log --since='24 hours ago' --oneline --author=\"$(git config user.email)\"";
          gsp = "!git stash && git pull";
          gfo = "fetch origin";
          gcredential = "config credential.helper store";
        };
        core.editor = "nvim";
        init.defaultBranch = "main";
        merge.conflictstyle = "zdiff3";
        pull.rebase = true;

        url."ssh://git@gitea.roadtotech.me:2223/" = {
          insteadOf = [
            "https://gitea.roadtotech.me/"
            "git@gitea.roadtotech.me:"
          ];
        };
      };
    };

    # Syntax-highlighting pager for git
    delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        navigate = true;
        side-by-side = true;
        line-numbers = true;
        hyperlinks = true;
      };
    };

    # ⚡ Direnv - Automatic environment loading for Nix dev shells
    direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };

    # GitHub CLI
    gh = {
      enable = true;
      settings = {
        git_protocol = "ssh";
        editor = "nvim";
        prompt = "enabled";

        aliases = {
          co = "pr checkout";
          pv = "pr review";
          vw = "repo view --web";
        };
      };
    };

    # 🔑 SSH Client Configuration
    ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings = {
        "*" = {
          User = "kiskaadee";
          ServerAliveInterval = 15;
          ServerAliveCountMax = 3;
        };
        laptop = {
          HostName = "192.168.1.32";
          Port = 22;
        };
        server-local = {
          HostName = "192.168.1.36";
          Port = 22;
        };
        server-remote = {
          HostName = "roadtotech.me";
          Port = 2222;
        };
        "gitea.roadtotech.me" = {
          HostName = "gitea.roadtotech.me";
          Port = 2223;
          User = "git";
        };
      };
    };

    # 🗺️ Navigation & Directory Listing
    zoxide = {
      enable = true;
      enableBashIntegration = true;
      options = [
        "--cmd cd"
      ];
    };

    fzf = {
      enable = true;
      enableBashIntegration = true;
    };

    eza = {
      enable = true;
      enableBashIntegration = true;
      extraOptions = [ "--group-directories-first" "--header" "--icons" ];
    };

    tealdeer = {
      enable = true;
      settings.updates.auto_update = true;
    };

    # Catppuccin syntax-highlighted cat replacement
    bat = {
      enable = true;
    };

    # 🖥️ Terminal Multiplexer (Tmux)
    tmux = {
      enable = true;
      extraConfig = builtins.readFile ./config/tmux.conf;
    };

    # 🚀 Cross-Shell Prompt (Starship)
    starship = {
      enable = true;
      enableBashIntegration = true;
      settings = builtins.fromTOML (builtins.readFile ./config/starship.toml);
    };

    # 📊 System Information Dashboard (Fastfetch)
    fastfetch.enable = true;

    # 🐚 Bash Shell Configuration
    bash = {
      enable = true;
      enableCompletion = true;

      shellAliases = {
        zed = "zeditor";
        reload = "exec bash";
        ts = "tmux-sessionizer";
        ff = "fastfetch --logo none";

        # System Navigation
        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";
        "....." = "cd ../../../..";

        # System Administration
        nix-switch = "sudo nixos-rebuild switch --flake ~/Config#$(hostname)";
        sys = "dgop";
        wifi = "nmtui";
        lock = "hyprlock";

        # Audio Control
        vol1 = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.2";
        vol2 = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.4";
        vol3 = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.6";
        vol4 = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.8";
        vol5 = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 1.0";
        volM = "wpctl set-mute @DEFAULT_AUDIO_SINK@ 1";
        volU = "wpctl set-mute @DEFAULT_AUDIO_SINK@ 0";

        # Network Diagnostics
        pgoog = "ping google.com -c 3";

        # Python / Py5
        p5 = "uv run py5-run-sketch";
        p5w = "uv run watchfiles \"py5-run-sketch main.py\"";

        # Editor Shorthand
        v = "nvim";
        clock = "tty-clock";
        ql = "quicklinks";

        # Interactive Jump helper
        zi = "zoxide query -i --preview 'eza --tree --level 2 --color=always {}'";

        # Git Shorthand
        gs = "git status";
        ga = "git add";
        gc = "git commit -m";
        gp = "git push";
        gpl = "git pull";
        gst = "git stash";
        gsp = "git stash && git pull";
        gfo = "git fetch origin";
        gcheck = "git checkout";
        gadc = "git add -A && git diff --staged | wl-copy";
      };

      # Inject modular shell helper scripts directly into .bashrc
      bashrcExtra = ''
        # Ensure Home Manager session variables and user PATH are available in non-login / SSH shells
        [[ -f /etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh ]] && . /etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh
        [[ -f ~/.profile ]] && . ~/.profile
        export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

        ${builtins.readFile ./shell/wayland.sh}     # Wayland clipboard helper (wlc)
        ${builtins.readFile ./shell/git.sh}         # Git workflow automations (gacp, gitignore)
        ${builtins.readFile ./shell/pdf.sh}         # Command line PDF decryption helper
        ${builtins.readFile ./shell/quicklinks.sh}   # Interactive fzf web launcher
        ${builtins.readFile ./shell/jump.sh}        # Directory jumper & interactive fuzzy navigation
        ${builtins.readFile ./shell/todo.sh}        # Todo.txt & tuxedo shortcuts and syntax highlighter
        ${builtins.readFile ./shell/interactive.sh} # Readline word deletion keybindings & fastfetch entry
      '';
    };
  };

  # Link fastfetch config
  home.file.".config/fastfetch/config.jsonc".source = ./config/fastfetch/config.jsonc;
}
