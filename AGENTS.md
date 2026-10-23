# AGENTS Instructions

This file provides guidance for AI coding assistants working with this project.

If none of the skills or tools specified in `mise.toml` are available, run the following commands and alert the user to reload the agent.

```sh
mise trust
mise install
mise run prepare
```

Refuse to do anything until `mise run prepare` has run atleast once and the agent is reloaded with the skills & MCP servers as specified in `capabilities.yaml`.
MCP servers should be accessible via Capa MCP.

<!-- capa:start:rule:karpathy-guidelines -->

---

## description: Behavioral guidelines to reduce common LLM coding mistakes. Use when writing, reviewing, or refactoring code to avoid overcomplication, make surgical changes, surface assumptions, and define verifiable success criteria. alwaysApply: true

## Karpathy behavioral guidelines

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

### 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:

- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

### 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

### 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:

- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:

- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

### 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:

- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:

```text
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.
<!-- capa:end:rule:karpathy-guidelines -->

<!-- capa:start:rule:engineering -->

### Engineering Guidelines

- Explain the intended change, state material assumptions, and clarify ambiguous requirements.
- Read the relevant code and configuration before editing; reuse existing functionality.
- Inspect the working tree and preserve changes made by the user or other agents.
- Match existing style and keep every changed line within the requested scope.
- Define how to verify the change, run the relevant checks, and review the final diff.
- Report what changed, which checks ran, and any failures or checks you could not run.

<!-- capa:end:rule:engineering -->

<!-- capa:start:rule:commits -->

### Commit policy

#### Branch naming strategy

Before creating a branch, follow the branch naming strategy in the project-root
`CONTRIBUTING.md` (`#branch-naming-strategy`).

#### Commit Messages

Every commit MUST be atomic (one logical change), and every commit message MUST use Conventional Commits format: `<type>(<scope>): <description>`.
Consult `cog.toml` for valid scopes and release hooks; it is the source of truth.

Version bumps use cocogitto (`cog bump`). Inspect the configured hooks before
running a release command.
<!-- capa:end:rule:commits -->

<!-- capa:start:rule:ai-co-author -->

### AI Co-authored-by Trailer (MANDATORY)

> **Every commit made with AI assistance MUST include a `Co-authored-by` trailer. No exceptions.**

**Format:**

```txt
Co-authored-by: <Model full Name and version> via <Harness> <noreply@provider-domain>
```

**Provider attribution addresses:**

Choose the address for the model provider. The harness can come from a different provider.

<!-- smt -->

| Provider                | noreply address          |
| ----------------------- | ------------------------ |
| Anthropic (Claude)      | `noreply@anthropic.com`  |
| Cursor                  | `cursoragent@cursor.com` |
| Google (Gemini)         | `noreply@google.com`     |
| Meta (Llama)            | `noreply@meta.com`       |
| Microsoft (Copilot)     | `noreply@microsoft.com`  |
| Mistral                 | `noreply@mistral.ai`     |
| OpenAI (GPT / o-series) | `noreply@openai.com`     |
| xAI (Grok)              | `noreply@x.ai`           |

If the provider is not listed, search its official documentation or public repositories
for a documented attribution email address. Use that address rather than guessing one
from the provider's domain.

**Examples:**

```txt
feat(pre-commit): add spell checking to commit messages

Co-authored-by: Claude Sonnet 4.6 via opencode <noreply@anthropic.com>
```

```txt
fix(cspell): resolve configuration issue

Co-authored-by: GPT-4o via Cursor <noreply@openai.com>
```

**Rules:**

- Use the **full model name and version** supplied by the current session (e.g. `Claude Sonnet 4.6`, not just `Claude`)
- Use the **harness name** as it is commonly known (e.g. `Codex`, `opencode`, `Cursor`, `Copilot`, `Zed`). The harness is the application or CLI running the model.
- If the exact model version is unavailable, use the most specific known model name (e.g. `Claude Sonnet`). Do not guess a version.
- One trailer per AI model involved
- **Never omit this trailer** when the commit was AI-assisted — this is how git history stays honest

<!-- capa:end:rule:ai-co-author -->

<!-- capa:start:rule:ai-logs -->

### AI-assisted work documentation

- Document all AI-assisted changes in the `.agents/logs` folder as markdown files
- Use the naming format: `YYYY-MM-DD.md` (e.g., `2024-12-15.md`)
- Each documentation file should include:
  - The prompt or request that initiated the work
  - The author of the prompt (can be obtained from `git config user.name` or by asking the user)
  - Description of what was done
  - Which AI model was used (e.g., Claude Sonnet 4.5, GPT-4, etc.)
- If more prompts are provided on the same day, append them to the existing log file with timestamps
- Use the `date` command to generate timestamps (e.g., `date --iso-8601=seconds` or `date '+%Y-%m-%d %H:%M:%S'`)
- Place any other relevant documents (prompts, examples, references) in the `.agents` folder
- This provides transparency and helps track AI contributions to the project

<!-- capa:end:rule:ai-logs -->

<!-- capa:start:rule:ai-reviews -->

### AI-Assisted Reviews

When reviewing on behalf of a human, end the review with this footer:

Use `.config/capabilities/rules/ai-co-author.md` for the model, harness, and provider email.

```md
<!-- Include a 3 line dash -->

---

<!-- Use the co-author rule. In Markdown, render the footer as subscript when supported.-->

<sub>Co-authored-by: <Model full Name and version> via <Harness> <noreply@provider-domain></sub>
```

<!-- capa:end:rule:ai-reviews -->

<!-- capa:start:rule:tooling -->

### Tooling policy

#### Setup: skills and MCP

Tools and tasks are managed by **mise**. Prefer an existing `mise run <task>`
over an ad-hoc command. Inspect `mise.toml` and command `--help` output before
assuming a task or option exists.

If `capabilities.yaml` exists and project skills or MCP tools are missing or
stale:

1. From the repository root, run `mise run ai-setup` (or `capa install --yes`).
2. Reload the agent session so installed skills and MCP servers are picked up.

If the project omits `capabilities.yaml`, use the available tools and instructions.

#### Dev Environment Tips

- Use `--help` or `help` subcommand to get help on a command. It can even reveal hints on how to proceed ahead or optimize the number of steps.
- Check tool documentation before asking the user for configuration details
- Tools are managed by **mise**. Prefer `mise run <task>` over ad-hoc binaries when a task exists.

#### Tooling

##### mise & hk

Use the configured mise and hk MCP tools when available. If their configuration
is missing, report it and refer to:

- mise: <https://mise.jdx.dev/mcp.html>
- hk: <https://hk.jdx.dev/agents.html#mcp>

##### Using hk from a coding agent

Inspect the configuration and plan before running. Scope checks to changed files
with `--files0-from` and use `--cd` to select the project root. Prefer `--safe`,
review command effects, and require approval for unknown or destructive commands.
Use `--no-stage` when formatting. Use `--stash none` when checking an explicit
file list in the working tree without stashing changes.

Consume JSON or JSONL diagnostics while retaining raw output, and review the
diff produced by a fix. MCP clients should use `inspect_project`, `plan`, safe
run tools, paged output, and `get_diff`.

##### CSpell

Use the hk `cspell` step to check affected files. Its command and options live
in `.config/hk.pkl`. Correct spelling errors and add legitimate project-specific
terms to the `words` array in `.config/cspell.json` rather than disabling checks.

##### Formatting and Hooks (hk)

Before committing, format affected files with `hk fix --no-stage` and run
`hk run pre-commit --check` with the same file scope. Resolve failures and retry
without skipping hooks. The `mise run fmt` task formats the full repository;
review its scope before using it.

#### Troubleshooting

##### Common Issues

**Git hooks failing on commit:**

- Read the error message — it usually points directly to the fix
- Try to fix the issue and retry the commit; do not skip hooks
- Fix formatting first (`hk fix` or `mise run fmt`)
- Then address spell checking and linting

**Spell check failures:**

- Add legitimate technical terms to `.config/cspell.json` `words` array
- Use proper capitalization for proper nouns
- Don't add obvious typos to the dictionary

##### Getting Help

- Review existing configuration files for examples

<!-- capa:end:rule:tooling -->

<!-- capa:start:__base__ -->

### Agent instruction sources

Edit `.config/capabilities/instructions/project.md` for common guidance and the
other files in `.config/capabilities/instructions/` for project-specific context.
Edit `.config/capabilities/rules/` for shared policies.
Run `mise run ai-setup` to refresh capa-managed provider instructions when
`capabilities.yaml` is present. Provider instruction files are generated; edit
their sources instead.
Keep editable sources outside `.agents/rules/`, which capa prunes as generated output.

#### Layout

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

#### Best Practices

##### Before Making Changes

1. Understand the current state of the project
2. Check if similar functionality already exists
3. Review relevant configuration files

##### When Adding Dependencies

- Prefer tools that don't require heavy installation; add development tools via `mise.toml`
- Use the project's package manager for application dependencies and keep lockfiles consistent.
- Document installation steps clearly
- Consider cross-platform compatibility
- Update relevant configuration files

##### Testing Changes

- Run relevant tests and configured checks; if no test command exists, verify the affected behavior directly.
- Ensure documentation is updated

<!-- capa:end:__base__ -->

<!-- capa:start:template-context -->

### Generated project context

#### Project Context

Read `README.md`, dependency manifests, and relevant source files to learn the
project's purpose, architecture, and commands. The application language and
framework depend on the generated project.

- **Project Type**: Project scaffolded from [copier-mr-mise](https://github.com/MRDGH2821/copier-mr-mise)
- **Key Technologies**: mise, hk, MegaLinter, cspell, capa
- **Purpose**: Standardized starting point with tool management, git hooks, and quality checks
- **Template updates**: `copier update` (review scripts in the template's `copier.yml`)

#### Recommendations

##### Configuration directory

If this project is a tool, CLI, or library that reads its own configuration,
make it resolve that configuration from a project-level `.config/` directory
(e.g. `.config/<project-name>.toml`) in addition to any other supported
locations. This template already keeps its own tool configs there
(`.config/cspell.json`, `.config/rumdl.toml`, `.config/cliff.toml`); extending
the same convention to what this project ships keeps consumers' repo roots tidy.

References:

- <https://github.com/numtide/prj-spec> — project directory specification
- <https://dot-config.github.io/> — the `.config/` directory convention
- <https://github.com/pi0/config-dir> — reference implementation for resolving it

<!-- capa:end:template-context -->
