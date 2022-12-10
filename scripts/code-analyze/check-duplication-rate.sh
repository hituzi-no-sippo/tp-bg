#!/usr/bin/env bash

set -o errexit
set -o errtrace
set -o nounset
set -o pipefail

declare -A limit_rate

function parse_options() {
	set +o nounset

	while (($# > 0)); do
		case $1 in
		--duplicate)
			limit_rate[duplicate]=$2
			;;
		--unique)
			limit_rate[unique]=$2
			;;
		esac
		shift
	done

	if [[ -z ${limit_rate[duplicate]} || -z ${limit_rate[unique]} ]]; then
		echo >&2 "'duplicate' and 'unique' options are required." \
			"For example '--duplicate 0 --unique 100'."

		exit 1
	fi

	set -o nounset
}

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
function extract_rate() {
	grep --only-matching --perl-regexp \
		"^Total $1 rate: \K([\d.]+)"
}

function check_rate() {
	for kind in 'duplicate' 'unique'; do
		local rate
		local limit
		local expr
		rate=$(echo "$1" | extract_rate "$kind")
		limit="${limit_rate[$kind]}"
		expr=$(
			printf "$rate %s $limit %s" \
				"$([[ $kind == 'duplicate' ]] && echo '>' || echo '<')" \
				"$([[ $kind == 'unique' ]] && echo "&& $rate != 0")"
		)

		if [[ $(echo "$expr" | bc) == 1 ]]; then
			printf "The $kind rate is %s $limit%%. The rate is $rate%%.\n" \
				"$([[ $kind == 'duplicate' ]] && echo 'over' || echo 'under')"

			exit 1
		fi
	done
}

parse_options "$@"

result=$(calc_duplication_rate)
echo "$result"

check_rate "$result"
