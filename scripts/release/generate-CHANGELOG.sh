#!/usr/bin/env bash

set -o errexit
set -o errtrace
set -o pipefail

if [[ $1 ]]; then
	export GIT_CLIFF_TAG=$1
fi

git-cliff --output CHANGELOG.md
