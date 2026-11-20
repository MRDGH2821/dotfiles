# Redirecting mise to a temporary config file it will update

**Date:** 2026-11-20
**Question:** Is there a way to make mise use a temporarily supplied config file path so that it updates the given path (e.g. via `mise use`, `mise settings set`, `mise install`, `mise upgrade`, lockfile writes) without touching the real `~/.config/mise/config.toml`?

All CLI evidence below is from the locally installed mise **2026.11.10** (`mise --version`); source links point at jdx/mise `main` as of today.

## Summary

**Yes — two complementary mechanisms, plus a sandbox recipe.**

1. **Per-command write-target flags.** `mise use -p/--path <FILE>` ("Write to this config file, or to the config file in this directory") writes the exact file given, regardless of what mise loads ([mise use docs](https://mise.jdx.dev/cli/use.html), verified with `mise use --path /tmp/…/alt.toml -n node@24` → "mise would update /tmp/…/alt.toml").
   The same style of flag exists on `mise unuse --path` ([docs](https://mise.jdx.dev/cli/unuse.html)), `mise set -f/--file <FILE>` ([docs](https://mise.jdx.dev/cli/set.html)), `mise unset -f/--file` ([docs](https://mise.jdx.dev/cli/unset.html)), and `mise config set -f/--file <FILE>` ([docs](https://mise.jdx.dev/cli/config/set.html)).
   This answers "make mise _update the given path_" directly — but note **`mise settings set|add|unset` have NO `--path`/`--file` flag** (`mise settings set --help`: only `-l/--local` and `--override`).

2. **Redirect the global config with an env var.** `MISE_GLOBAL_CONFIG_FILE=<path>` (older alias: `MISE_CONFIG_FILE`) makes that single file _the_ global config: mise loads it instead of everything in `~/.config/mise`, and every **global** write targets it.
   ([configuration docs](https://mise.jdx.dev/configuration.html#global-config): "`global_config_file` (`MISE_GLOBAL_CONFIG_FILE`) replaces all of these files with one file"; [environment-variables docs](https://mise.jdx.dev/configuration/environment-variables.html): "`MISE_CONFIG_FILE` is an older name".)
   Verified by dry-run: `MISE_CONFIG_FILE=/tmp/…/alt.toml mise use -g -n node@20` → "mise would update /tmp/…/alt.toml", and source: [crates/mise-util/src/env.rs](https://github.com/jdx/mise/blob/main/crates/mise-util/src/env.rs) (`MISE_GLOBAL_CONFIG_FILE = var_path("MISE_GLOBAL_CONFIG_FILE").or_else(|| var_path("MISE_CONFIG_FILE"))`).

3. **Full sandbox recipe (reads and writes only the temp files).** Run from a temp dir outside `$HOME` (no parent configs walk up), with the env var pointing at a copy of the real config:

   ```bash
   SB=$(mktemp -d); cp ~/.config/mise/config.toml "$SB/config.toml"
   export MISE_GLOBAL_CONFIG_FILE="$SB/config.toml"

   mise settings set jobs 4            # writes $SB/config.toml
   mise use -g node@24                  # writes $SB/config.toml
   mise -C "$SB" settings set --local experimental=true   # writes $SB/mise.toml (project file)
   mise -C "$SB" lock                   # writes $SB/mise.lock
   mise -C "$SB" upgrade --bump         # bumps versions in $SB/mise.toml + $SB/mise.lock

   unset MISE_GLOBAL_CONFIG_FILE
   ```

   Add `MISE_NO_CONFIG=1` if you want **no** config loaded at all (pure write isolation), e.g. `MISE_NO_CONFIG=1 MISE_GLOBAL_CONFIG_FILE=$SB/config.toml mise -C "$SB" use -g node@20` still writes `$SB/config.toml` — but then even the temp global file is not _read_ (verified: `MISE_NO_CONFIG=1 mise config ls` prints nothing, and a `[tools] node="20"` in the temp file is not listed).

   One-off alternative without touching the environment: `mise use -p "$SB/config.toml" node@24` (writes that file but still _reads_ your normal config for resolution).

**Non-existent things (checked, negative result):** there is **no `MISE_CONFIG_FILES` (plural) and no `MISE_CONFIG_FILE_ENV`** in mise — neither in the [environment-variables docs](https://mise.jdx.dev/configuration/environment-variables.html) nor anywhere in the [jdx/mise source tree](https://github.com/jdx/mise) (grep over `src/` and `docs/`).
`mise env` is read-only (prints the computed environment) and has no config-file target option (`mise env --help`). `mise install` never writes config; `mise upgrade --bump` "update[s] the version in mise.toml" — i.e. the config file that declares the tool, which in a sandbox is the temp file (`mise upgrade --help`).

## Mechanism 1: `--path` / `--file` flags on write commands

`mise use --help` (run locally):

> `-p, --path <PATH>` — Write to this config file, or to the config file in this directory. For a directory, mise picks the file by the usual write-target rules.

The [mise use docs page](https://mise.jdx.dev/cli/use.html) states the same and adds: "Use `--path` for an explicit file or directory, `--global` for personal defaults, or `--env` to write `mise.ENV.toml`... If you pass more than one, the last one wins." Source: [src/cli/use.rs](https://github.com/jdx/mise/blob/main/src/cli/use.rs).

Local dry-run verification (cwd = the chezmoi repo, i.e. the real config would otherwise be picked up):

```console
$ mise use --path /tmp/misetest_alt.toml -n node@24
mise would update /tmp/misetest_alt.toml (add: node@24.21.0)
```

Commands with an explicit-file flag (all verified via `--help` run locally and docs pages):

| Command                           | Flag                                       | Citation                                                                                                                                                                                      |
| --------------------------------- | ------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `mise use`                        | `-p, --path <PATH>`                        | [cli/use](https://mise.jdx.dev/cli/use.html)                                                                                                                                                  |
| `mise unuse`                      | `-p, --path <PATH>`                        | [cli/unuse](https://mise.jdx.dev/cli/unuse.html) ("Use `--path` to choose the file")                                                                                                          |
| `mise set`                        | `-f, --file <FILE>`                        | [cli/set](https://mise.jdx.dev/cli/set.html) ("Use `--global`, `--file`, or `-E <env>` to write elsewhere")                                                                                   |
| `mise unset`                      | `-f, --file <FILE>`                        | [cli/unset](https://mise.jdx.dev/cli/unset.html) ("Use `--global` or `--file` to pick another file")                                                                                          |
| `mise config set`                 | `-f, --file <FILE>`                        | [cli/config/set](https://mise.jdx.dev/cli/config/set.html) ("Use `--file` to select an existing project file")                                                                                |
| `mise settings set`/`add`/`unset` | **none** — only `-l/--local`, `--override` | `mise settings set --help`: "Writes ~/.config/mise/config.toml, or the nearest project config with `--local`... set `global_config_file` and similar through their **environment variables**" |

`--override` (available on `mise use`, `mise unuse`, `mise set`, `mise unset`, `mise settings set|add|unset`, `mise config get|set`) targets the global _override_ file `config.override.toml` instead, and conflicts with `--global` and `--path` ([configuration docs, "Override file"](https://mise.jdx.dev/configuration.html#override-file)). It is not a general temp-path mechanism.

## Mechanism 2: `MISE_GLOBAL_CONFIG_FILE` (alias `MISE_CONFIG_FILE`)

What it does ([configuration docs, "Global and system config"](https://mise.jdx.dev/configuration.html#global-config)):

> `global_config_file` (`MISE_GLOBAL_CONFIG_FILE`) replaces all of these files with one file. mise loads no `MISE_ENV` variants... or `.local` files beside it as global config... It also turns off the override files...
> It does not hide `~/.config/mise/config.toml` from projects under your home directory, which still load it as a project config; add `~/.config/mise/config.toml` to `ignored_config_paths` to skip it.

The [environment variables page](https://mise.jdx.dev/configuration/environment-variables.html) documents the legacy alias: `MISE_GLOBAL_CONFIG_FILE` — "`MISE_CONFIG_FILE` is an older name".
The settings reference entry ([settings#global_config_file](https://mise.jdx.dev/configuration/settings.html#global_config_file), from [schema/mise.json](https://github.com/jdx/mise/blob/main/schema/mise.json)): "One file to use as the global config instead of the config files in `~/.config/mise`."

Source code confirms the alias and the write path:

- [crates/mise-util/src/env.rs](https://github.com/jdx/mise/blob/main/crates/mise-util/src/env.rs): `pub static MISE_GLOBAL_CONFIG_FILE: Lazy<Option<PathBuf>> = Lazy::new(|| var_path("MISE_GLOBAL_CONFIG_FILE").or_else(|| var_path("MISE_CONFIG_FILE")));`
- [src/config/settings.rs](https://github.com/jdx/mise/blob/main/src/config/settings.rs), `global_tools_file()`: `env::var_path("MISE_GLOBAL_CONFIG_FILE").or_else(|| env::var_path("MISE_CONFIG_FILE")).unwrap_or_else(|| … dirs::CONFIG.join("config.toml"))` — the same fallback chain used when `mise use -g` has no `write_targets.tools`.
- [src/config/mod.rs](https://github.com/jdx/mise/blob/main/src/config/mod.rs), `global_config_files()`: when `MISE_GLOBAL_CONFIG_FILE` is set, the global tier is exactly `vec![that file]` (no `conf.d`, no `~/.tool-versions`), and `global_config_path()` — the default write target — falls back to `MISE_GLOBAL_CONFIG_FILE`.
- [src/cli/settings/set.rs](https://github.com/jdx/mise/blob/main/src/cli/settings/set.rs): the write path is chosen as `override → config::override_config_path()`, `local → config::local_toml_config_path()`, else `config::global_config_path()`;
  `mise settings add` delegates to the same function ([src/cli/settings/add.rs](https://github.com/jdx/mise/blob/main/src/cli/settings/add.rs)), and `settings unset` uses the same three-way choice ([src/cli/settings/unset.rs](https://github.com/jdx/mise/blob/main/src/cli/settings/unset.rs)).

So with the env var set:

- **loads:** the temp file is the only global config (verified: `MISE_CONFIG_FILE=$T/alt.toml mise config ls` lists only `$T/alt.toml`; with a `[tools]` section it shows the tools);
- **global writes** (`mise use -g`, `mise settings set|add|unset` without `--local`) go to it (verified by dry-run: `mise use -g -n node@20` → "mise would update $T/alt.toml"; the `settings set` code path above);
- **project writes are unaffected**: `mise settings set --local jobs 4` still wrote `./mise.toml` in the current directory, not the env-var file (verified as a real write in a temp dir);
- two caveats from the docs quote above, both seen live: when run from a directory under `$HOME` (e.g. the repo), the real `~/.config/mise/config.toml` still **loads as a project config** and can shadow tools (`mise WARN node is defined in ~/.config/mise/config.toml which overrides the global config ($T/alt.toml)`);
  and `--override` becomes an error because the env var "makes it the only global config and disables config.override.toml" ([src/config/mod.rs](https://github.com/jdx/mise/blob/main/src/config/mod.rs)).

Precedence among these env vars: `MISE_GLOBAL_CONFIG_FILE` beats `MISE_CONFIG_FILE`; both only replace the **global** tier — system config (`MISE_SYSTEM_CONFIG_FILE`), `.miserc.toml` discovery settings, and project configs are separate ([environment-variables docs](https://mise.jdx.dev/configuration/environment-variables.html)).

## Mechanism 3: sandbox working directory + `MISE_NO_CONFIG`

mise's default write rule ([configuration docs, "Which file mise writes to"](https://mise.jdx.dev/configuration.html#target-file-for-write-operations)): project writes go to "the lowest-precedence file in the nearest directory that has config... If no project config exists, it creates one in the current directory."
So a temp directory with its own `mise.toml` naturally collects all project writes, and `mise lock` / `mise upgrade --bump` operate on that config root.

- `MISE_NO_CONFIG=1` ("load no config files at all, the same as the `--no-config` flag" — [environment-variables docs](https://mise.jdx.dev/configuration/environment-variables.html)) prevents any discovered config from loading; writes then still land on their normal targets.
  Verified: `MISE_NO_CONFIG=1 mise -C $T use -n node@20` → "mise would update $T/mise.toml"; `MISE_NO_CONFIG=1 MISE_GLOBAL_CONFIG_FILE=$T/alt.toml mise -C $T use -g -n node@20` → "mise would update $T/alt.toml"; `MISE_NO_CONFIG=1 mise config ls` prints nothing (not even the env-selected file, so it is write-isolation only).
- The global `-C, --cd <DIR>` flag ("Run as if mise were started in DIR", from `mise config --help`) avoids `cd`-ing the current shell ([global flags](https://mise.jdx.dev/cli/#global-flags)).
- Running the sandbox **outside `$HOME`** (e.g. `mktemp -d`) means the directory walk-up finds no user configs, so the only loaded files are the env-selected global file and the sandbox's own project files (verified: `MISE_GLOBAL_CONFIG_FILE=$T/alt.toml mise -C $T config ls` lists only `$T/alt.toml` and `$T/mise.toml`).

## Worked example (recommended recipe for the chezmoi-managed config)

```bash
# 1. Sandbox directory outside $HOME, seeded with a copy of the real global config
SB=$(mktemp -d)                                  # e.g. /tmp/tmp.XXXX
cp ~/.config/mise/config.toml "$SB/config.toml"

# 2. Point mise's global config at the copy (nothing in ~/.config/mise is touched again)
export MISE_GLOBAL_CONFIG_FILE="$SB/config.toml"

# 3. Write commands now update the sandbox files:
mise settings set jobs 4                          # -> $SB/config.toml  [settings]
mise settings add disable_hints python_multi      # -> $SB/config.toml  [settings add]
mise settings unset jobs                          # -> $SB/config.toml  [settings unset]
mise use -g --pin node@24                         # -> $SB/config.toml  [tools]
mise -C "$SB" settings set --local python.compile=true   # -> $SB/mise.toml (project file)
mise -C "$SB" lock                                # -> $SB/mise.lock
mise -C "$SB" upgrade --bump                      # updates $SB/mise.toml + mise.lock

# 4. Confirm where mise thinks its config lives, then compare/diff before applying:
mise config ls                                    # lists $SB/config.toml (and $SB/mise.toml)
diff ~/.config/mise/config.toml "$SB/config.toml"

# 5. Clean up
unset MISE_GLOBAL_CONFIG_FILE
```

Alternative for a single command when you don't want to redirect reads: `mise use -p "$SB/config.toml" --pin node@24` — updates exactly that file (resolution still uses your normal config).

## Gaps / uncertainties

- The permission classifier blocked executing the **real** (non-dry-run) `mise use --path …` and `mise settings set` (global) writes during this research session (it failed closed on those commands), so those two write paths are evidenced by `--dry-run` output plus the cited source code, not by an observed completed write.
  A real write was observed for `mise settings set --local` (project target), and all dry-run outputs named the exact target file.
- Docs and source links point at jdx/mise `main` (2026-11-20); the installed CLI is 2026.11.10 and its `--help` text matches the docs verbatim, but flag details could drift in later releases.

## Sources

- [mise use — CLI reference](https://mise.jdx.dev/cli/use.html) — `-p, --path <PATH>`; `--global` / `--env` / `--override` write targets
- [mise.toml configuration — "Global and system config"](https://mise.jdx.dev/configuration.html#global-config) — `MISE_GLOBAL_CONFIG_FILE` semantics and the "still load it as a project config" caveat
- [mise.toml configuration — "Which file mise writes to"](https://mise.jdx.dev/configuration.html#target-file-for-write-operations) — default project write rule
- [mise.toml configuration — override files](https://mise.jdx.dev/configuration.html#override-file) — `--override` conflicts with `--global`/`--path`
- [Settings reference — global_config_file](https://mise.jdx.dev/configuration/settings.html#global_config_file) — "One file to use as the global config instead of the config files in `~/.config/mise`"
- [Settings — Settings with restricted locations](https://mise.jdx.dev/configuration/settings.html#settings-with-restricted-locations) — `global_config_file` is environment-only; `mise settings` refuses it
- [MISE_* variables](https://mise.jdx.dev/configuration/environment-variables.html) — `MISE_GLOBAL_CONFIG_FILE` with `MISE_CONFIG_FILE` as older name; `MISE_NO_CONFIG`; no plural `MISE_CONFIG_FILES` exists
- [mise unuse — CLI reference](https://mise.jdx.dev/cli/unuse.html) — `-p, --path <PATH>`
- [mise set — CLI reference](https://mise.jdx.dev/cli/set.html) — `-f, --file <FILE>`
- [mise unset — CLI reference](https://mise.jdx.dev/cli/unset.html) — `-f, --file <FILE>`
- [mise config set — CLI reference](https://mise.jdx.dev/cli/config/set.html) — `-f, --file <FILE>`
- [mise lock — CLI reference](https://mise.jdx.dev/cli/lock.html) — operates on the current config root
- [jdx/mise src/cli/settings/set.rs](https://github.com/jdx/mise/blob/main/src/cli/settings/set.rs) — write-target selection (override / local / `global_config_path()`)
- [jdx/mise src/cli/settings/add.rs](https://github.com/jdx/mise/blob/main/src/cli/settings/add.rs) — delegates to the same `set()` path
- [jdx/mise src/cli/settings/unset.rs](https://github.com/jdx/mise/blob/main/src/cli/settings/unset.rs) — same three-way target choice
- [jdx/mise crates/mise-util/src/env.rs](https://github.com/jdx/mise/blob/main/crates/mise-util/src/env.rs) — `MISE_GLOBAL_CONFIG_FILE` = `var_path("MISE_GLOBAL_CONFIG_FILE").or_else(var_path("MISE_CONFIG_FILE"))`
- [jdx/mise src/config/settings.rs](https://github.com/jdx/mise/blob/main/src/config/settings.rs) — `global_tools_file()` fallback chain
- [jdx/mise src/config/mod.rs](https://github.com/jdx/mise/blob/main/src/config/mod.rs) — `global_config_files()` / `global_config_path()` / `--override` disabled under `MISE_GLOBAL_CONFIG_FILE`
- [jdx/mise schema/mise.json](https://github.com/jdx/mise/blob/main/schema/mise.json) — `global_config_file` description
- Local CLI runs (mise 2026.11.10): `mise --version`, `mise use --help`, `mise config --help`, `mise config set --help`, `mise settings --help`, `mise settings set --help`, `mise settings add --help`, `mise set --help`, `mise lock --help`, `mise upgrade --help`, `mise env --help`, plus the dry-run/config-ls experiments quoted above
