# 🐚 Shell & CLI Environment Reference

This document catalogs the interactive Bash shell configuration, Starship prompt integration, and custom helper scripts managed in `home/shell.nix` and `home/shell/`.

---

## 1. Shell Configuration Architecture

The shell environment is modularized:
- **`home/shell.nix`**: Core Home Manager bash module, aliases, environment exports, and tool integrations (Direnv, Starship, Fastfetch).
- **`home/shell/`**: Domain-specific sourced shell scripts:
  - `git.sh`: Git helper functions and branch utilities.
  - `jump.sh`: Directory navigation and quick jumping.
  - `pdf.sh`: PDF compilation, viewing, and OCR helpers.
  - `quicklinks.sh`: Shortcuts to primary project directories.
  - `todo.sh`: Lightweight terminal task tracking.
  - `wayland.sh`: Wayland session environment variables.

---

## 2. Shell Aliases & Shortcuts

### System & Navigation
| Alias | Target Command | Purpose |
| :--- | :--- | :--- |
| `c` | `clear` | Clear terminal scrollback. |
| `q` | `exit` | Close shell session. |
| `ls` | `eza --icons` | Modern directory listing. |
| `ll` | `eza -la --icons` | Detailed directory listing. |
| `tree` | `eza --tree --icons` | Directory tree visualization. |
| `cat` | `bat --paging=never` | Syntax-highlighted file viewing. |

### Git & Workflows
| Alias | Target Command | Purpose |
| :--- | :--- | :--- |
| `gs` | `git status` | Quick working tree status. |
| `gd` | `git diff` | Syntax-highlighted git diff via Delta. |
| `gl` | `git log --oneline --graph --decorate` | Compact visual commit graph. |

---

## 3. Modular Shell Scripts (`home/shell/`)

All files in `home/shell/*.sh` are automatically sourced during interactive bash startup:

```bash
for script in ~/.config/bash/*.sh; do
  [ -r "$script" ] && source "$script"
done
```

### Adding a New Shell Extension
To add new bash functions or aliases:
1. Create a new `.sh` file under `home/shell/<topic>.sh`.
2. Add the source link in `home/shell.nix`:
   ```nix
   home.file.".config/bash/<topic>.sh".source = ./shell/<topic>.sh;
   ```
3. Rebuild and restart the shell.
