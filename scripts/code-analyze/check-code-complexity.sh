#!/usr/bin/env bash

set -o errexit
set -o errtrace
set -o nounset
set -o pipefail

lizard \
	--Threshold nloc=40 \
	--Threshold length=80 \
	--Threshold cyclomatic_complexity=10 \
	--Threshold parameter_count=5 \
	--Threshold token_count=100 \
	-ENS --Threshold max_nested_structures=3 \
	--warnings_only \
	"$@"
