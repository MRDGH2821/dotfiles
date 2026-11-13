# AGENTS Instructions

This file provides guidance for AI coding assistants working with this project.

## Check task dependencies

Identify the skills, mise tools, and MCP tools this task needs. Check only those
dependencies. Missing unrelated tools must not block the task.

### Check Capa MCP

This project uses `toolExposure: search`. Capa exposes `search` and `call_tool`;
upstream tools are discovered on demand and may not appear by their own names.

1. Call Capa `search` with the task, server, or tool name.
2. If search returns a matching tool, Capa MCP is reachable and the tool is
   registered. Use `call_tool` to run the task's operation.
3. If search responds but finds no match, Capa MCP is reachable, but the tool
   was not found. Search by its configured name or description before reporting
   it unavailable.
4. If `search` is missing or fails before returning results, report that Capa
   MCP is unavailable in this agent session. This does not prove the Capa
   service is stopped.
5. If `call_tool` fails, report the tool and exact error. Do not claim the
   server is down unless the error confirms that.

Do not probe the local Capa URL with shell `curl`; the shell may not share the
agent's network. Continue work that does not need the unavailable capability.
Recommend `mise trust`, `mise install`, or `mise run prepare` only when setup is
the confirmed cause of a required dependency being unavailable.

<!-- capa:start:rule:karpathy-guidelines -->
---
description: Behavioral guidelines to reduce common LLM coding mistakes. Use when writing, reviewing, or refactoring code to avoid overcomplication, make surgical changes, surface assumptions, and define verifiable success criteria.
alwaysApply: true
---

# Karpathy behavioral guidelines

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

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

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.
<!-- capa:end:rule:karpathy-guidelines -->

<!-- capa:start:rule:engineering -->
## Engineering Guidelines

- Explain the intended change, state material assumptions, and clarify ambiguous requirements.
- Read the relevant code and configuration before editing; reuse existing functionality.
- Inspect the working tree and preserve changes made by the user or other agents.
- Match existing style and keep every changed line within the requested scope.
- Define how to verify the change, run the relevant checks, and review the final diff.
- Report what changed, which checks ran, and any failures or checks you could not run.
<!-- capa:end:rule:engineering -->

<!-- capa:start:rule:commits -->
## Commit policy

### Branch naming strategy

Before creating a branch, follow the branch naming strategy in the project-root
`CONTRIBUTING.md` (`#branch-naming-strategy`).

Before committing, treat the repository's default branch, `main`, `master`,
`dev`, `develop`, `release`, and branches under `release/` as shared branches.
If the current branch is shared, create a new branch using the naming strategy
and commit there, preserving existing working-tree changes.

Before creating a pull or merge request, check whether the branch has an open
request and whether its name follows the branch-naming strategy.

- If an open request already exists, leave the branch name unchanged and notify
  the user if it does not comply.
- Use the existing working branch for the request. Do not query remote branch
  protection solely to check compliance with the naming strategy.
- For a non-compliant branch without an open request, propose a
  compliant name and wait for approval. If declined, stop unless the user
  explicitly authorizes an exception.
- For a pushed branch, explain that a native remote rename removes the old
  remote name and ask for approval before using it. After approval, use a native
  rename when available and update the local branch and upstream.
- If native remote rename is unavailable, propose pushing the new name while
  retaining the old remote branch. Obtain separate approval before deleting the
  old remote branch.
- If a push is rejected because the branch is protected, create a new working
  branch and push it instead.

### Commit Messages

Every commit MUST be atomic (one logical change), and every commit message MUST use Conventional Commits format: `<type>(<scope>): <description>`.
Consult `cog.toml` for valid scopes and release hooks; it is the source of truth.

Version bumps use cocogitto (`cog bump`). Inspect the configured hooks before
running a release command.
<!-- capa:end:rule:commits -->

<!-- capa:start:rule:ai-artifacts -->
## AI-generated artifact locations

- For agent-plugin artifacts, use the plugin's dedicated subdirectory under `docs/` when it has one; keep its contents there (for example, `docs/superpowers/`).
- If the plugin instead stores artifacts in a repository-root directory, move/use `.agents/<plugin-id>/` (for example, move `paad/` to `.agents/paad/`).
- For other AI-generated artifacts, use `.agents/<artifact-type>/`, such as `.agents/logs/` for AI work logs or `.agents/research/` for research.
<!-- capa:end:rule:ai-artifacts -->

<!-- capa:start:__base__ -->
## Agent instruction sources

Edit this file for shared guidance. Use other files in
`.config/capabilities/instructions/` for project-specific context and
`.config/capabilities/rules/` for shared policies.

After editing these sources, run `mise run ai-setup` when `capabilities.yaml`
exists. Otherwise, keep corresponding `AGENTS.md` sections in sync. Keep
editable sources outside `.agents/rules/`; Capa prunes that generated directory.

### Conditional guidance

Read the relevant rule before acting:

- Branching, committing, or creating a pull request: `.config/capabilities/rules/commits.md`.
- For an AI-assisted commit, also read `.config/capabilities/rules/ai-co-author.md`.
- Recording AI-assisted work: `.config/capabilities/rules/ai-logs.md`.
- Reviewing on behalf of a human: `.config/capabilities/rules/ai-reviews.md`.
- Using mise or hk, or running project checks: `.config/capabilities/rules/tooling.md`.

### Dependencies

Prefer lightweight, cross-platform dependencies. Use the project's package
manager, update relevant configuration and lockfiles, and document installation.

### Verification and documentation

If no relevant test or check exists, verify behavior directly. Update
documentation when setup or behavior changes.
<!-- capa:end:__base__ -->

<!-- capa:start:template-context -->
## Generated project context

Inspect source files, dependency manifests, and configuration to learn the project's purpose, architecture, and commands. Treat overview documentation as advisory; verify its claims against those maintained sources.

### Template updates

Use `copier update` to apply template updates, then review the resulting changes.

### Recommendations

When implementing a tool, CLI, or library that reads its own configuration, consider the `.config/` recommendation in `README.md`. Verify its fit against maintained source and configuration before following it.
<!-- capa:end:template-context -->
