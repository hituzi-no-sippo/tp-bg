#!/usr/bin/env bash

set -o errexit
set -o errtrace
set -o nounset
set -o pipefail

function extract_commit_msg_from_file() {
	local -r script_directory="$(dirname "$0")"

	local -r message="$(bash "$script_directory/extract-commit-msg.sh" "$1")"

	if [[ -z $message ]]; then
		exit 1
	fi

	echo "$message"
}

extract_commit_msg_from_file "$1" |
	lychee --no-progress --cache --max-cache-age=1d -
