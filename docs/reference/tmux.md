# 🪟 Terminal Workspaces & Tmux Reference

This reference covers the operational controls, keybindings, and workflows for persistent workspaces and terminal multiplexing on the `laptop` workstation.

---

## 1. Terminal Workflows

| Shortcut | Action | Semantics |
| :--- | :--- | :--- |
| `Mod+Return` | **Alacritty Shell** | Opens a standard shell immediately. Ephemeral, isolated, non-persistent. |
| `Mod+T` | **Workspace Selector** | Opens Alacritty running the interactive sessionizer (`ts`). Exiting `fzf` with `Esc` closes the window cleanly. |

---

## 2. Sessionizer CLI (`ts`)

The `ts` utility (`tmux-sessionizer`) connects directly to persistent tmux workspaces:

```bash
# Interactive fuzzy selector (shows session name and path)
ts

# Open a workspace by name (exact or normalized)
ts config
ts brain
ts core
ts bitetrack-api

# Open a workspace by unique substring
ts magnet        # Resolves to MagNetFlix

# Open a workspace by direct filesystem path
ts ~/Config
ts ~/Projects/active/nekoweb
```

### Argument Resolution Order
When an argument is provided (`ts <arg>`), it resolves in this exact order:
1. **Existing directory**: Canonicalizes path via `realpath`.
2. **Exact session name**: Matches normalized session name.
3. **Exact directory basename**: Matches directory name.
4. **Unique substring**: Matches against names and paths.

*Ambiguous matches fail safely with an error and candidate list rather than guessing.*

---

## 3. Workspace Discovery

The sessionizer automatically indexes workspaces from:

- **Explicit Workspaces**:
  - `~/Config`
  - `~/Brain`
  - `~/Homelab/Core`
- **Git Repositories**:
  - Discovered beneath `~/Projects` and `~/Homelab` (depth 4).

*Any directory passed directly as a path (`ts <path>`) works immediately without needing to be under discovery roots.*

---

## 4. Tmux Behavior & Persistence

- **Outside Tmux**: Running `ts` creates or attaches to the session.
- **Inside Tmux**: Running `ts` switches the active client (`switch-client`) without nesting sessions.
- **Session State**: New sessions start in the workspace folder. Reconnecting to an existing session preserves your current working directory, open files, and terminal buffers.
- **Persistence**: Closing an Alacritty window leaves background jobs and tmux sessions running. Reconnect at any time by pressing `Mod+T` or running `ts <name>`.

---

## 5. Tmux Controls & Keybindings

- **Prefix Key**: `Ctrl+Space` (`C-Space`)
- **Terminal Capabilities**: TrueColor (`tmux-256color`) with RGB support and extended keys enabled.
- **Mouse Support**: Enabled for scrolling, pane selection, and resizing.

### Smart Neovim / Tmux Navigation (No Prefix Required)
Navigate between Neovim splits and Tmux panes seamlessly using `Ctrl+h/j/k/l`:

| Shortcut | Action |
| :--- | :--- |
| `Ctrl+h` | Move to left pane / Neovim split. |
| `Ctrl+j` | Move to down pane / Neovim split. |
| `Ctrl+k` | Move to up pane / Neovim split. |
| `Ctrl+l` | Move to right pane / Neovim split. |

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

## 6. Verification Commands

```bash
# Validate flake metadata & checks
nix flake check

# Build laptop configuration without switching
nix build .#nixosConfigurations.laptop.config.system.build.toplevel --no-link
```

*(For architectural background, boundary models, and design principles, see `Brain/records/decisions/terminal-workspace-architecture.md`)*.
