# Refactoring chezmoi-managed dotfiles into mise-managed dotfiles

**Date:** 2026-11-20
**Question:** The owner wants to "refactor my entire chezmoi-managed dotfiles into mise-managed dotfiles." Does mise actually support managing dotfiles per its own docs, what would be lost from chezmoi, and what partial moves are mise-native?

All CLI evidence below is from the locally installed mise **2026.11.10** (`mise --version`, linux-x64); doc links point at mise.jdx.dev and chezmoi.io as of 2026-11-20, and source links at jdx/mise and twpayne/chezmoi `main`.

## Summary

**The premise is valid today — but only since June 2026.** mise v2026.6.6 (2026-06-13) added a first-class
dotfiles subsystem: a declarative `[dotfiles]` config section plus the `mise dotfiles` (alias `mise dot`)
command family ([release notes](https://github.com/jdx/mise/releases/tag/v2026.6.6): "Declarative dotfiles via
`[dotfiles]` plus `mise dotfiles add` / `apply` / `edit` / `status`, supporting `symlink`, `symlink-each`,
`copy`, and `template` modes"). Before that release, everything mise did to files was "run a task that copies
files" — no tracked state. The installed mise 2026.11.10 has the full feature set, including `diff`, `apply`,
`status`, `unapply`, `track`, `save`, `history`, `rollback`, `undo`, `origin`, `sync`, `pull`, `watch`, and
`capture` (verified via `mise dotfiles --help`).

So a migration is **documented and supported**, not a misuse of mise. It is a real port, though: every `.tmpl` file must be rewritten from Go templates to mise's Tera, the secret story narrows to `fnox`, and chezmoi's interactive per-machine config prompts and templated ignore file have no documented mise equivalent. Details and citations below.

## 1. Every mise feature that touches file/configuration state

| Feature                                                                                                       | What it does to files                                                                                                                                                                                                                           | State tracked?                                                                                                         | Source                                                                                                                |
| ------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------- |
| `mise.toml` config files (`[tools]`, `[env]`, `[vars]`, `[settings]`, `[tasks]`, `[plugins]`, `[secrets]`, …) | Read as config; written by `mise use` / `mise set` / `mise settings` / `mise tasks add`                                                                                                                                                         | Own config only                                                                                                        | [configuration docs](https://mise.jdx.dev/configuration.html)                                                         |
| **`mise dotfiles` / `mise dot`**                                                                              | Deploys files from a source dir (`symlink`, `symlink-each`, `copy`, `template`), removes files (`absent`), edits part of a file (`line`/`block`, `merge`), tracks live files in place (`track`)                                                 | **Yes — target-state model with `diff`/`apply`/`status`/`unapply`, plus a local Git history store with `origin` sync** | [dotfiles docs](https://mise.jdx.dev/dotfiles.html), [managed-files docs](https://mise.jdx.dev/dotfiles/managed.html) |
| `mise bootstrap`                                                                                              | "sets up a machine from your mise configuration: host packages, system files, services, Git repositories, dotfiles, shell activation, tools, and your `bootstrap` task"; applies `[dotfiles]` as one part, with `--dry-run` / `plan` / `status` | Yes, per part ("Parts that declare state skip anything already in the desired state")                                  | [bootstrap docs](https://mise.jdx.dev/bootstrap.html)                                                                 |
| mise tasks (`[tasks.<name>]`, `mise-tasks/`)                                                                  | Run named commands with project tools/env; `sources`/`outputs` freshness: "When `sources` is set, mise skips the task if the newest source file is older than the newest output"                                                                | Task I/O freshness only, not declared file state                                                                       | [tasks docs](https://mise.jdx.dev/tasks/), [task configuration](https://mise.jdx.dev/tasks/task-configuration.html)   |
| `mise watch`                                                                                                  | Re-runs a task when files matching its `sources` change                                                                                                                                                                                         | Reuses task freshness                                                                                                  | [task configuration — `watch`, `sources`](https://mise.jdx.dev/tasks/task-configuration.html)                         |
| Hooks (`[hooks]`: `enter`, `leave`, `cd`, `preinstall`, `postinstall`; `[[watch_files]]`)                     | "A hook is a command string, a table, a task reference, or an array of these"; `watch_files` runs a command/task when a glob's target changes (checked at prompt under `mise activate`)                                                         | No — "mise does not track or undo what a script changes"                                                               | [hooks docs](https://mise.jdx.dev/hooks.html)                                                                         |
| `mise generate`                                                                                               | 8 generators writing project files: `config`, `devcontainer`, `git-pre-commit`, `github-action`, `install-script`, `task-docs`, `task-stubs`, `tool-stub` — "Generate project files such as CI workflows, git hooks, and scripts"               | No                                                                                                                     | [generate CLI reference](https://mise.jdx.dev/cli/generate.html)                                                      |
| `mise activate` / shims                                                                                       | Activation "updates tools and environment variables as this shell changes directories"; shims directory is `$HOME/.local/share/mise/shims`                                                                                                      | No                                                                                                                     | [activate CLI reference](https://mise.jdx.dev/cli/activate.html)                                                      |
| Lockfile (`mise.lock`)                                                                                        | Pins tool versions next to config                                                                                                                                                                                                               | Tool versions only                                                                                                     | [configuration docs](https://mise.jdx.dev/configuration.html)                                                         |

The rigorous distinction the owner should keep in mind: **tasks, hooks, `generate`, and `activate` do not
track dotfile state** — they are "mise can run a task that copies files." The **only** mise subsystem that
tracks declared file state (diff before apply, converge, unapply, history/rollback) is `mise dotfiles` + `mise
bootstrap`, both added in v2026.6.6 and hardened through v2026.11.x (frequent fixes in the [release
notes](https://github.com/jdx/mise/releases), e.g. v2026.11.7 "refusing to overwrite locally edited copies
without `--yes`").

### The `mise dotfiles` model in detail ([docs](https://mise.jdx.dev/dotfiles.html))

Two approaches: **deploy** — "takes files from a source directory, such as a dotfiles repository, and places
them as links, copies, or templates" — and **track** — "mise saves the history of the configuration files you
edit in place." An entry maps a target path to options, e.g. `"~/.gitconfig" = { source = "git/config", mode =
"copy" }`. Modes ([managed docs](https://mise.jdx.dev/dotfiles/managed.html)):

- `symlink` — "Create one link to a file or a whole directory" (the default per the dotfiles page).
- `symlink-each` — "Create directories and link each file within them."
- `copy` — "Copy a file or directory, overwriting matching files." Warning quoted verbatim in docs: "Applying a copy entry overwrites changes made directly to the target." Round-trip: "If you edit a copied target in place, run `mise dot add` on it again to save the change back to its source" (`mise dot add --changed` does this for every changed copy target).
- `template` — "renders its source with mise's Tera templates on every apply," using "`env`, `vars`, `exec()`, and the rest of the template context" (example: `{% if os() == "macos" %}`). Capture is refused for templates ("that would replace the template code in the source"; `--force` overrides).
- `fnox` — deploys a secret stored in [fnox](https://mise.jdx.dev/dotfiles/managed.html) (≥ 1.44.0): `fnox set --file` stores, apply runs `fnox get --file` and writes with `0600`.
- `absent` — deletes an unwanted target (regular files/symlinks only).
- `track` / `track-local` — "save the history of a file where it is, without a source"; history is "a separate store, shared only if you connect an origin" (private Git repo via `mise dot origin set … --sync sync`).

Entries can live in the global config, a `conf.d` folder, or a dotfiles repository's `mise.toml` — the
repository's `[dotfiles]` is "read only after you trust it" ([configuration
docs](https://mise.jdx.dev/configuration.html)). Per-machine entries: "To give some entries to one machine or
operating system, put them in `config.local.toml`" ([dotfiles docs](https://mise.jdx.dev/dotfiles.html)).
`mise dot apply` is also a step of `mise bootstrap` (after `[bootstrap.repos]` clone), with `pre-dotfiles` /
`post-dotfiles` hook phases ([bootstrap docs](https://mise.jdx.dev/bootstrap.html)).

## 2. What chezmoi features would be lost or need rework

chezmoi's own landing page ([chezmoi.io](https://www.chezmoi.io/)): it "Manage[s] your dotfiles across multiple diverse machines, securely," with templating, "Password manager support keeps secrets out of your plain-text files," archive imports, "Full file encryption works with age, gpg, git-crypt, or transcrypt," and script execution.

| chezmoi feature (source)                                                                                                                                                                                                                                                                                 | mise equivalent                                                                                                                                                                                                                                                                                                                                                                      | Loss / rework                                                                                                                                                                                                                                                                                                                                       |
| -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Templating: Go `text/template` "extended with text template functions from `sprig`" plus chezmoi's own runtime functions ([templating guide](https://www.chezmoi.io/user-guide/templating/))                                                                                                             | `mode = "template"` with Tera v2, `env`/`vars`/`exec()`/`os()` ([templates docs](https://mise.jdx.dev/templates.html), [managed docs](https://mise.jdx.dev/dotfiles/managed.html))                                                                                                                                                                                                   | **Every `.tmpl` must be rewritten.** Different language, different function set (no sprig, no password-manager template functions). No `--autotemplate` equivalent.                                                                                                                                                                                 |
| Secrets: password managers (1Password, Bitwarden, etc. — [landing page](https://www.chezmoi.io/)) and encryption with age/gpg/git-crypt/transcrypt                                                                                                                                                       | `mode = "fnox"` only — one secret store, needs `fnox` (≥ 1.44.0) on `PATH`, keyed by target path ([managed docs](https://mise.jdx.dev/dotfiles/managed.html))                                                                                                                                                                                                                        | All manager integrations and in-repo encryption are lost; secrets must move into fnox.                                                                                                                                                                                                                                                              |
| `chezmoi diff` ("Print the difference between the target state and the destination state", [diff command](https://www.chezmoi.io/reference/commands/diff/)) and `chezmoi add` (adopts destination edits back into source state, [add command](https://www.chezmoi.io/reference/commands/add/))           | `mise dot diff` — "Show what `mise dot apply` would change"; `mise dot add` copies edits back to source ([dotfiles docs](https://mise.jdx.dev/dotfiles.html))                                                                                                                                                                                                                        | Equivalent exists. Difference: chezmoi templates round-trip via `add --template`; mise "refuses to capture a `template` target" without `--force` ([managed docs](https://mise.jdx.dev/dotfiles/managed.html)).                                                                                                                                     |
| `run_onchange_` scripts: "only executed if their content has changed since the last time they were run successfully"; `run_once_` via "content's SHA256 hash … stored … in a database"; `before_`/`after_` ordering ([scripts guide](https://www.chezmoi.io/user-guide/use-scripts-to-perform-actions/)) | mise tasks with `sources`/`outputs` ("mise skips the task if the newest source file is older than the newest output"; "The files that define the task … always count as sources" — [task configuration](https://mise.jdx.dev/tasks/task-configuration.html)); `[bootstrap.hooks]` named phases; the `[tasks.bootstrap]` task ([bootstrap docs](https://mise.jdx.dev/bootstrap.html)) | `run_onchange` maps well (task-definition changes also re-run, like chezmoi's rendered-content hash). **No verified `run_once`-per-content-hash equivalent.** Not every `run_onchange` semantics maps: chezmoi hashes _rendered script content_; mise compares source/output _timestamps_ (or contents with `task.source_freshness_hash_contents`). |
| Per-machine config: `.chezmoi.$FORMAT.tmpl` — "template file … that generates chezmoi's config file," typically prompting (e.g. `promptStringOnce` for email) into the config's `data` section ([special file docs](https://www.chezmoi.io/reference/special-files/chezmoi-format-tmpl/))                | `config.local.toml` for machine/OS-specific entries ([dotfiles docs](https://mise.jdx.dev/dotfiles.html)); `[vars]` for template data                                                                                                                                                                                                                                                | **No documented interactive-prompt equivalent** — per-machine values must be written into `config.local.toml` some other way. Template data variables differ (`.chezmoidata`/`.chezmoi.*` vs Tera `env`/`vars`).                                                                                                                                    |
| `.chezmoiignore`: "a set of patterns to ignore," matched against target paths, and it "is interpreted as a template, whether or not it has a `.tmpl` extension" — so different machines ignore different files ([docs](https://www.chezmoi.io/reference/special-files/chezmoiignore/))                   | `mise dotfiles exclude` — "Never save paths matching a glob" (CLI help); per-entry `exclude` ([configuration table](https://mise.jdx.dev/configuration.html))                                                                                                                                                                                                                        | No templated/conditional ignore documented; glob-level only.                                                                                                                                                                                                                                                                                        |
| Archive imports / externals (`.chezmoiexternals/` — [special directories](https://www.chezmoi.io/reference/special-directories/))                                                                                                                                                                        | `[bootstrap.repos]` clones Git repositories only ([bootstrap docs](https://mise.jdx.dev/bootstrap.html))                                                                                                                                                                                                                                                                             | No verified archive-import equivalent.                                                                                                                                                                                                                                                                                                              |
| Encrypted-file targets, `--encrypt` on `chezmoi add` ([add command](https://www.chezmoi.io/reference/commands/add/))                                                                                                                                                                                     | none (fnox covers secret _content_, not encrypted repo files)                                                                                                                                                                                                                                                                                                                        | Lost.                                                                                                                                                                                                                                                                                                                                               |

## 3. mise-native patterns for config files (per official docs)

- **`[dotfiles]` entries** are the native pattern: target → `{ source, mode, permissions, exclude, merge, line/block }`, in global config, `conf.d`, or a trusted dotfiles-repo `mise.toml` ([configuration docs](https://mise.jdx.dev/configuration.html), [dotfiles docs](https://mise.jdx.dev/dotfiles.html)).
- **`mode = "track"` + history** for files you want versioned but not sourced from the repo, with `origin`/`sync`/`pull` to share between machines and `mise dotfiles watch` ("Save tracked files as they change") plus `rollback`/`undo` ([dotfiles docs](https://mise.jdx.dev/dotfiles.html), [history docs](https://mise.jdx.dev/dotfiles/history.html)).
- **`[env]`** replaces exported env vars currently templated into shell rc files ([configuration docs](https://mise.jdx.dev/configuration.html)); `mise config ls` lists the loaded config chain (verified in the [previous research note](./2026-11-20-mise-config-file-override.md)).
- **`mise bootstrap`** replaces the machine-setup `run_onchange` scripts wholesale: packages (`apt`, `brew`,
  `mas`, `winget`-style managers), users/groups, files/directories, services (systemd/launchd), repos, shell
  activation, and the `[tasks.bootstrap]` escape hatch, all idempotent ("Parts that declare state skip anything
  already in the desired state") ([bootstrap docs](https://mise.jdx.dev/bootstrap.html)).

## Verdict

**"mise-managed dotfiles" is an officially supported mise use case since mise v2026.6.6 (2026-06-13) — the premise is not mistaken for current mise.** Anyone (or any older doc) claiming mise is "only a dev-tools/env/tasks manager" is describing pre-June-2026 mise. The migration is real engineering, though:

1. Every `.tmpl` file (Go templates + sprig) must be rewritten in Tera v2 — the biggest mechanical cost.
2. The secrets model narrows to fnox; chezmoi's password-manager integrations and age/gpg file encryption are lost.
3. `.chezmoi.toml.tmpl` interactive prompts (promptStringOnce) and templated `.chezmoiignore` have no documented mise equivalents — per-machine values go in `config.local.toml`, ignores in `exclude` globs.
4. `run_onchange_*` scripts convert cleanly to mise tasks with `sources`/`outputs` (or `[bootstrap.hooks]`); a `run_once`-per-content-hash equivalent was not found in the docs.
5. `run_onchange_after_05-linux-mise-bootstrap.sh.tmpl` is a natural first candidate to move into `[bootstrap]` — mise bootstrap covers exactly that ground (the repo already has `.config/mise/mise.lock` and a mise workflow).

Partial moves are also fine: keep chezmoi for templated/secret-heavy files and adopt `mise dotfiles`/`mise bootstrap` incrementally. Note the dotfiles subsystem is ~5 months old with fixes still landing weekly (see the v2026.11.x [release notes](https://github.com/jdx/mise/releases)) — pin a mise version and test `mise dot diff` on a scratch clone before the real migration.

## Scratch-clone trial (2026-11-20, mise 2026.11.10)

Live trial of `mise dot` against a scratch clone at `/tmp/mise-dot-trial/` (clone of `ce3eadd`, trial
`mise.toml` + Tera source inside the clone only; target `$HOME` overridden to an empty fake home via `HOME=`;
global config overridden with `MISE_GLOBAL_CONFIG_FILE` pointing at an empty file). Three entries: `copy`
(`files/dot_zshenv` → `~/.zshenv`), `template` (Tera rewrite of `dot_bash_aliases.tmpl` → `~/.bash_aliases`),
`symlink` (`files/dot_config/fastfetch` → `~/.config/fastfetch`). Verified: `mise trust` gates the repo's
`mise.toml` (matches the docs' trust note); `status` / `diff` render correct unified diffs; `apply` deploys
all three modes correctly; re-`status` is idempotent ("3 entries up to date"); a locally edited copy target
refuses non-interactive overwrite without `--yes` and names the source path to save the edit into; `unapply`
refuses to remove a diverged target without `--force`. No live-tree or real-home writes occurred.

**New finding not covered above: mise Tera has no cross-file include.** Both `dot_bash_aliases.tmpl` and
`dot_bashrc.d/shell-importer.sh.tmpl` are trampolines that call chezmoi's `template "shell-scripts/…" .` to
pull from `.chezmoitemtemplates/shell-scripts/` (~15 shared shell fragments). `{% include %}` fails with
`Unknown template` — a `templates/` dir in the config root is not registered either — and the [templates
docs](https://mise.jdx.dev/templates.html) state: "Define a component in the same template string that calls
it; mise has no shared component library." Every chezmoi template that includes shared fragments must inline
the fragment's content (or the include trampoline pattern dies). This is an additional per-file migration cost
beyond the Go-template→Tera rewrite itself.

**Mitigating finding: no source renaming needed.** `[dotfiles]` entries declare target paths explicitly, so chezmoi's `dot_*`/`dot_` naming convention is not required — a migration can point sources at the existing `files/dot_*` paths and only rename later, or never.

## Gaps / uncertainties

- `mise dot status` / `diff` / `apply` were not executed against a live `[dotfiles]` config in this read-only session; the feature set is evidenced by docs, release notes, and local `mise dotfiles --help` only.
- No `run_once`-style per-content-hash gating was found in mise task docs; if it matters, verify on the CLI (`mise run --help` and task docs may have drifted).
- No interactive `promptStringOnce` equivalent found anywhere in mise docs; this may exist under `mise bootstrap setup` (linked from the dotfiles page as [bootstrap/setup](https://mise.jdx.dev/bootstrap/setup.html)) — not verified.
- fnox itself is a separate tool (≥ 1.44.0) and was not installed or exercised locally.
- Docs conflict check: none found between mise.jdx.dev pages or chezmoi.io pages. Third-party material
  describing mise as tools-only predates v2026.6.6 and conflicts with the current official docs — trust the
  official pages cited here. The author's announcement post is linked from the docs ([jdx.dev,
  2026-09-07](https://jdx.dev/posts/2026-09-07-dotfiles-that-save-themselves/)) but is not needed for any claim
  above.

## Sources

- [mise dotfiles — overview, tracking vs deploying, modes](https://mise.jdx.dev/dotfiles.html)
- [mise dotfiles — managed files: modes table, templates, fnox, absent, capturing changes](https://mise.jdx.dev/dotfiles/managed.html)
- [mise dotfiles — history](https://mise.jdx.dev/dotfiles/history.html)
- [mise bootstrap — full machine setup incl. dotfiles step and hook phases](https://mise.jdx.dev/bootstrap.html)
- [mise configuration — config contents, precedence, `[dotfiles]` table entry](https://mise.jdx.dev/configuration.html)
- [mise templates — Tera v2, `env`/`vars`/`exec()`/`os()`](https://mise.jdx.dev/templates.html)
- [mise tasks — overview](https://mise.jdx.dev/tasks/) and [task configuration — `sources`/`outputs` freshness, `watch`, `depends`](https://mise.jdx.dev/tasks/task-configuration.html)
- [mise hooks — `enter`/`leave`/`cd`/`preinstall`/`postinstall`, `[[watch_files]]`](https://mise.jdx.dev/hooks.html)
- [mise generate — CLI reference (8 generators)](https://mise.jdx.dev/cli/generate.html)
- [mise activate — CLI reference, shims at `$HOME/.local/share/mise/shims`](https://mise.jdx.dev/cli/activate.html)
- [jdx/mise release v2026.6.6 — dotfiles feature introduction (#10365, #10368, #10374, #10376)](https://github.com/jdx/mise/releases/tag/v2026.6.6)
- [jdx/mise releases — dotfiles fixes through v2026.11.x](https://github.com/jdx/mise/releases)
- [chezmoi — landing page, feature list](https://www.chezmoi.io/)
- [chezmoi — concepts: source/target/destination state](https://www.chezmoi.io/reference/concepts/)
- [chezmoi — templating guide (Go text/template + sprig)](https://www.chezmoi.io/user-guide/templating/)
- [chezmoi — scripts guide (`run_`, `run_once_`, `run_onchange_`, hashes in state)](https://www.chezmoi.io/user-guide/use-scripts-to-perform-actions/)
- [chezmoi — `.chezmoi.$FORMAT.tmpl` config-file template and prompts](https://www.chezmoi.io/reference/special-files/chezmoi-format-tmpl/)
- [chezmoi — `.chezmoiignore` (templated ignore patterns)](https://www.chezmoi.io/reference/special-files/chezmoiignore/)
- [chezmoi — special directories (`.chezmoiscripts/`, `.chezmoitemplates/`, `.chezmoidata/`, `.chezmoiexternals/`)](https://www.chezmoi.io/reference/special-directories/)
- [chezmoi — `add` command (adopt destination state, `--encrypt`, `--autotemplate`)](https://www.chezmoi.io/reference/commands/add/)
- [chezmoi — `diff` command](https://www.chezmoi.io/reference/commands/diff/)
- Local CLI runs (mise 2026.11.10): `mise --version`, `mise dotfiles --help` (full subcommand list: add, apply, capture, conflicts, diff, edit, exclude, files, history, include, notify, origin, paths, pull, recover, rollback, save, status/ls, sync, track, unapply, undo, untrack, watch)
- Prior note in this directory: [2026-11-20-mise-config-file-override.md](./2026-11-20-mise-config-file-override.md) — config write-target flags, `mise config ls`, `MISE_GLOBAL_CONFIG_FILE`
