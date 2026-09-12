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

    # Cryptographic Secrets management
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Antigravity CLI - coding companion and local AI agent helper
    antigravity = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # --- System Outputs ---
  outputs = { self, nixpkgs, home-manager, dms, dgop, dank-greeter, dankcalendar, danksearch, zen-browser, antigravity, ... }@inputs: {
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
