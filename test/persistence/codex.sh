#!/bin/bash

set -e

source dev-container-features-test-lib

check "root local bin exists" bash -c "[ -d /root/.local/bin ]"
check "root local bin owner" bash -c "[ \"$(stat -c '%U:%G' /root/.local/bin)\" = \"root:root\" ]"
check "root bin directory is not linked as entry" bash -c "[ ! -e /root/.local/bin/bin ] && [ ! -L /root/.local/bin/bin ]"
check "root persistent bin entries are linked" bash -c "for src_path in /usr/local/share/persistence/bin/*; do [ -e \"$src_path\" ] || [ -L \"$src_path\" ] || continue; [ -d \"$src_path\" ] && continue; bin_name=\"$(basename \"$src_path\")\"; dest_path=\"/root/.local/bin/$bin_name\"; [ -L \"$dest_path\" ] && [ \"$(readlink \"$dest_path\")\" = \"$src_path\" ] || exit 1; done"
check "codex symlink exists" bash -c "[ -L /root/.codex ]"
check "codex symlink target" bash -c "[ \"$(readlink /root/.codex)\" = \"/usr/local/share/persistence/codex\" ]"

reportResults
