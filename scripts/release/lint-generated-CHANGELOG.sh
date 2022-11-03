#!/usr/bin/env bash

set -o errexit
set -o errtrace
set -o nounset
set -o pipefail

BACKUP_CHANGELOG=CHANGELOG.md~
readonly BACKUP_CHANGELOG

function make_CHANGEOLG_backup() {
	mv CHANGELOG.md "$BACKUP_CHANGELOG"
}
function restore_CHANGEOLG() {
	mv "$BACKUP_CHANGELOG" CHANGELOG.md
}
function remove_generated_CHANGELOG() {
	rm CHANGELOG.md
}

function generate_CHANGEROG() {
	local -r script_directory="$(dirname "$0")"

	bash "$script_directory/generate-CHANGELOG.sh"
}

function format() {
	dprint check CHANGELOG.md
}
function lint() {
	npm run lint:md -- \
		--disable line-length -- \
		CHANGELOG.md
}

exits_backup=false

if [[ -f CHANGELOG.md ]]; then
	make_CHANGEOLG_backup

	exits_backup=true
fi

readonly exits_backup

set +o errexit

generate_CHANGEROG && format && lint

result="$?"

if "$exits_backup"; then
	restore_CHANGEOLG
else
	remove_generated_CHANGELOG
fi

exit "$result"
