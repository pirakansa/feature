#!/bin/bash
set -e
source dev-container-features-test-lib
check "setup installed" test -x /usr/local/bin/persistence-setup
check "git installed" git --version
check "setup behavior" bash ./behavior.sh
reportResults
