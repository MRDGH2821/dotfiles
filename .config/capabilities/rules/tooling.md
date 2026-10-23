## Tooling policy

### Setup: skills and MCP

Tools and tasks are managed by **mise**. Prefer an existing `mise run <task>`
over an ad-hoc command. Inspect `mise.toml` and command `--help` output before
assuming a task or option exists.

If `capabilities.yaml` exists and project skills or MCP tools are missing or
stale:

1. From the repository root, run `mise run ai-setup` (or `capa install --yes`).
2. Reload the agent session so installed skills and MCP servers are picked up.

If the project omits `capabilities.yaml`, use the available tools and instructions.

### Dev Environment Tips

- Use `--help` or `help` subcommand to get help on a command. It can even reveal hints on how to proceed ahead or optimize the number of steps.
- Check tool documentation before asking the user for configuration details
- Tools are managed by **mise**. Prefer `mise run <task>` over ad-hoc binaries when a task exists.

### Tooling

#### mise & hk

Use the configured mise and hk MCP tools when available. If their configuration
is missing, report it and refer to:

- mise: <https://mise.jdx.dev/mcp.html>
- hk: <https://hk.jdx.dev/agents.html#mcp>

#### Using hk from a coding agent

Inspect the configuration and plan before running. Scope checks to changed files
with `--files0-from` and use `--cd` to select the project root. Prefer `--safe`,
review command effects, and require approval for unknown or destructive commands.
Use `--no-stage` when formatting. Use `--stash none` when checking an explicit
file list in the working tree without stashing changes.

Consume JSON or JSONL diagnostics while retaining raw output, and review the
diff produced by a fix. MCP clients should use `inspect_project`, `plan`, safe
run tools, paged output, and `get_diff`.

#### CSpell

Use the hk `cspell` step to check affected files. Its command and options live
in `.config/hk.pkl`. Correct spelling errors and add legitimate project-specific
terms to the `words` array in `.config/cspell.json` rather than disabling checks.

#### Formatting and Hooks (hk)

Before committing, format affected files with `hk fix --no-stage` and run
`hk run pre-commit --check` with the same file scope. Resolve failures and retry
without skipping hooks. The `mise run fmt` task formats the full repository;
review its scope before using it.

### Troubleshooting

#### Common Issues

**Git hooks failing on commit:**

- Read the error message — it usually points directly to the fix
- Try to fix the issue and retry the commit; do not skip hooks
- Fix formatting first (`hk fix` or `mise run fmt`)
- Then address spell checking and linting

**Spell check failures:**

- Add legitimate technical terms to `.config/cspell.json` `words` array
- Use proper capitalization for proper nouns
- Don't add obvious typos to the dictionary

#### Getting Help

- Review existing configuration files for examples
