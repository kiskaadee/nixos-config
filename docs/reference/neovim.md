# 📝 Neovim Architecture & Keymaps

This document outlines the Neovim editor setup declared in `home/dev.nix` and `home/config/nvim/`.

---

## 1. Neovim Configuration Architecture

Neovim is configured through a hybrid Nix / Lua model:
- **Nix Layer (`home/dev.nix`)**: Packages, tree-sitter grammars, and language server packages (LSPs) installed into `$PATH`.
- **Lua Layer (`home/config/nvim/`)**: Modular Lua configuration symlinked to `~/.config/nvim/`:
  - `init.lua`: Editor options, leader key (`Space`), and module loader.
  - `lua/plugins.lua`: Lazy/Packer plugin definitions.
  - `lua/keymaps.lua`: Core keybindings and normal/visual mode ergonomics.
  - `lua/lsp.lua`: Language Server Protocol client handlers and completions.

---

## 2. Integrated Toolchains & LSPs

The following language servers are installed globally via `home/dev.nix` and attached automatically:

| Language | Language Server / Tool | Formatter / Linter |
| :--- | :--- | :--- |
| **Nix** | `nil` | `nixfmt-rfc-style` |
| **Rust** | `rust-analyzer` | `rustfmt` |
| **Python** | `pyright` | `ruff` |
| **JavaScript / TypeScript** | `typescript-language-server` | `prettier` |
| **Go** | `gopls` | `gofmt` |
| **Markdown / Documentation** | `marksman` | `prettier` |

---

## 3. Essential Keybindings

- **Leader Key**: `Space`

### Navigation & Files
| Shortcut | Action |
| :--- | :--- |
| `<leader>ff` | Find files (Telescope). |
| `<leader>fg` | Live grep across project. |
| `<leader>fb` | Switch active buffer. |
| `<leader>e` | Toggle file explorer tree. |

### LSP & Diagnostics
| Shortcut | Action |
| :--- | :--- |
| `gd` | Go to definition. |
| `gr` | Go to references. |
| `K` | Hover documentation. |
| `<leader>rn` | Rename symbol. |
| `<leader>ca` | Code action. |
| `[d` / `]d` | Jump to previous / next diagnostic error. |
