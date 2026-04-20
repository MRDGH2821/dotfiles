#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = [
#   "PyYAML>=6",
# ]
# ///
"""Generate the packages table in Packages.md from the actual install files.

Sources of truth (read-only):
  .chezmoidata/packages/linux/{arch,debian,fedora,ubuntu,linux_common}.yaml
  .chezmoidata/packages/windows.yaml
  .chezmoidata/packages/rust.yaml
  dot_config/soar/packages.toml

Mapping layer (edit to add display names / cross-distro aliases):
  scripts/packages-names.yaml

After running this script, treefmt will sort rows and align columns via
sort-markdown-tables and prettier.

Usage:
    uv run scripts/gen-packages-table.py
"""

from __future__ import annotations

import re
import tomllib
from pathlib import Path
from typing import Any

import yaml

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------
REPO_ROOT = Path(__file__).parent.parent
PACKAGES_MD = REPO_ROOT / "Packages.md"
NAMES_FILE = REPO_ROOT / ".zed" / "packages-names.yaml"
TABLE_MARKER = "<!-- smt -->"

LINUX_DIR = REPO_ROOT / ".chezmoidata" / "packages" / "linux"
WINDOWS_YAML = REPO_ROOT / ".chezmoidata" / "packages" / "windows.yaml"
RUST_YAML = REPO_ROOT / ".chezmoidata" / "packages" / "rust.yaml"
SOAR_TOML = REPO_ROOT / "dot_config" / "soar" / "packages.toml"

# Column keys → header labels (alphabetical = matches yq-key-sort + treefmt)
COLUMNS: list[tuple[str, str]] = [
    ("arch", "Arch"),
    ("debian", "Debian"),
    ("fedora", "Fedora"),
    ("ubuntu", "Ubuntu"),
    ("windows", "Windows"),
]

# ---------------------------------------------------------------------------
# Emoji constants
# ---------------------------------------------------------------------------
SKIP = "🚫"
NATIVE = "👍"
FLATPAK = "📦"
BINARY_URL = "💻🔗"
NATIVE_URL = "👍🔗"
APPIMAGE_SOAR = "🖼️🪽🔗"
SOAR = "🪽🔗"
SOAR_BARE = "🪽"  # soar entry that has a pkg_id (uses system store, no direct URL)
DRA = "👍📥"  # dra: package: [...] (GitHub release download, selects asset)
DRA_BARE = "📥"  # dra: [...] (bare dra list, no asset selection)
CARGO = "🦀"  # cargo install (from crates.io source)
CARGO_BINSTALL = "🦀💻"  # cargo binstall (downloads precompiled binary)
CARGO_GIT = "🦀🔗"  # cargo install --git (from a git repo)

# These packages are installed via URL on the given distro, keyed by URL fragment
# Maps (URL fragment substring) → display name
_URL_FRAGMENT_MAP: dict[str, str] = {
    "steam": "Steam",
    "discord": "Discord",
    "gitkraken": "Gitkraken",
}

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def _load_yaml(path: Path) -> dict[str, Any]:
    return yaml.safe_load(path.read_text(encoding="utf-8")) or {}


def _resolve(pkg_id: str, aliases: dict[str, str]) -> str:
    """Return canonical display name for a raw package ID."""
    return aliases.get(pkg_id, pkg_id)


def _extract_installer_url_name(cmd: str) -> str | None:
    """Pull the binary name from an 'if ! command -v X' installer-url line."""
    m = re.search(r"command -v (\S+)", cmd)
    return m.group(1) if m else None


def _extract_dra_repo_name(spec: str) -> str:
    """'owner/RepoName --select ...' → 'RepoName'."""
    return spec.split("/")[1].split()[0]


def _set_if_better(
    packages: dict[str, dict[str, str]],
    display: str,
    distro: str,
    emoji: str,
) -> None:
    """Set packages[display][distro] = emoji only if not already set by a
    higher-priority source.  Priority: native/flatpak/dra/installer > soar.
    Soar entries are treated as fallback; they must NOT overwrite an explicit
    distro-file entry.
    """
    packages.setdefault(display, {})[distro] = emoji


def _set_soar_fallback(
    packages: dict[str, dict[str, str]],
    display: str,
    distro: str,
    emoji: str,
) -> None:
    """Set packages[display][distro] = emoji only if the slot is empty."""
    packages.setdefault(display, {}).setdefault(distro, emoji)


# ---------------------------------------------------------------------------
# Linux YAML parser
# ---------------------------------------------------------------------------

# Keys whose children apply to ALL four Linux distros (used for linux_common)
_ALL_LINUX = ("arch", "debian", "fedora", "ubuntu")


def _parse_linux_yaml(
    path: Path,
    distros: tuple[str, ...],
    aliases: dict[str, str],
    packages: dict[str, dict[str, str]],
) -> None:
    """Parse a Linux YAML and set packages[display][distro] entries.

    `distros` is the set of distros this file applies to.  For per-distro
    files it's a single-element tuple; for linux_common it's all four.
    """
    data = _load_yaml(path)

    def _emit(raw_id: str, emoji: str) -> None:
        display = _resolve(raw_id, aliases)
        for d in distros:
            _set_if_better(packages, display, d, emoji)

    def _walk(node: Any, key_path: tuple[str, ...]) -> None:
        if isinstance(node, dict):
            for k, v in node.items():
                _walk(v, key_path + (k,))
            return

        if not isinstance(node, list):
            return

        for item in node:
            if not isinstance(item, str):
                continue

            # ---- installer_url ------------------------------------------------
            if "installer_url" in key_path:
                name = _extract_installer_url_name(item)
                if name:
                    _emit(name, BINARY_URL)
                continue

            # ---- dra.package --------------------------------------------------
            if "dra" in key_path and "package" in key_path:
                raw = _extract_dra_repo_name(item)
                _emit(raw, DRA)
                continue

            # ---- bare dra list ------------------------------------------------
            if "dra" in key_path:
                _emit(item, DRA_BARE)
                continue

            # ---- url sublists (nala.url, dnf5.url) ----------------------------
            if key_path and key_path[-1] == "url":
                # Skip commented-out lines
                stripped = item.strip()
                if stripped.startswith("#"):
                    continue
                # Match against known URL fragments
                low = stripped.lower()
                for fragment, display in _URL_FRAGMENT_MAP.items():
                    if fragment in low:
                        for d in distros:
                            _set_if_better(packages, display, d, NATIVE_URL)
                        break
                continue

            # ---- flatpak ------------------------------------------------------
            if "flatpak" in key_path:
                _emit(item, FLATPAK)
                continue

            # ---- everything else is native ------------------------------------
            _emit(item, NATIVE)

    _walk(data, ())


# ---------------------------------------------------------------------------
# Rust YAML parser
# ---------------------------------------------------------------------------


def _parse_rust_yaml(
    path: Path,
    aliases: dict[str, str],
    packages: dict[str, dict[str, str]],
) -> None:
    """Parse rust.yaml and set packages[display][distro] for all Linux distros.

    Sections:
      binstall: → 🦀💻  (cargo binstall — downloads precompiled binary)
      install:  → 🦀    (cargo install — compiles from crates.io)
      git:      → 🦀🔗  (cargo install --git — from a git repo URL)
    """
    data = _load_yaml(path)

    def _emit_rust(raw_id: str, emoji: str) -> None:
        display = _resolve(raw_id, aliases)
        for d in _ALL_LINUX:
            _set_if_better(packages, display, d, emoji)

    for pkg_id in data.get("binstall", []):
        _emit_rust(pkg_id, CARGO_BINSTALL)

    for pkg_id in data.get("install", []):
        _emit_rust(pkg_id, CARGO)

    for git_url in data.get("git", []):
        # Extract repo name from URL: https://github.com/owner/repo → repo
        repo_name = git_url.rstrip("/").split("/")[-1]
        _emit_rust(repo_name, CARGO_GIT)


# ---------------------------------------------------------------------------
# Windows YAML parser
# ---------------------------------------------------------------------------


def _parse_windows_yaml(
    path: Path,
    aliases: dict[str, str],
    packages: dict[str, dict[str, str]],
) -> None:
    data = _load_yaml(path)
    for pkg_id in data.get("winget", []):
        display = _resolve(pkg_id, aliases)
        _set_if_better(packages, display, "windows", NATIVE)


# ---------------------------------------------------------------------------
# Soar TOML parser
# ---------------------------------------------------------------------------


def _parse_soar_toml(
    path: Path,
    aliases: dict[str, str],
    packages: dict[str, dict[str, str]],
) -> None:
    soar = tomllib.loads(path.read_text(encoding="utf-8"))
    for pkg_name, cfg in soar.get("packages", {}).items():
        display = _resolve(pkg_name, aliases)
        is_appimage = cfg.get("pkg_type") == "appimage"
        # pkg_id means soar can install from a system store (no direct URL link
        # shown to end-user) — but for the table we use the same "🪽🔗" as all
        # other soar packages because the install is still via soar.
        emoji = APPIMAGE_SOAR if is_appimage else SOAR
        for distro in _ALL_LINUX:
            # Soar is a fallback: only fills slots not already covered by a
            # per-distro native/flatpak/dra/installer entry.
            _set_soar_fallback(packages, display, distro, emoji)


# ---------------------------------------------------------------------------
# Table generation
# ---------------------------------------------------------------------------


def _row(cells: list[str]) -> str:
    return "| " + " | ".join(cells) + " |"


def generate_table(packages: dict[str, dict[str, str]]) -> str:
    headers = ["Name", *(label for _, label in COLUMNS)]
    lines: list[str] = [
        _row(headers),
        _row(["---"] * len(headers)),
    ]
    for name, distros in sorted(packages.items(), key=lambda x: x[0]):
        cells = [name, *(distros.get(col, SKIP) for col, _ in COLUMNS)]
        lines.append(_row(cells))
    return "\n".join(lines)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------


def main() -> None:
    # Load mapping file
    names_data = _load_yaml(NAMES_FILE)
    aliases: dict[str, str] = names_data.get("aliases", {})
    static: dict[str, dict[str, str]] = names_data.get("static", {})

    # Build the package matrix
    packages: dict[str, dict[str, str]] = {}

    # 1. Seed with static entries (manually-managed packages not in install files)
    for display, distros in static.items():
        packages[display] = dict(distros)

    # 2. Parse per-distro Linux YAMLs (highest priority for their distro)
    for distro in ("arch", "debian", "fedora", "ubuntu"):
        yaml_path = LINUX_DIR / f"{distro}.yaml"
        if yaml_path.exists():
            _parse_linux_yaml(yaml_path, (distro,), aliases, packages)

    # 3. Parse linux_common.yaml — applies to all four Linux distros
    common_path = LINUX_DIR / "linux_common.yaml"
    if common_path.exists():
        _parse_linux_yaml(common_path, _ALL_LINUX, aliases, packages)

    # 4. Parse Windows
    if WINDOWS_YAML.exists():
        _parse_windows_yaml(WINDOWS_YAML, aliases, packages)

    # 5. Parse rust.yaml — applies to all Linux distros (binstall/install/git)
    if RUST_YAML.exists():
        _parse_rust_yaml(RUST_YAML, aliases, packages)

    # 6. Parse soar (FALLBACK — fills slots not already set by install files)
    if SOAR_TOML.exists():
        _parse_soar_toml(SOAR_TOML, aliases, packages)

    # Generate and inject the table
    content = PACKAGES_MD.read_text(encoding="utf-8")
    idx = content.find(TABLE_MARKER)
    if idx == -1:
        msg = f"Marker '{TABLE_MARKER}' not found in {PACKAGES_MD}"
        raise ValueError(msg)

    prefix = content[: idx + len(TABLE_MARKER)]
    table = generate_table(packages)
    PACKAGES_MD.write_text(f"{prefix}\n\n{table}\n", encoding="utf-8")
    print(f"Updated {PACKAGES_MD.relative_to(REPO_ROOT)}")
    print(f"  {len(packages)} packages")


if __name__ == "__main__":
    main()
