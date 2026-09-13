# 🪟 Tmux Reference & Workflow

This document describes the Tmux terminal multiplexer configuration declared in `home/shell.nix` and `home/config/tmux/tmux.conf`.

---

## 1. Core Configuration

- **Prefix Key**: `Ctrl+A` (remapped from standard `Ctrl+B`).
- **Terminal Capabilities**: TrueColor (`tmux-256color`) with RGB support.
- **Mouse Support**: Enabled for scrolling, pane selection, and resizing.
- **Base Index**: Windows and panes start at index `1` instead of `0`.

---

## 2. Keybindings & Controls

### Pane Management
| Shortcut | Action |
| :--- | :--- |
| `Ctrl+A \|` | Split window horizontally. |
| `Ctrl+A -` | Split window vertically. |
| `Ctrl+A h / j / k / l` | Navigate left, down, up, right (Vim style). |
| `Ctrl+A H / J / K / L` | Resize pane left, down, up, right. |
| `Ctrl+A z` | Toggle full-screen zoom on current pane. |
| `Ctrl+A x` | Kill active pane. |

### Window Management
| Shortcut | Action |
| :--- | :--- |
| `Ctrl+A c` | Create new window. |
| `Ctrl+A n` | Next window. |
| `Ctrl+A p` | Previous window. |
| `Ctrl+A 1..9` | Switch directly to window number. |
| `Ctrl+A ,` | Rename current window. |

---

## 3. Persistent Sessions
```bash
# Attach or create session named "dev":
tmux new-session -A -s dev

# List active sessions:
tmux ls

# Detach from session:
Ctrl+A d
```
