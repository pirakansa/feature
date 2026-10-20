#!/bin/bash

tool_available() (
    local executable
    executable=$(command -v "$1") || return 1
    if [[ "$(readlink "$executable" || :)" == "/usr/local/lib/persistence/shims/$1" ]]; then
        [[ -x "$HOME/.local/bin/$1" ]]
    else
        return 0
    fi
)

