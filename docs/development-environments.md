# 💻 Declarative Development Environments

This guide shows how to run isolated project environments using `nix-shell` or `devShells` alongside `direnv` and `uv` to keep the global system environment clean.

---

## ⚡ DevShells and nix-shell

Instead of installing packages globally in [apps.nix](file:///home/kiskaadee/Config/modules/user/apps.nix) for one-off projects, define them per-project.

### 1. Classic `shell.nix` (Nix Channels)
For standard Nix projects, place a `shell.nix` in your project root:
```nix
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    nodejs_20
    yarn
  ];

  shellHook = ''
    echo "Welcome to the Node.js environment!"
  '';
}
```
Run `nix-shell` to drop into this isolated shell with `node` and `yarn` pre-loaded.

### 2. Flake-based `devShell`
For modern Flake projects, declare your `devShell` inside your `flake.nix`:
```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          go
          golangci-lint
        ];
      };
    };
}
```
Run `nix develop` to enter this environment.

---

## 🔄 Automated Shell Loading with `direnv`

`direnv` automatically activates your project-specific environment when you `cd` into its directory.

### Configuration
1.  In your project root, create a file named `.envrc`.
2.  Add one of the following lines based on your setup:
    *   **For classic projects (`shell.nix`):**
        ```bash
        use nix
        ```
    *   **For Flake-based projects (`flake.nix`):**
        ```bash
        use flake
        ```
3.  Allow the environment to load:
    ```bash
    direnv allow
    ```

As soon as you step into the directory, `direnv` populates `$PATH` and other variables with your Nix-defined tools. Leaving the folder unloads them automatically.

---

## 🐍 Python Projects: Nix + `uv` Workflow

To prevent library conflicts and keep the host system clean, combine Nix (for system-level packages/binaries like C libraries, python compilers) with `uv` (for project-level Python packages).

### Recommended Workflow:
1.  **Use Nix (`devShells` or `nix-shell`)** to make Python and system dependencies (like OpenSSL or PostgreSQL drivers) available:
    ```nix
    pkgs.mkShell {
      buildInputs = with pkgs; [
        python311
        uv
        openssl
      ];
    }
    ```
2.  **Use `uv`** inside that environment to manage the virtual environment and install Python-specific libraries cleanly:
    ```bash
    # Create the virtualenv
    uv venv
    
    # Activate the environment
    source .venv/bin/activate
    
    # Install dependencies lightning-fast without polluting system packages
    uv pip install fastapi uvicorn
    ```
3.  **Ensure `.envrc`** loads both the Nix shell and the virtual environment automatically:
    ```bash
    use flake
    layout python
    ```
    This triggers standard Nix tools and sources `.venv/bin/activate` simultaneously upon changing directories.
