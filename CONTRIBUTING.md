# Contributing

Contributions can include bug fixes, features, documentation, and tooling changes.
Read `README.md` for the project's purpose and usage.

## Report a bug or propose a change

Search the repository's issue tracker before opening an issue.
Use the supplied issue templates when available.
For a substantial change, discuss the problem and approach in an issue first.

For a bug report, include:

- The steps to reproduce it, plus the expected and actual results.
- Your operating system and relevant tool versions.
- Relevant log output with credentials and personal data removed.

For a feature request, explain the problem, the proposed solution, and alternatives.

## Prepare your contribution

Fork or clone the repository and create a branch for your change.
Keep the change focused. Follow the existing code and configuration style.
Update documentation when setup or behavior changes.

## Set up the development environment

Install [mise](https://mise.jdx.dev/getting-started.html) before you start.
Run these commands from the repository root:

```sh
mise trust
mise install
mise run prepare
```

Read `mise.toml` before trusting it. Installation runs the configured tool hooks.
The `prepare` task installs the package dependencies with Bun.
The tool installation also configures Git hooks with hk.

If `capabilities.yaml` exists and you need the project skills or MCP tools, run
`mise run ai-setup`. Restart the agent session after installation.
If `AGENTS.md` exists, read it before using an AI agent on this project.

## Branch naming strategy

### For agents

When an AI agent creates a branch, it must use the following naming strategy:

`<human first name or username>/<work type>/<work name>`

For example:

- `john/feat/add-packages`
- `jane/fix/ui-bugs`
- `joy/refactor/payment`

`<human first name or username>` - will be derived from `git config user.name` or the author's first name. Ask the author for their first name if it's not available.
`<work type>` - the type of work being done (e.g., `feat`, `fix`, `refactor`). Should match commit types from conventional commits.
`<work name>` - the name of the work being done (e.g., `add-packages`, `ui-bugs`, `payment`)

### For humans

If you are one of the maintainers of this repo, ideally follow the same naming structure as stated in above section.
Shouldn't matter in long run.

If you are contributor, branch name wouldn't matter as it would be in your own fork. You are welcome to use same naming scheme as described above.

## Format and check your changes

Run the configured tasks from the repository root:

```sh
mise run fmt
mise run check
```

The `fmt` task formats the repository. Review its diff before committing.
The `check` task runs hk checks and validates commit history with cocogitto.
These tasks are defined in `mise.toml`.

For a smaller formatting change, pass the affected files to
`mise exec -- hk fix --no-stage`. Agent-specific guidance for scoped checks
lives in `AGENTS.md`, when that file exists.

Fix hook failures and retry without bypassing the hooks.
Correct spelling errors. Add legitimate project terms to `.config/cspell.json`.
CI also runs MegaLinter. Read its reports and `.mega-linter.yml` when a check fails.

## Test the affected behavior

Find application test and build commands in `README.md`, `mise.toml`, or the
project's dependency manifests. Run the commands that cover your change.
The scaffold's `check` task covers shared tooling. It does not define application tests.

For a behavior change, add or update tests when a test suite exists.
If no relevant test command exists, describe how you tested the behavior directly.
Keep this guide current as the project adds setup steps, tests, or build commands.

## Commit messages

Use [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/):

```text
<type>(<scope>): <description>
```

The scope is optional.

Examples:

```text
fix(hk): correct the formatting hook
feat(mise): add a development tool
docs: clarify setup instructions
```

Use `cog.toml` for the configured scopes. Keep each commit focused on one change.
Follow any AI attribution and work-log requirements in the applicable `AGENTS.md`.

## Open a pull request or merge request

Use the review workflow supported by the repository's hosting service.
Describe the problem and the resulting behavior. Link the related issue, if any.
Include the following information:

- The commands and tests that you ran, with their results.
- Any failed or skipped checks and the reason for them.
- Any changes to setup, dependencies, or supported platforms.

Review the final diff and keep unrelated changes out of the request.
Respond to review feedback and fix failed CI checks.
The configured GitHub or GitLab pipeline runs mise checks and MegaLinter.
