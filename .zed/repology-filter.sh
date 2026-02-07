#!/usr/bin/env bash

set -euo pipefail

PROJECT="${1:-firefox}"
API="https://repology.org/api/v1/project/${PROJECT}"

# Map human names to Repology repo IDs (you can adjust these).
# You can check exact IDs at https://repology.org/repository/<id>.
REPOS=(
  "aur"          # Arch User Repository
  "arch"         # Arch Linux official repos
  "debian_13"    # Debian 13 (Trixie)
  "ubuntu_24_04" # Ubuntu 24.04
  "fedora_43"    # Fedora 43
  "terra"        # TERRA (if it exists; adjust if needed)
  "chaotic_aur"  # Chaotic‑AUR
  "nix_unstable" # Nix unstable
)

# Function to check if a repo matches our list
matches_repo() {
  local repo="$1"
  for pattern in "${REPOS[@]}"; do
    if [[ "$repo" == "$pattern" ]] || [[ "$repo" == "$pattern"* ]]; then
      return 0
    fi
  done
  return 1
}

# Query Repology, convert to TSV format, then filter
curl -s -A "repology-shell-filter/0.1" "$API" |
  yq -p json -o tsv '.[] | [.repo, .visiblename // .srcname // "-", .version // "-", .status // "-"] | @tsv' |
  while IFS=$'\t' read -r repo pkgname version status; do
    if matches_repo "$repo"; then
      echo "$repo | $pkgname | $version | $status"
    fi
  done
