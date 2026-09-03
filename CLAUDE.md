# CLAUDE.md

Read and follow [`AGENTS.md`](./AGENTS.md).

Read [`architecture.md`](./architecture.md) when making architectural, shared-module, host, service, secret, dependency, or infrastructure changes.

- [`AGENTS.md`](./AGENTS.md) is the authoritative source for agent behavior, safety guardrails, and validation protocols.
- [`architecture.md`](./architecture.md) is the authoritative source for repository architecture, layers, and invariants.

Do not modify the running system (`nixos-rebuild switch`, `systemctl`, etc.) unless the user explicitly requests that operation.
