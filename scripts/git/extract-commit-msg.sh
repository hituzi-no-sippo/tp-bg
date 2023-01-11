#!/usr/bin/env bash

set -o errexit
set -o errtrace
set -o nounset
set -o pipefail

if ! [[ -r $1 ]]; then
	echo "Can't read ""$1: No such file" >&2

	exit 1
fi

sed -z "s/\n\+#.*/\n/g" "$1"
