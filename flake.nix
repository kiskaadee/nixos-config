{
  description = "Kiskaadee's Declarative NixOS Laptop Workstation";

  # --- External Repositories & Flake Inputs ---
  inputs = {
    # NixOS Unstable channel - official project-hosted zstd tarball
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";

    # Home Manager - manages user-space configurations, dotfiles, and shell environments
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # DankMaterialShell (DMS) - core custom desktop shell environment and panel
    dms = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # dgop - companion system monitoring / daemon utility for DankMaterialShell
    dgop = {
      url = "github:AvengeMedia/dgop";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # dank-greeter - greetd login screen with Dank Material aesthetic
    dank-greeter = {
      url = "github:AvengeMedia/dank-greeter";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # DankCalendar - calendar daemon and UI for DMS
    dankcalendar = {
      url = "github:AvengeMedia/dankcalendar";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # DankSearch - fast indexed filesystem search for DMS
    danksearch = {
      url = "github:AvengeMedia/danksearch";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Zen Browser - modern, lightweight, community-maintained browser
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Antigravity CLI - coding companion and local AI agent helper
    antigravity = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # --- System Outputs ---
  outputs = { self, nixpkgs, home-manager, dms, dgop, dank-greeter, dankcalendar, danksearch, zen-browser, antigravity, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    # --- Linting, Formatting & Static Analysis Checks ---
    # Executed via `nix flake check` or `nix build .#checks.<system>.<check>`
    checks.${system} = {
      # Shell script linting via ShellCheck
      shellcheck = pkgs.runCommand "check-shellcheck" {
        nativeBuildInputs = [ pkgs.shellcheck ];
      } ''
        echo "🐚 [ShellCheck] Checking shell scripts..."
        find ${self} -type f -name "*.sh" -exec shellcheck -s bash {} +
        echo "✅ [ShellCheck] All shell scripts passed!"
        touch $out
      '';

      # Lua linting via luacheck
      luacheck = pkgs.runCommand "check-luacheck" {
        nativeBuildInputs = [ pkgs.luaPackages.luacheck ];
      } ''
        echo "🌙 [Lua] Checking Neovim Lua configuration..."
        luacheck ${self}/home/config/nvim --globals vim
        echo "✅ [Lua] All Lua files passed!"
        touch $out
      '';

      # Python linting via ruff
      ruff-lint = pkgs.runCommand "check-ruff-lint" {
        nativeBuildInputs = [ pkgs.ruff ];
      } ''
        echo "🐍 [Ruff] Running Python linter (ruff check)..."
        ruff check --no-cache ${self}
        echo "✅ [Ruff] All Python files passed linting!"
        touch $out
      '';

      # Python formatting check via ruff
      ruff-format = pkgs.runCommand "check-ruff-format" {
        nativeBuildInputs = [ pkgs.ruff ];
      } ''
        echo "🎨 [Ruff] Checking Python formatting (ruff format)..."
        ruff format --check ${self}
        echo "✅ [Ruff] All Python files properly formatted!"
        touch $out
      '';

      # Python static type analysis via pyright
      pyright = pkgs.runCommand "check-pyright" {
        nativeBuildInputs = [ pkgs.pyright ];
      } ''
        echo "🔬 [Pyright] Running Python type analysis..."
        pyright ${self}
        echo "✅ [Pyright] All Python type checks passed!"
        touch $out
      '';
    };

    nixosConfigurations = {
      # 💻 LAPTOP HOST (Mobile Workstation)
      laptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./system
          inputs.dank-greeter.nixosModules.default
          inputs.dankcalendar.nixosModules.default

          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.kiskaadee = {
              imports = [
                ./home
                inputs.danksearch.homeModules.default
              ];
            };
          }
        ];
      };
    };
  };
}
