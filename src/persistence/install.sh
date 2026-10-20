#!/bin/sh
set -eu

require_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "Script must be run as root." >&2
        exit 1
    fi
}

# A subshell keeps the package list and temporary variables inside this function.
install_prerequisites() (
    # Resolve prerequisites before setup runs as the unprivileged remote user.
    set --
    for dependency in bash:bash curl:curl git:git tar:tar gzip:gzip awk:mawk sha256sum:coreutils readlink:coreutils install:coreutils mktemp:coreutils; do
        executable=${dependency%%:*}
        package=${dependency#*:}
        if ! command -v "$executable" >/dev/null 2>&1; then
            echo "Missing prerequisite: $executable (package: $package)"
            case " $* " in
                *" $package "*) ;;
                *) set -- "$@" "$package" ;;
            esac
        fi
    done
    if [ ! -s /etc/ssl/certs/ca-certificates.crt ]; then
        echo "Missing prerequisite: CA certificate bundle"
        set -- "$@" ca-certificates
    fi

    if [ "$#" -gt 0 ]; then
        if ! command -v apt-get >/dev/null 2>&1; then
            echo "Cannot install missing prerequisites: $*. Automatic installation requires apt-get." >&2
            exit 1
        fi
        apt-get update
        DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "$@"
    else
        echo "All persistence prerequisites are already available."
    fi
)

install_setup_command() {
    install -m 755 persistence-setup /usr/local/bin/persistence-setup
}

save_options() (
    install -d -m 755 /usr/local/share/persistence
    for option in CLAUDE CODEX GH; do
        eval 'value=${'"$option"':-false}'
        case "$value" in true|false) ;; *) echo "Invalid option: $option" >&2; exit 1 ;; esac
        printf '%s=%s\n' "$option" "$value"
    done > /usr/local/share/persistence/options.env
    chmod 644 /usr/local/share/persistence/options.env
)

install_user_launchers() (
    install -d -m 755 /usr/local/lib/persistence/shims
    for tool in claude codex gh; do
        # Keep existing system installations. Launchers resolve HOME at runtime,
        # including for docker exec / Orca processes without shell initialization.
        case "$tool" in
            claude) enabled=${CLAUDE:-false} ;;
            codex) enabled=${CODEX:-false} ;;
            gh) enabled=${GH:-false} ;;
        esac
        if [ "$enabled" != true ]; then
            continue
        fi
        if command -v "$tool" >/dev/null 2>&1; then
            continue
        fi
        cat > "/usr/local/lib/persistence/shims/$tool" <<'EOF'
#!/bin/sh
exec "$HOME/.local/bin/${0##*/}" "$@"
EOF
        chmod 755 "/usr/local/lib/persistence/shims/$tool"
        ln -s "/usr/local/lib/persistence/shims/$tool" "/usr/local/bin/$tool"
    done
)

main() {
    require_root
    install_prerequisites
    install_setup_command
    install -m 755 persistence-install-tools /usr/local/bin/persistence-install-tools
    install -d -m 755 /usr/local/lib/persistence
    install -m 644 persistence-common.sh /usr/local/lib/persistence/common.sh
    save_options
    install_user_launchers
}

main "$@"
