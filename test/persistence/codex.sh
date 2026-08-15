#!/bin/bash

set -e

source dev-container-features-test-lib

check "codex symlink exists" bash -c "[ -L /root/.codex ]"
check "codex symlink target" bash -c "[ \"$(readlink /root/.codex)\" = \"/usr/local/share/persistence/codex\" ]"

reportResults
