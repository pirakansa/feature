#!/bin/bash
set -e
source dev-container-features-test-lib
check "runs as vscode" test "$(id -un)" = vscode
check "setup behavior as remote user" bash ./behavior.sh
reportResults
