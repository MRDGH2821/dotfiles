#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = [
#   "rich>=13",
# ]
# ///
"""Query Repology for a project and filter results to known repos.

Usage:
    uv run repology-filter.py <project>
    uv run repology-filter.py           # prompts interactively

Check exact repo IDs at https://repology.org/repository/<id>.
"""

from __future__ import annotations

import json
import sys
import urllib.request
from urllib.error import HTTPError, URLError

from rich.console import Console
from rich.table import Table
from rich import box

# ---------------------------------------------------------------------------
# Repos to filter for
# ---------------------------------------------------------------------------
REPOS: list[str] = [
    "aur",  # Arch User Repository
    "arch",  # Arch Linux official repos
    "debian_13",  # Debian 13 (Trixie)
    "ubuntu_24_04",  # Ubuntu 24.04
    "fedora_43",  # Fedora 43
    "terra",  # TERRA
    "chaotic_aur",  # Chaotic-AUR
    "nix_unstable",  # Nix unstable
]

# Status → color mapping
_STATUS_STYLE: dict[str, str] = {
    "newest": "bold green",
    "devel": "cyan",
    "unique": "blue",
    "outdated": "red",
    "legacy": "yellow",
    "ignored": "dim",
    "incorrect": "magenta",
    "untrusted": "magenta",
    "noscheme": "dim",
    "rolling": "cyan",
}

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def matches_repo(repo: str) -> bool:
    """Return True if repo matches any entry in REPOS (exact or prefix)."""
    return any(repo == r or repo.startswith(r) for r in REPOS)


def query_repology(project: str) -> list[dict]:
    url = f"https://repology.org/api/v1/project/{project}"
    req = urllib.request.Request(
        url, headers={"User-Agent": "repology-shell-filter/0.1"}
    )
    try:
        with urllib.request.urlopen(req) as resp:
            return json.loads(resp.read().decode())
    except HTTPError as e:
        print(f"Error: HTTP {e.code} from Repology API", file=sys.stderr)
        sys.exit(1)
    except URLError as e:
        print(f"Error: Could not reach Repology API: {e.reason}", file=sys.stderr)
        sys.exit(1)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------


def main() -> None:
    if len(sys.argv) >= 2:
        project = sys.argv[1]
    else:
        project = input("Enter project name (e.g., firefox): ").strip()
        if not project:
            print("Error: Project name cannot be empty", file=sys.stderr)
            sys.exit(1)

    packages = query_repology(project)

    rows = []
    for pkg in packages:
        repo = pkg.get("repo", "")
        if not matches_repo(repo):
            continue
        name = pkg.get("visiblename") or pkg.get("srcname") or "-"
        version = pkg.get("version") or "-"
        status = pkg.get("status") or "-"
        rows.append((repo, name, version, status))

    if not rows:
        print(
            f"No results found for [bold]{project}[/bold] in the configured repos.",
            file=sys.stderr,
        )
        sys.exit(0)

    console = Console()

    table = Table(
        title=f"Repology — [bold cyan]{project}[/bold cyan]",
        box=box.ROUNDED,
        show_lines=False,
        highlight=True,
    )
    table.add_column("Repo", style="bold", no_wrap=True)
    table.add_column("Package", no_wrap=True)
    table.add_column("Version", no_wrap=True)
    table.add_column("Status", no_wrap=True)

    for repo, name, version, status in rows:
        style = _STATUS_STYLE.get(status, "")
        table.add_row(
            repo, name, version, f"[{style}]{status}[/{style}]" if style else status
        )

    console.print(table)


if __name__ == "__main__":
    main()
