#!/usr/bin/env sh
# Sort all arrays in YAML files in the packages directory

set -e

PACKAGES_DIR=".chezmoidata/packages"

echo "Sorting YAML arrays in ${PACKAGES_DIR}..."
echo ""

# Find all .yaml and .yml files in packages directory (including subdirectories)
find "${PACKAGES_DIR}" -type f \( -name "*.yml" -o -name "*.yaml" \) | while read -r file; do
  echo "Sorting: ${file}"
  yq eval -i '(.. | select(tag == "!!seq")) |= (sort_by(. | downcase))' "${file}"
done

echo ""
echo "✓ All YAML files sorted successfully!"
