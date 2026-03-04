#!/bin/bash

set -e

source dev-container-features-test-lib

check "opencode config symlink exists" bash -c "[ -L /root/.config/opencode ]"
check "opencode config symlink target" bash -c "[ \"$(readlink /root/.config/opencode)\" = \"/usr/local/share/persistence/opencode-config\" ]"
check "opencode local-share symlink exists" bash -c "[ -L /root/.local/share/opencode ]"
check "opencode local-share symlink target" bash -c "[ \"$(readlink /root/.local/share/opencode)\" = \"/usr/local/share/persistence/opencode-local-share\" ]"

reportResults
