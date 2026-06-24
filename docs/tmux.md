# 🎛️ Tmux Environment & Cheat Sheet

This repository configures **Tmux** declaratively via Home Manager in [terminal.nix](file:///home/kiskaadee/Config/modules/user/terminal.nix#L30). The configuration is optimized for speed, Vim keybindings, and seamless split-pane navigation.

---

## 🔑 Core Settings

*   **Prefix Key**: Remapped from `Ctrl+b` to **`Ctrl+a`** (easier to reach).
*   **Status Bar**: Anchored to the **top** of the terminal window.
*   **Base Index**: Windows and panes start indexing at **`1`** (aligning with your physical keyboard numbers).
*   **Mouse Support**: Enabled. You can scroll, click to select panes, and drag splits to resize them.
*   **Zero Esc-Lag**: Keyboard escape latency is set to `0ms` (essential for vim editing response).

---

## 🧭 Seamless Neovim Navigation

The configuration loads the **`vim-tmux-navigator`** plugin. This allows you to navigate between Vim/Neovim split windows and Tmux splits using the same hotkeys **without pressing the prefix key**:

| Shortcut | Action |
| :--- | :--- |
| `Ctrl + h` | Focus pane/split to the **left** |
| `Ctrl + j` | Focus pane/split **down** |
| `Ctrl + k` | Focus pane/split **up** |
| `Ctrl + l` | Focus pane/split to the **right** |

---

## 📋 Common Tmux Keybindings

For the following shortcuts, press your prefix key **`Ctrl+a`** first, release it, then press the shortcut key.

### Sessions & Windows
| Key | Action |
| :--- | :--- |
| `d` | **Detach** from the current session (keeps it running in the background) |
| `c` | Create a **new window** (tab) |
| `,` | **Rename** the current window |
| `&` | Kill the current window |
| `1` - `9` | Switch to window by index number |

### Splits & Panes
| Key | Action |
| :--- | :--- |
| `"` | Split pane **horizontally** (top/bottom) |
| `%` | Split pane **vertically** (left/right) |
| `x` | Close/kill the current pane |
| `z` | **Zoom** the current pane to full screen (press again to restore) |
| `h` / `j` / `k` / `l` | Vim-style switch focus left/down/up/right (alternative to Ctrl+direction) |

---

## 🖥️ Command Line Session Management

Manage your persistent background sessions directly from your shell:

```bash
# Start a new named session
tmux new -s my-session-name

# List all active background sessions
tmux ls

# Attach to an existing session
tmux a -t my-session-name
# Or attach to the last active session:
tmux a

# Kill a session
tmux kill-session -t my-session-name
```
