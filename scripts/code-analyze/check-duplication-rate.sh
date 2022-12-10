#!/usr/bin/env bash

set -o errexit
set -o errtrace
set -o nounset
set -o pipefail

function calc_duplication_rate() {
	# `--warnings_only` flag
	# Hide the result of the code complexity analysis
	lizard \
		-Eduplicate \
		--warnings_only \
		--exclude "./.git/*" \
		--exclude "./node_modules/*" \
		--exclude "./.git-cliff/*" \
		--exclude "./.vale/*" \
		--exclude "./docs/*"
}

calc_duplication_rate
