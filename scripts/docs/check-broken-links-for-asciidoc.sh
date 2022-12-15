#!/usr/bin/env bash

set -o errtrace
set -o nounset
set -o pipefail

function find_asciidoc_files() {
	# All AsciiDoc files are targets.
	# Because they may be modified by include directives(`include::target`).
	# https://docs.asciidoctor.org/asciidoc/latest/directives/include/
	find . -type f -name '*.adoc' \
		-not -path "./.git/*" \
		-not -path "./node_modules/*" \
		-not -path "./.git-cliff/*" \
		-not -path "./.vale/*"
}

function lint_asciidoc() {
	# Don't use `--out-file=''`.
	# We don't know which file is causing the error.
	# shellcheck disable=SC2086
	# The `$1` is intentionally split.
	npm run --silent convert-asciidoc-to-html $1
}
function check_broken_links() {
	# shellcheck disable=SC2086
	# The `$1` is intentionally split.
	lychee --no-progress --cache --max-cache-age 1d $1
}

function remove_converted_html_from_asciidoc() {
	# shellcheck disable=SC2086
	# The `$1` is intentionally split.
	rm --force $1
}

asciidoc_files=$(find_asciidoc_files)
readonly asciidoc_files

lint_asciidoc "$asciidoc_files"

html_files="${asciidoc_files//.adoc/.html}"
readonly html_files

check_broken_links "$html_files"

result=$?

remove_converted_html_from_asciidoc "$html_files"

exit "$result"
