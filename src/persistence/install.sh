#!/bin/sh
set -e

if [ "$(id -u)" -ne 0 ]; then
    echo "Script must be run as root."
    exit 1
fi

echo "Setting up persistence feature..."

PERSIST_ROOT="/usr/local/share/persistence"
TARGET_HOME="${_REMOTE_USER_HOME:-${_CONTAINER_USER_HOME:-}}"

if [ -z "$TARGET_HOME" ]; then
    TARGET_HOME="/root"
fi

is_enabled() {
    case "$(echo "$1" | tr '[:upper:]' '[:lower:]')" in
        1|true|yes|on)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

initialize_persistence_layout() {
    install -d -m 777 "$PERSIST_ROOT"
    target_uid="$(stat -c '%u' "$TARGET_HOME")"
    target_gid="$(stat -c '%g' "$TARGET_HOME")"

    for persist_dir_name in \
        "claude" \
        "codex" \
        "gemini" \
        "google-vscode-extension" \
        "cloud-code" \
        "copilot-cli" \
        "gh-cli" \
        "opencode-config" \
        "opencode-local-share"
    do
        install -d -m 777 "$PERSIST_ROOT/$persist_dir_name"
        chmod -R 777 "$PERSIST_ROOT/$persist_dir_name"
        chown -R "$target_uid:$target_gid" "$PERSIST_ROOT/$persist_dir_name"
    done
}

link_persistence() {
    persist_name="$1"
    relative_target="$2"

    persist_dir="$PERSIST_ROOT/$persist_name"
    target_path="$TARGET_HOME/$relative_target"
    target_parent="$(dirname "$target_path")"

    install -d -m 777 "$persist_dir"
    install -d -m 777 "$target_parent"

    if [ -e "$target_path" ] || [ -L "$target_path" ]; then
        echo "Skipping existing path: $target_path"
        return 0
    fi

    ln -s "$persist_dir" "$target_path"
}

initialize_persistence_layout

if is_enabled "${CLAUDE:-false}"; then
    link_persistence "claude" ".claude"
fi

if is_enabled "${CODEX:-false}"; then
    link_persistence "codex" ".codex"
fi

if is_enabled "${GEMINI:-false}"; then
    link_persistence "gemini" ".gemini"
    link_persistence "google-vscode-extension" ".cache/google-vscode-extension"
    link_persistence "cloud-code" ".cache/cloud-code"
fi

if is_enabled "${COPILOT_CLI:-false}"; then
    link_persistence "copilot-cli" ".copilot"
fi

if is_enabled "${GH_CLI:-false}"; then
    link_persistence "gh-cli" ".config/gh"
fi

if is_enabled "${OPENCODE:-false}"; then
    link_persistence "opencode-config" ".config/opencode"
    link_persistence "opencode-local-share" ".local/share/opencode"
fi
