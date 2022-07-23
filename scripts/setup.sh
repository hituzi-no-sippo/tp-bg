#!/usr/bin/env bash

set -o errexit
set -o errtrace
set -o nounset
set -o pipefail

function info() {
	printf "\n%s\n" "${1}"
}

function install_tools_with_version_manager() {
	info "Lazy Install. Download the tool when the tool is executed."

	aqua install --only-link
}
function __setup_natural_language() {
	info "Setup natural language tools"

	function __setup_linter() {
		vale sync
	}

	__setup_linter
}

function setup() {
	info "Setup Start"

	install_tools_with_version_manager

	__setup_natural_language

	info "Setup Complete"
}

setup
