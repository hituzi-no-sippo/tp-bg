#!/usr/bin/env bash

set -o errtrace
set -o nounset
set -o pipefail

commit_editmsg_file="$1"
readonly commit_editmsg_file
# Set extension to md, to format with dprint.
TEMP_FILE="COMMIT_EDITMSG.md"
readonly TEMP_FILE

function extract_commit_msg_to_temp_file() {
	local -r script_directory="$(dirname "$0")"

	local -r message="$(bash "$script_directory/extract-commit-msg.sh" "$commit_editmsg_file")"

	if [[ -z $message ]]; then
		exit 1
	fi

	echo "$message" >"$TEMP_FILE"
}

PATTERN="^\(=\|-\)\+"
ADDITIONAL_WORD="MD003/heading-style/header-style"
readonly PATTERN
readonly ADDITIONAL_WORD

# Avoid MD003
# https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md#md003---heading-style
# Because MD003 in dprit can't be disabled.
# MD003 in markdownlinter is disabled.
function replace_lines_with_only_symbols_to_avoid_MD003() {
	sed --in-place "s#${PATTERN}\$#\0${ADDITIONAL_WORD}#g" "$TEMP_FILE"
}
function restore_lines_with_only_symbols() {
	sed --in-place "s#\(${PATTERN}\)${ADDITIONAL_WORD}#\1#g" "$TEMP_FILE"
}

function clean_up_files() {
	restore_lines_with_only_symbols

	mv "$TEMP_FILE" "$commit_editmsg_file"
}

function format() {
	function run_dprint() {
		dprint fmt "$TEMP_FILE"
	}

	run_dprint
}

extract_commit_msg_to_temp_file

replace_lines_with_only_symbols_to_avoid_MD003

format

result="$?"

clean_up_files

exit "$result"
