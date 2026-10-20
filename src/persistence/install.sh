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
    for dependency in bash:bash curl:curl git:git tar:tar gzip:gzip awk:mawk sha256sum:coreutils install:coreutils mktemp:coreutils; do
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

configure_shell_path() {
# Applies to interactive/login shells without embedding a user's home at build time.
cat > /etc/profile.d/persistence-path.sh <<'EOF'
case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) export PATH="$HOME/.local/bin:$PATH" ;;
esac
EOF
# Bash interactive non-login shells do not read /etc/profile.d.
if [ -f /etc/bash.bashrc ]; then
    printf '\n. /etc/profile.d/persistence-path.sh\n' >> /etc/bash.bashrc
fi
}

main() {
    require_root
    install_prerequisites
    install_setup_command
    configure_shell_path
}

main "$@"
