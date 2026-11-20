# mise `[dotfiles]` in the wild: real-world usage, experience, and adoption

**Date:** 2026-11-20
**Question:** The prior note ([2026-11-20-mise-as-dotfiles-manager.md](./2026-11-20-mise-as-dotfiles-manager.md)) verified mise's dotfiles subsystem from docs and a scratch clone. What does real-world usage look like ~5 months after the feature landed in v2026.6.6 (2026-06-13): who uses it publicly, what breaks, what does the author promise, and how big is adoption?

Method: GitHub code/issue/commit search via the authenticated API and direct fetches of repos, issues,
discussions, release notes, and blog posts, all on 2026-11-20. GitHub code search counts are exact at query
time but only index public default branches — anything in a private repo or a global
`~/.config/mise/config.toml` (where `track` mode lives) is invisible to it. Primary evidence (repos, issues,
release notes, official posts) is kept separate from secondary commentary (blogs, Reddit), and opinion is
labeled.

## Summary

Adoption is real but young and **symlink-dominated**. GitHub code search finds **453 `mise.toml` files
containing `[dotfiles]`**; the highest-profile user is
[nicknisi/dotfiles](https://github.com/nicknisi/dotfiles) (3,004 stars, machine setup now "Mise bootstrap and
tasks" per its README). The upstream tracker shows **194 issues/PRs with `dotfiles` in the title** and **51
releases since v2026.6.6 whose notes mention dotfiles/fnox/history-watch** — a heavy, still-ongoing fix
cadence that includes a genuinely dangerous early bug (`mise dot apply` overwriting locally edited copies with
no TTY and no `--yes`, [#15528](https://github.com/jdx/mise/issues/15528)) fixed only in the v2026.11.x
window. The announcement post's headline feature — in-place tracking with auto-save — is barely visible in
public repos (`mode = "track"`: 3 hits). No showstopper beyond what the prior note already found, but the
community's own migration reports confirm the chezmoi gaps, and one blogger's answer to "my dotfiles outgrew
Stow" was **chezmoi, not mise**.

## 1. Public dotfiles repos using mise `[dotfiles]`

Code search `[dotfiles] filename:mise.toml` = 453 hits (2026-11-20). Repos inspected directly (primary evidence — each `mise.toml` fetched and read):

| Repo (stars)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                | Modes used                                                                                                                                                                                                                                                                                    | Notable                                                                                                                                                                                                                                                                                                                                                               |
| ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [nicknisi/dotfiles](https://github.com/nicknisi/dotfiles) (3,004★)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          | default (symlink); bare-string entries (`"~/.??*" = "home/.??*"`)                                                                                                                                                                                                                             | [mise.toml](https://github.com/nicknisi/dotfiles/blob/main/mise.toml) comments explain **relative sources resolve against the file's own dir**, so the clone can live anywhere with zero per-machine config; the global `config.toml` deliberately has no `[dotfiles]`. README documents full `mise bootstrap` flow ([README](https://github.com/nicknisi/dotfiles)). |
| [yutkat/dotfiles](https://github.com/yutkat/dotfiles) (1,002★)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              | default (symlink), globs (`"~/.config/*"`)                                                                                                                                                                                                                                                    | Repository of a known dotfiles curator; `[tasks.dotfiles-apply]` wraps `mise bootstrap dotfiles apply --yes`; notes a real directory "owned by Home Manager" that must not be linked whole ([mise.toml](https://github.com/yutkat/dotfiles/blob/main/mise.toml)).                                                                                                     |
| [TechDufus/dotfiles](https://github.com/TechDufus/dotfiles) (414★)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          | symlink, `symlink-each`, `absent`                                                                                                                                                                                                                                                             | Most engineered setup seen: **per-app `mise.toml` modules** under `modules/<app>/` linked into `~/.config/mise/conf.d`, with profiles (Omarchy/macOS), a work/personal purpose marker, and a defensive wrapper script that backs up conflicting targets before apply ([README](https://github.com/TechDufus/dotfiles)). "Applied with mise" badge.                    |
| [alex35mil/dotfiles](https://github.com/alex35mil/dotfiles) (303★)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          | (hit in search; not inspected in detail)                                                                                                                                                                                                                                                      | —                                                                                                                                                                                                                                                                                                                                                                     |
| [dkarter/dotfiles](https://github.com/dkarter/dotfiles) (130★)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              | default (symlink), ~18 plain entries + `"~/.config/*"` glob                                                                                                                                                                                                                                   | Also uses `[bootstrap.macos]` for dock/finder/trackpad/keyboard defaults ([mise.toml](https://github.com/dkarter/dotfiles/blob/main/mise.toml)).                                                                                                                                                                                                                      |
| [prabirshrestha/dotfiles](https://github.com/prabirshrestha/dotfiles) (100★), [iain/dotfiles](https://github.com/iain/dotfiles) (90★), [jawilson/dotfiles](https://github.com/jawilson/dotfiles) (77★), [jefftriplett/dotfiles](https://github.com/jefftriplett/dotfiles) (66★), [kiyoon/dotfiles](https://github.com/kiyoon/dotfiles) (47★), [lvancrayelynghe/dotfiles](https://github.com/lvancrayelynghe/dotfiles) (27★), [sagebind/dotfiles](https://github.com/sagebind/dotfiles) (17★), [kenchan/dotfiles](https://github.com/kenchan/dotfiles) (20★) | symlink mostly; kiyoon adds **`variants = [{ os = "macos" }]`** entries; lvancrayelynghe adds `symlink-each` for mixed directories (`.vim`, `.git-templates`) and repo-scoped `[dotfiles]` with the same config-root reasoning as nicknisi; sagebind sets `dotfiles.default_mode = "symlink"` | All fetched; all pushed within the last week — the sample is actively maintained, not abandoned experiments.                                                                                                                                                                                                                                                          |

Mode usage across GitHub (`filename:mise.toml "mode = \"…\""` counts, 2026-11-20; primary query results):

- `symlink-each` 141, `copy` 125, `template` 79, `absent` 18, `merge` 11, `track` 3, `fnox` 0, `line` 0, `block` 0, `track-local` 0.
- Honest caveat: these are counts of _files containing the string_, not verified working setups;
  `track`/`fnox`/edit modes realistically live in private global config (per the
  [docs](https://mise.jdx.dev/dotfiles.html), tracking is declared in `~/.config/mise/config.toml`), so public
  code search undercounts them by construction. But even granting that, the visible ecosystem is symlink-first,
  exactly the model the docs list as default.

## 2. Community experience: jdx/mise issues, discussions, release notes (primary)

Scale of churn: **194 issues/PRs with `dotfiles` in the title** in jdx/mise (search on 2026-11-20), clustered
after v2026.6.6; **51 releases from v2026.6.6 (2026-06-13) through v2026.11.10 (2026-11-18) mention
dotfiles/fnox/history-watch** in their notes (release-API scan). Two pre-feature releases already mention
"dotfiles" (v2025.10.13, v2026.4.14) — groundwork, not the subsystem. Release cadence of dotfiles fixes is
roughly weekly; the biggest single dotfiles release is **v2026.10.23** ([release
notes](https://github.com/jdx/mise/releases/tag/v2026.10.23)): `mode = "fnox"`, INI merge, dotfile-group
block/line/merge edits, and a perf fix that cut `mise dot status` on ~860 tracked files "from about 7s to
1.4s" ([#15127](https://github.com/jdx/mise/pull/15127)).

Recurring problems, grouped from the issue titles (all primary, state as of 2026-11-20):

- **Data loss near-miss (most serious):** without a TTY, `mise dot apply` overwrote locally edited copies with
  no `--yes` and no way to undo ([#15528](https://github.com/jdx/mise/issues/15528), filed 2026-11-09); fixed by
  refusing to overwrite edited copies without a terminal ([#15565](https://github.com/jdx/mise/issues/15565))
  and warning when a copy target was edited since mise wrote it
  ([#15600](https://github.com/jdx/mise/issues/15600)), landing in v2026.11.7–v2026.11.10. **Lesson: pin ≥
  v2026.11.7.**
- **Windows is the weakest platform:** a cluster fixed on 2026-11-01
  ([#15246](https://github.com/jdx/mise/issues/15246), [#15247](https://github.com/jdx/mise/issues/15247),
  [#15248](https://github.com/jdx/mise/issues/15248), [#15249](https://github.com/jdx/mise/issues/15249),
  [#15252](https://github.com/jdx/mise/issues/15252), [#15253](https://github.com/jdx/mise/issues/15253)) —
  junction/symlink unapply, case-changing paths splitting state files, symlink-each pruning; and "Windows
  symlink-each copies need `--force` once the source changes" needed a docs note
  ([#15247](https://github.com/jdx/mise/issues/15247)).
- **State/tracking edge cases:** batch untrack dropped earlier successful tracking when a later path failed
  ([#15206](https://github.com/jdx/mise/issues/15206), fixed
  [#15208](https://github.com/jdx/mise/issues/15208)); widening a tracked directory to its parent froze autosave
  and `pull` could not clear it ([#15186](https://github.com/jdx/mise/issues/15186), fixed
  [#15187](https://github.com/jdx/mise/issues/15187)); a failed apply now carries on instead of aborting the run
  ([#15253](https://github.com/jdx/mise/issues/15253)).
- **Symlink-each dangers:** following user directory links in a target ([#15399](https://github.com/jdx/mise/issues/15399)), dangling links ([#15395](https://github.com/jdx/mise/issues/15395)), state cleanup when a group is removed ([#15390](https://github.com/jdx/mise/issues/15390)).
- **Secrets in history:** a history secret scan now exists and gained "approve harmless values" ([#15864](https://github.com/jdx/mise/issues/15864), 2026-11-18) — evidence the leakage concern from the announcement (below) was real enough to need tooling.

Two design discussions matter most to a chezmoi migrator:

- **[#13410 — "[dotfiles] Six gaps found migrating a real setup off
  chezmoi"](https://github.com/jdx/mise/discussions/13410)** (discussion; issue/PR numbers #13411–#13427).
  @waynehoover's gaps and maintainer response: (1) `mise dot track` swallows directories without a preview —
  `mise dot paths --preview` existed but was undocumented, PR [#13417](https://github.com/jdx/mise/pull/13417);
  (2) no per-entry `exclude` on track — PR [#13418](https://github.com/jdx/mise/pull/13418), reporter conceded
  it was "a nicety rather than a fix"; (3) parent-directory permissions not captured — PR
  [#13412](https://github.com/jdx/mise/pull/13412); (4) nested git repos stored as gitlinks and silently dropped
  — now warns and skips ([#13416](https://github.com/jdx/mise/pull/13416)); (5) credential-guard omissions not
  reported at save time — PR [#13415](https://github.com/jdx/mise/pull/13415); (6) no hook after apply — PR
  [#13414](https://github.com/jdx/mise/pull/13414), with the first-adopt case unresolved. As of the fetch, only

## 13411 is merged; the rest are open PRs or design questions. **This is the community-authored mirror of the

prior note's feature-loss table, from someone who actually did the migration.**

- **[#13934 — "Dotfiles UX from a multi-environment GNU Stow user's
  perspective"](https://github.com/jdx/mise/discussions/13934)**: a Linux/Windows/WSL Stow user's needs (per-app
  packages, controlled folding, per-environment differences) led directly to **dotfile groups** —
  `[dotfile_groups.<name>]` with a `root`, full mode set, and profiles selecting groups via `[bootstrap]
dotfile_groups`, merged in [#13945](https://github.com/jdx/mise/pull/13945) and extended in v2026.10.23
  ([release notes](https://github.com/jdx/mise/releases/tag/v2026.10.23)). Still open from that thread: Windows
  `symlink-each` behavior and template edit capture. Also evidence the maintainer will decline designs flatly
  ("i do not want to discuss it further" on a settings-restructuring proposal).

### 3. The announcement post vs. the docs now

[Dotfiles That Save Themselves — @jdx,
2026-09-07](https://jdx.dev/posts/2026-09-07-dotfiles-that-save-themselves/) (primary, linked from the docs).
What it actually promises is **the third model** — not Stow-style symlinks, not chezmoi-style generated files,
but _tracking_: "Change `.zshrc` on my laptop and mise saves it, shares it, and applies it on my desktop."
Concretely: `mise dot track` + a background `history-watch` service (LaunchAgent / systemd user unit /
Scheduled Task), history stored "in a Git repository by default, so no `.git` directory is needed in your home
directory", `rollback`/`undo`, `origin set` sharing with `--sync manual`, conflict resolution that pauses and
never writes conflict markers, `encrypt = true` with a recipient list for history contents, and `mise dot
capture -- <command>` checkpoints around e.g. an Omarchy update.

The author's own caveats, verbatim in substance: "I don't recommend making your dotfiles repository public with automatic syncing enabled"; the push check "enforces encryption declarations only. It doesn't scan unencrypted files for secrets"; a secret briefly stored unencrypted persists in an intermediate commit; untrack stops capture but doesn't erase old commits.

Versus the docs today ([dotfiles](https://mise.jdx.dev/dotfiles.html) /
[managed](https://mise.jdx.dev/dotfiles/managed.html)): everything the post promises for `track` is
documented, plus the deploy modes (`symlink`/`symlink-each`/`copy`/`template`) the post treats as optional
extras — the docs give both equal billing. Two post claims have since been softened or superseded in practice:
(a) the post's history-store `encrypt = true` is the only in-mise encryption story for _tracked_ files, while
the newer `fnox` mode (v2026.10.23, [#15134](https://github.com/jdx/mise/pull/15134)) handles _deployed_
secret files — two mechanisms where chezmoi has several; (b) the secret-leakage caveats the post states by
hand now have tooling (#15864's secret scan) — i.e., the caveats were real, not hypothetical. The post's open
items (squashing unpublished saves, conflict surfacing) remain open.

### 4. Migration write-ups (mixed primary/secondary; opinion marked)

- **chezmoi → mise, positive:** "[mise の dotfiles 機能で chezmoi
  を代替できるか試した](https://gr1m0h.hatenablog.com/entry/2026/09/13/233325)" (Howdunit, 2026-09-13; hands-on,
  primary-in-spirit). Tracked `~/.zshrc` etc. across a personal and a work machine; enabled `history-watch`;
  synced to a dedicated `mise-sync` branch. Hit: unrelated histories made the existing `main` unusable as origin
  ("The `--branch` option also doesn't create branches"); a macOS watcher silent failure caused by broken Xcode
  CLT git; secrets must be encrypted _before the first save_. Verdict (opinion): reduced daily operations for
  few machine differences; chezmoi's template-centric model fits better when machine differences are extensive.
- **chezmoi → mise, critical:** the [#13410 discussion](https://github.com/jdx/mise/discussions/13410) above — six concrete gaps, most fixes still open PRs.
- **Stow → mise, positive:** "[Manage your dotfiles with mise](https://blog.verybadfrags.com/posts/manage-dotfiles-with-mise/)" (secondary; author's own migration from GNU Stow). Uses `symlink-each` for `zsh-custom` so files can be added without tracking the whole oh-my-zsh folder; calls the setup more complex than Stow but is "happy with the trade-off" (opinion).
- **Deciding against mise, for chezmoi:** "[My dotfiles outgrew GNU
  Stow](https://ayydany.com/2026/07/28/my-dotfiles-outgrew-gnu-stow/)" (2026-07-28; secondary; mise not even
  considered in the post). The author had "simply built a small configuration manager around [Stow] and was
  pretending I had not"; a Windows machine was the trigger; chose chezmoi for derived profiles, per-platform
  templates, native package managers, and regular files with `diff`/`apply`/`verify` — i.e., they wanted exactly
  the features the prior note lists as mise's gaps.
- **Both, deliberately:** "[Dotfile Management with mise and chezmoi: The Perfect Combo](https://tommeurs.nl/en/posts/dotfile-management-mise-chezmoi/)" (secondary) — mise for tool versions, chezmoi for dotfiles; the complementary framing is also what chezmoi's own articles page links to ([chezmoi.io/links/articles](https://www.chezmoi.io/links/articles/)).
- **General sentiment (secondary, opinion):** r/dotfiles threads ("[Why I stuck with GNU Stow instead of
  chezmoi or
  yadm](https://www.reddit.com/r/dotfiles/comments/1qy9vbe/why_i_stuck_with_gnu_stow_instead_of_chezmoi_or/)",
  "[Best tool to manage multiple
  dotfiles](https://www.reddit.com/r/dotfiles/comments/1pvq3hh/best_tool_to_manage_multiple_dotfiles/)") show
  Stow-vs-chezmoi dominating discussion; mise dotfiles barely registers there. Hacker News: one story ("Dotfiles
  – Mise-En-Place", 2026-10-02) at **4 points, 1 comment** ([HN
  search](https://hn.algolia.com/api/v1/search?query=mise%20dotfiles&tags=story)) — essentially no HN traction
  yet.

### 5. Adoption scale, honestly

- **453** public `mise.toml` files with `[dotfiles]` (GitHub code search, 2026-11-20) — against roughly 200k+ repos GitHub search finds for a `chezmoi`-style marker; the absolute number is small and the feature is ~5 months old. Context: jdx/mise itself has 36,327 stars (API).
- Of those 453, 13 sampled repos were read directly; all are actively pushed (last week of 2026-11) and the largest is 3,004 stars — this is not a toy-only feature, but no single "reference implementation" has emerged yet.
- Upstream investment is disproportionately high: 194 titled issues/PRs, 51 dotfiles-mentioning releases in 5 months, and the maintainer personally answering design discussions within days. The risk profile is "young and fast-moving," not "abandoned."
- The `track`/auto-save model the announcement centers on is the _least_ visible in public (3 `mode = "track"` hits, and those live in global config by design, so hard to observe) — the ecosystem has so far converged on `symlink`/`symlink-each`, the most conservative mode.

### What this means for the migration

1. **Examples to copy exist, at every scale.** nicknisi (3k★) is the closest match to this repo's shape:
   repo-scoped `mise.toml` with relative sources, a full `mise bootstrap` flow, and explicit comments on why
   `[dotfiles]` must not live in the global config (same `config_root` reasoning as lvancrayelynghe). TechDufus
   shows the per-app module + `conf.d` pattern plus `absent` and group/profile selection, if this repo ever wants
   per-app organization. kiyoon shows `variants = [{ os = "macos" }]` for the Windows/macOS split this repo
   already has (winget/mise bootstrap work, commit 7304ab2).
2. **The wild validates the prior note's loss table.** waynehoover's six gaps (#13410) overlap it almost
   exactly (no interactive prompts, no per-entry excludes, permission capture, hook timing), and the one "outgrew
   Stow" writer in the same period chose chezmoi for precisely the features mise lacks. Nobody public was found
   doing a template-heavy chezmoi-style setup in mise; `template` appears in 79 files but no inspected repo
   builds on it — consistent with the prior note's no-cross-file-include finding.
3. **Showstopper check: one, already fixed.** The non-TTY copy-overwrite data-loss bug (#15528) is disqualifying for any version before v2026.11.7. Pin mise ≥ 2026.11.7 and re-check the release notes before each upgrade; fixes land weekly and Windows remains the roughest platform.
4. **The tracking/auto-save headline feature is unproven in public.** If the migration's appeal was "dotfiles
   that save themselves," note that almost no one demonstrably runs that in the wild yet, its macOS watcher has
   had silent-failure reports (gr1m0h), and the author himself warns against auto-syncing a public repo with
   secrets in history. This repo's current chezmoi setup already solves the save-back problem via `chezmoi add`.
5. **Net: same verdict as the prior note, now with community evidence — wait-and-see or partial.** The
   strongest community-endorsed patterns for this repo are the symlink/bulk-entries style with `mise bootstrap`
   (well proven in the wild) while keeping chezmoi (or pre-rendered sources) for templated and secret-heavy files
   — the "perfect combo" several writers independently landed on. A full port is justified only if reducing to
   one tool outweighs reworking ~15 shared template fragments into inline Tera and accepting fnox-only secrets.
