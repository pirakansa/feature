#!/bin/bash

# Auto-generated test: Verifies the manual login-state persistence command is installed.
#
# How to run:
#   devcontainer features test \
#     --features persistence \
#     --skip-scenarios \
#     --base-image mcr.microsoft.com/devcontainers/base:ubuntu \
#     /path/to/this/repo
#
# Reference: https://github.com/devcontainers/cli/blob/main/docs/features/test.md

set -e

# Optional: Import test library bundled with the devcontainer CLI
# See https://github.com/devcontainers/cli/blob/HEAD/docs/features/test.md#dev-container-features-test-lib
# Provides the 'check' and 'reportResults' commands.
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib. Syntax is...
# check <LABEL> <cmd> [args...]
check "persistence root exists" bash -c "[ -d /usr/local/share/persistence ]"
check "persistence-login is installed" bash -c "[ -x /usr/local/bin/persistence-login ]"

# Report results
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
