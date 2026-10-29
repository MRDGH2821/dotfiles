## Tooling policy

### Setup: skills and MCP

Prefer an existing `mise run <task>` over an ad-hoc command. Inspect
`.config/mise/config.toml` and command `--help` output before assuming a
task or option exists.

Consult tool documentation and existing config examples before asking the user
about configuration.

If `capabilities.yaml` exists and project skills or MCP tools are missing or
stale:

1. From the repository root, run `mise run ai-setup` (or `capa install --yes`).
2. Reload the agent session so installed skills and MCP servers are picked up.

If the project omits `capabilities.yaml`, use the available tools and
instructions.

### mise & hk

Use configured mise and hk MCP tools when available. If their configuration is
missing, report it and refer to:

- mise: <https://mise.jdx.dev/mcp.html>
- hk: <https://hk.jdx.dev/agents.html#mcp>

### Using hk from a coding agent

Inspect the configuration and plan before running checks. Scope them to changed
files with `--files0-from` and select the project root with `--cd`. Prefer
`--safe`; review command effects and require approval for unknown or destructive
commands.

Use `--no-stage` when formatting and `--stash none` when checking explicit
working-tree files.

Retain raw JSON or JSONL diagnostics and review diffs from fixes. MCP clients
should use `inspect_project`, `plan`, safe run tools, paged output, and
`get_diff`.

### CSpell

Use the hk `cspell` step configured in `.config/hk.pkl`. Fix spelling errors
and add legitimate project terms to `.config/cspell.json` instead of disabling
the check.

### Formatting and hooks

Before committing, format affected files with `hk fix --no-stage` and run
`hk run pre-commit --check` on the same files. Resolve failures and retry
without skipping hooks. `mise run fmt` formats the full repository; review its
scope before running it.

If a hook fails, follow its diagnostic, fix the cause, and retry.
