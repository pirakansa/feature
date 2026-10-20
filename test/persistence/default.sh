#!/bin/bash
set -e
source dev-container-features-test-lib
check "runs as vscode" test "$(id -un)" = vscode
check "setup behavior as remote user" bash ./behavior.sh
check "local bin on shell PATH" bash -ic 'case ":$PATH:" in *":$HOME/.local/bin:"*) exit 0 ;; *) exit 1 ;; esac'
reportResults
