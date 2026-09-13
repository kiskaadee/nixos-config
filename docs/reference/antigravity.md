# 🤖 Antigravity AI Agent Reference

This document outlines the Antigravity AI pair programming agent integration, operating boundaries, and tool conventions for this workstation.

---

## 1. Operating Rules & Boundaries

AI agents operating in this repository are governed by the constitution defined in [`AGENTS.md`](file:///home/kiskaadee/Config/AGENTS.md).

### The Golden Rule: Build, Never Switch
Autonomous agents must **never** execute `nixos-rebuild switch`, `boot`, `test`, or mutate the running host state. Agents:
1. May **read** repository files.
2. May **modify** declarations in `system/` and `home/`.
3. Must **validate** via dry builds (`nix flake check` and `nix build ... --no-link`).

---

## 2. Second Brain Inbox Capture Rule

Whenever an agent produces an artifact (`UserFacing: true`) or substantial analysis, a copy must be preserved in the Second Brain staging inbox:

```text
/home/kiskaadee/Brain/inbox/<descriptive-name>.md
```

With frontmatter:
```yaml
---
type: inbox
created: YYYY-MM-DD
---
```

---

## 3. Toolchains & Local Binaries

Antigravity executes in an interactive development environment with access to:
- `agy` CLI binary installed via `home/dev.nix`.
- Python runtime, Ruff, and Pyright.
- Git, ripgrep (`rg`), and fd (`find_by_name`).
- Nix CLI (`nix flake check`, `nix build`, `nix eval`).
