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
	npm run convert-asciidoc-to-html -- \
		$1 \
		--failure-level=WARNING \
		--attribute attribute-missing=warn@ \
		--verbose
}

function remove_converted_html_from_asciidoc() {
	html_files="${1//.adoc/.html}"

	# shellcheck disable=SC2086
	# The `$html_files1` is intentionally split.
	rm --force $html_files
}

asciidoc_files=$(find_asciidoc_files)
readonly asciidoc_files

lint_asciidoc "$asciidoc_files"

result=$?

remove_converted_html_from_asciidoc "$asciidoc_files"

exit "$result"
