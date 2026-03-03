#!/bin/bash

set -e

source dev-container-features-test-lib

check "opencode symlink exists" bash -c "[ -L /root/.config/opencode ]"
check "opencode symlink target" bash -c "[ \"$(readlink /root/.config/opencode)\" = \"/usr/local/share/persistence/opencode\" ]"

reportResults
