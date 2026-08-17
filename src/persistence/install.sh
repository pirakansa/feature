#!/bin/sh
set -e

if [ "$(id -u)" -ne 0 ]; then
    echo "Script must be run as root."
    exit 1
fi

echo "Setting up persistence feature..."

PERSIST_ROOT="/usr/local/share/persistence"

install -d -m 777 "$PERSIST_ROOT"
install -m 755 persistence-login /usr/local/bin/persistence-login
