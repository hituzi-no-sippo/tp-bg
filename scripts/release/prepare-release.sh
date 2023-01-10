#!/usr/bin/env bash

set -o errexit
set -o errtrace
set -o nounset
set -o pipefail

script_directory=$(dirname "$0")
readonly script_directory

version=$(cog bump --dry-run --auto)
readonly version

bash "$script_directory/generate-CHANGELOG.sh" "$version"

git add --all

# Skip hook of pre-commit
# https://pre-commit.com/#temporarily-disabling-hooks
# https://github.com/pre-commit/pre-commit-hooks#no-commit-to-branch
SKIP=no-commit-to-branch \
	git commit --message "chore(release): prepare for $version"

git tag "$version" --message "$version"
