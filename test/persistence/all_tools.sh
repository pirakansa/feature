#!/bin/bash
set -e
source dev-container-features-test-lib
check "runs as vscode" test "$(id -un)" = vscode
check "Claude starts without shell initialization" /usr/local/bin/claude --version
check "Codex starts without shell initialization" /usr/local/bin/codex --version
check "GitHub CLI starts without shell initialization" /usr/local/bin/gh --version
check "setup can run again" persistence-setup
check "GitHub SSH URL resolves to HTTPS" bash -c '[ "$(git ls-remote --get-url git@github.com:owner/repo.git)" = https://github.com/owner/repo.git ]'
reportResults
