## Agent instruction sources

Edit `.config/capabilities/instructions/project.md` for common guidance and the
other files in `.config/capabilities/instructions/` for project-specific context.
Edit `.config/capabilities/rules/` for shared policies.
Run `mise run ai-setup` to refresh capa-managed provider instructions when
`capabilities.yaml` is present. Provider instruction files are generated; edit
their sources instead.
Keep editable sources outside `.agents/rules/`, which capa prunes as generated output.

### Layout

| Path                   | Purpose                                             |
| ---------------------- | --------------------------------------------------- |
| `mise.toml`            | Tools, tasks, `hk install --mise` postinstall hook  |
| `.config/hk.pkl`       | hk hook config (pre-commit, commit-msg, fix, check) |
| `capabilities.yaml`    | Skills, MCP servers, and providers (capa)           |
| `cog.toml`             | Conventional-commit scopes and version bump hooks   |
| `.mega-linter.yml`     | MegaLinter config                                   |
| `.config/treefmt.toml` | Full-tree formatter                                 |
| `.config/cspell.json`  | Spell-check dictionary                              |
| `.agents/logs/`        | AI-assisted work logs                               |

### Best Practices

#### Before Making Changes

1. Understand the current state of the project
2. Check if similar functionality already exists
3. Review relevant configuration files

#### When Adding Dependencies

- Prefer tools that don't require heavy installation; add development tools via `mise.toml`
- Use the project's package manager for application dependencies and keep lockfiles consistent.
- Document installation steps clearly
- Consider cross-platform compatibility
- Update relevant configuration files

#### Testing Changes

- Run relevant tests and configured checks; if no test command exists, verify the affected behavior directly.
- Ensure documentation is updated
