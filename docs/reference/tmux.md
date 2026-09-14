# 🪟 Tmux Reference & Workflow

This document describes the Tmux terminal multiplexer configuration declared in `home/shell.nix` and `home/config/tmux.conf`.

---

## 1. Core Configuration

- **Prefix Key**: `Ctrl+Space` (`C-Space`, remapped from standard `Ctrl+B`).
- **Terminal Capabilities**: TrueColor (`tmux-256color`) with RGB support and extended keys enabled.
- **Mouse Support**: Enabled for scrolling, pane selection, and resizing.
- **Base Index**: Windows and panes start at index `1` (matching keyboard row `1..9`).
- **Escape Time**: `0ms` (zero delay for responsive escape-key behavior in Vim/Neovim).
- **Clipboard**: OSC 52 integration enabled (`set -s set-clipboard on`), syncing clipboard locally and over SSH.

---

## 2. Keybindings & Controls

### Smart Neovim / Tmux Navigation (No Prefix Required)
Thanks to `vim-tmux-navigator` integration, you can navigate seamlessly between Vim splits and Tmux panes without pressing the prefix key:

| Shortcut | Action |
| :--- | :--- |
| `Ctrl+h` | Move to left pane / Vim split. |
| `Ctrl+j` | Move to down pane / Vim split. |
| `Ctrl+k` | Move to up pane / Vim split. |
| `Ctrl+l` | Move to right pane / Vim split. |

*(Fallback navigation using prefix: `Ctrl+Space h/j/k/l`)*

### Pane Management (Prefix: `Ctrl+Space`)
| Shortcut | Action |
| :--- | :--- |
| `Ctrl+Space \|` | Split window horizontally (opens in current working directory). |
| `Ctrl+Space -` | Split window vertically (opens in current working directory). |
| `Ctrl+Space H / J / K / L` | Resize pane left, down, up, right by 5 cells. |
| `Ctrl+Space z` | Toggle full-screen zoom on active pane. |
| `Ctrl+Space x` | Kill active pane. |

### Window Management (Prefix: `Ctrl+Space`)
| Shortcut | Action |
| :--- | :--- |
| `Ctrl+Space c` | Create new window. |
| `Ctrl+Space n` | Next window. |
| `Ctrl+Space p` | Previous window. |
| `Ctrl+Space 1..9` | Switch directly to window index `1..9`. |
| `Ctrl+Space ,` | Rename current window. |
| `Ctrl+Space r` | Reload `~/.config/tmux/tmux.conf`. |

### Copy Mode (Vi-Style)
| Shortcut | Action |
| :--- | :--- |
| `Ctrl+Space Escape` | Enter copy mode. |
| `v` | Begin text selection (in copy mode). |
| `Ctrl+v` | Toggle rectangle / block selection. |
| `y` | Copy selection to system clipboard (via OSC 52) and exit copy mode. |

---

## 3. Persistent Sessions

```bash
# Attach or create session named "dev":
tmux new-session -A -s dev

# List active sessions:
tmux ls

# Detach from active session:
Ctrl+Space d
```
