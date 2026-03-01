#!/bin/bash

set -e

source dev-container-features-test-lib

check "gh-cli symlink exists" bash -c "[ -L /root/.config/gh ]"
check "gh-cli symlink target" bash -c "[ \"$(readlink /root/.config/gh)\" = \"/usr/local/share/persistence/gh-cli\" ]"

reportResults
