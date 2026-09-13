# 📦 Adding Software: Placement & Packaging Guide

This guide defines the architectural decision tree for introducing new software, packages, or services into the workstation configuration.

---

## 1. Package Placement Decision Tree

When adding a tool or application, follow this priority hierarchy:

```text
Is it a kernel module, hardware driver, or root systemd daemon?
   ├── YES ──> system/core.nix or system/hardware.nix
   └── NO
        │
Is it a GUI application or desktop utility?
   ├── YES ──> home/desktop.nix
   └── NO
        │
Is it a compiler, LSP, language runtime, or dev tool?
   ├── YES ──> home/dev.nix
   └── NO  ──> home/shell.nix (CLI tools, shell integration)
```

---

## 2. Directory Placement Reference

| File | Scope | Examples |
| :--- | :--- | :--- |
| **`system/core.nix`** | Root OS fundamentals | Kernel params, OpenSSH daemon, locale, user definitions, Nix-LD |
| **`system/hardware.nix`** | Hardware daemons & root services | PipeWire, Docker, Bluetooth (`bluez`), Power management (`tlp`), CUPS printing |
| **`system/desktop.nix`** | Display server & greeter | Niri compositor enablement, DMS greeter, greetd, system typography/fonts |
| **`home/desktop.nix`** | User graphical applications | Zen Browser, Zed, Obsidian, LibreOffice, GIMP, MPV, grim/slurp, DankSearch |
| **`home/dev.nix`** | Toolchains & development | Rust, Python, Node, Go, language servers (pyright, rust-analyzer), Antigravity, sops/age CLI |
| **`home/shell.nix`** | Interactive shell & CLI tools | Bash, Tmux, Git, Starship, Delta, Fastfetch, ripgrep, fzf, bat, jq, eza |

---

## 3. Package Syntax Styles: When to Use What

### Pattern A: Simple Package List (`home.packages`)
Use when the tool requires no specialized shell wrappers or generated dotfiles:

```nix
# Example in home/desktop.nix or home/shell.nix
home.packages = with pkgs; [
  ripgrep
  htop
  jq
];
```

### Pattern B: Home Manager Program Module (`programs.<name>`)
Use when Home Manager provides an upstream module that configures shell completions, systemd user services, or dotfiles:

```nix
# Example in home/shell.nix
programs.tmux = {
  enable = true;
  shortcut = "a";
  terminal = "tmux-256color";
};
```

*Advantage*: Modules handle initialization scripts, environment variables, and shell aliases automatically.

### Pattern C: Custom Compiled Scripts (`pkgs.writeScriptBin`)
Use when distributing a bespoke script or python tool into the user's `$PATH`:

```nix
# Example in home/desktop.nix
let
  recordScript = pkgs.writeScriptBin "record" (builtins.readFile ./scripts/record.sh);
in
{
  home.packages = [ recordScript ];
}
```

---

## 4. Handling Unfree Software

Unfree packages are permitted globally in `system/core.nix` and `home/default.nix`:

```nix
nixpkgs.config.allowUnfree = true;
```

You do not need to configure per-package unfree predicate overrides unless isolating builds.

---

## 5. What NOT to Add to this Repository

1. **Homelab Server Daemons**: Production services (Traefik, DDNS monitors, public web services, databases) belong exclusively in the [`Core`](file:///home/kiskaadee/Projects/active/homelab/Core) repository.
2. **Ephemeral Project Dependencies**: Rather than polluting `home/dev.nix` with temporary project dependencies, create a dedicated `flake.nix` or `shell.nix` in that project's directory and use `direnv`.
