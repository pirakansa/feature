#!/bin/bash

# This test file will be executed against an auto-generated devcontainer.json that
# includes the 'hello' Feature with no options.
#
# For more information, see: https://github.com/devcontainers/cli/blob/main/docs/features/test.md
#
# Eg:
# {
#    "image": "<..some-base-image...>",
#    "features": {
#      "hello": {}
#    },
#    "remoteUser": "root"
# }
#
# Thus, the value of all options will fall back to the default value in 
# the Feature's 'devcontainer-feature.json'.
# For the 'hello' feature, that means the default favorite greeting is 'hey'.
#
# These scripts are run as 'root' by default. Although that can be changed
# with the '--remote-user' flag.
# 
# This test can be run with the following command:
#
#    devcontainer features test \ 
#                   --features hello   \
#                   --remote-user root \
#                   --skip-scenarios   \
#                   --base-image mcr.microsoft.com/devcontainers/base:ubuntu \
#                   /path/to/this/repo

set -e

# Optional: Import test library bundled with the devcontainer CLI
# See https://github.com/devcontainers/cli/blob/HEAD/docs/features/test.md#dev-container-features-test-lib
# Provides the 'check' and 'reportResults' commands.
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib. Syntax is...
# check <LABEL> <cmd> [args...]
check "persistence root exists" bash -c "[ -d /usr/local/share/persistence ]"
check "persistence bin exists" bash -c "[ -d /usr/local/share/persistence/bin ]"
check "persistence claude exists" bash -c "[ -d /usr/local/share/persistence/claude ]"
check "persistence codex exists" bash -c "[ -d /usr/local/share/persistence/codex ]"
check "persistence gemini exists" bash -c "[ -d /usr/local/share/persistence/gemini ]"
check "persistence google-vscode-extension exists" bash -c "[ -d /usr/local/share/persistence/google-vscode-extension ]"
check "persistence cloud-code exists" bash -c "[ -d /usr/local/share/persistence/cloud-code ]"
check "persistence copilot-cli exists" bash -c "[ -d /usr/local/share/persistence/copilot-cli ]"
check "persistence gh-cli exists" bash -c "[ -d /usr/local/share/persistence/gh-cli ]"
check "user local bin exists" bash -c "[ -d \"$HOME/.local/bin\" ]"
check "user local bin owner" bash -c 'owner="$(stat -c "%U:%G" "$HOME/.local/bin")"; [ "$owner" = "$(id -un):$(id -gn)" ]'

# Report results
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
