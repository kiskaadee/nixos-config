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
	  last = "log -1 HEAD~1";

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
  };

  # Standalone System dependencies
  home.packages = with pkgs; [
    ripgrep fd glow jq tree wl-clipboard sqlite python3 nodejs
    bc qpdf tty-clock grim slurp swappy libnotify fastfetch
  ];
}
