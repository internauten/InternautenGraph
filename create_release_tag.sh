#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

MODULE_FILE="internautengraph/internautengraph.php"

if [[ ! -f "${MODULE_FILE}" ]]; then
  echo "Error: ${MODULE_FILE} not found."
  exit 1
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Error: this script must be run inside a git repository."
  exit 1
fi

VERSION="$(awk -F"'" '/\$this->version[[:space:]]*=/{print $2; exit}' "${MODULE_FILE}")"

if [[ -z "${VERSION}" ]]; then
  echo "Error: could not extract module version from ${MODULE_FILE}."
  exit 1
fi

TAG="v${VERSION}"

if git rev-parse -q --verify "refs/tags/${TAG}" >/dev/null 2>&1; then
  echo "Tag ${TAG} already exists locally."
  exit 1
fi

if git ls-remote --exit-code --tags origin "refs/tags/${TAG}" >/dev/null 2>&1; then
  echo "Tag ${TAG} already exists on origin."
  exit 1
fi

git tag -a "${TAG}" -m "Release ${TAG}"
git push origin "${TAG}"

echo "Created and pushed tag: ${TAG}"