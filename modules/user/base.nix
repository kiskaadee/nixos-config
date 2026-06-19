{ pkgs, ...}:

{
  programs = {
    # Version Control
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
      };
    };

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

    # Core Environment Management
    direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };

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

    ### Navigation
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
      extraOptions = ["--group-directories-first" "--header" "--icons"];
    };

    tealdeer = {
      enable = true;
      settings.updates.auto_update = true;
    };

    # Catppuccin syntax-highlighted cat replacement
    bat = {
      enable = true;
    };

    # Bash Shell Config
    bash = {
      enable = true;
      enableCompletion = true;

      shellAliases = {
        zed = "zeditor";
        reload = "exec bash";
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

      bashrcExtra = ''
        ${builtins.readFile ./shell/wayland.sh}
        ${builtins.readFile ./shell/git.sh}
        ${builtins.readFile ./shell/pdf.sh}
        ${builtins.readFile ./shell/quicklinks.sh}
        ${builtins.readFile ./shell/jump.sh}

        # --- Visual Entry ---
        if [[ $- == *i* ]]; then
            fastfetch --logo none
        fi
      '';
    };
  };

  # Custom Catnap-style Fastfetch
  programs.fastfetch = {
    enable = true;
    settings = {
      display = {
        separator = " ";
      };
      modules = [
        { key = "╭───────────╮"; type = "custom"; }
        { key = "│  user    {#keys}│"; type = "title"; format = "{user-name}"; }
        { key = "│ 󰇅 hname   {#keys}│"; type = "title"; format = "{host-name}"; }
        { type = "command"; key = "│ 󱦟 os age  {#keys}│"; keyColor = "magenta"; text = "printf \"\\e[0m%s days\\e[0m\" \"$(( ($(date +%s) - $(stat -c %W /)) / 86400 ))\""; }
        { key = "│ 󰅐 uptime  {#keys}│"; type = "uptime"; }
        { key = "│ {icon} distro  {#keys}│"; type = "os"; }
        { key = "│  kernel  {#keys}│"; type = "kernel"; }
        { key = "│  wm      {#keys}│"; type = "wm"; }
        { key = "│ 󰇄 desktop {#keys}│"; type = "de"; }
        { key = "│  term    {#keys}│"; type = "terminal"; }
        { key = "│  shell   {#keys}│"; type = "shell"; }
        { key = "│ 󰍛 cpu     {#keys}│"; type = "cpu"; showPeCoreCount = true; }
        { key = "│ 󰉉 root    {#keys}│"; type = "disk"; folders = "/"; }
        { key = "│ 󰉉 home    {#keys}│"; type = "disk"; folders = "/home"; }
        { key = "│ 󰉉 media   {#keys}│"; type = "disk"; folders = "/media"; }
        { key = "│  memory  {#keys}│"; type = "memory"; }
        { key = "├───────────┤"; type = "custom"; }
        { key = "│  colors  {#keys}│"; type = "colors"; symbol = "circle"; }
        { key = "╰───────────╯"; type = "custom"; }
      ];
    };
  };

  # Standalone System dependencies
  home.packages = with pkgs; [
    ripgrep fd glow jq tree wl-clipboard sqlite python3 nodejs
    bc qpdf tty-clock grim slurp swappy libnotify uv
  ];
}
