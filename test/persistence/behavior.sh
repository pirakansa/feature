#!/bin/bash
set -euo pipefail
setup=${1:-/usr/local/bin/persistence-setup}
setup=$(realpath "$setup")
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
export HOME="$tmp/home"
mkdir -p "$HOME" "$tmp/bin"
export PATH="$tmp/bin:$PATH"
unset CLAUDE_CODE_OAUTH_TOKEN GH_TOKEN GIT_USER_NAME GIT_USER_EMAIL
export GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL="$HOME/.gitconfig"
# All downloads are mocked. No real tokens or network access are used.
cat > "$tmp/bin/curl" <<'EOF'
#!/bin/bash
printf 'curl\n' >> "$HOME/downloads"
if [[ "${MOCK_CURL_FAIL:-}" == 1 ]]; then exit 22; fi
if [[ "$*" == *claude.ai/install.sh* ]]; then
    echo 'mkdir -p "$HOME/.local/bin"; printf "#!/bin/sh\\nexit 0\\n" > "$HOME/.local/bin/claude"; chmod +x "$HOME/.local/bin/claude"'
elif [[ "$*" == *releases/latest* ]]; then
    printf 'https://github.com/cli/cli/releases/tag/v1.2.3'
else
    while [[ "$1" != -o ]]; do shift; done
    case "$2" in
        */checksums.txt) cp "$HOME/fixture-checksums" "$2" ;;
        *) cp "$HOME/fixture.tar.gz" "$2" ;;
    esac
fi
EOF
chmod +x "$tmp/bin/curl"
# Ignore preinstalled host CLIs while exercising the local install branches.
command() {
    if [[ "$#" == 2 && "$1" == -v && ( "$2" == claude || "$2" == gh ) ]]; then
        [[ -x "$HOME/.local/bin/$2" ]] || return 1
        printf '%s\n' "$HOME/.local/bin/$2"
    else
        builtin command "$@"
    fi
}
export -f command
bash "$setup"
[[ ! -e "$HOME/downloads" && ! -e "$HOME/.gitconfig" ]]
export GIT_USER_NAME='Test User' GIT_USER_EMAIL='test@example.com'
bash "$setup"
[[ "$(git config --global user.name)" == 'Test User' ]]
[[ "$(git config --global user.email)" == test@example.com ]]
unset GIT_USER_NAME GIT_USER_EMAIL
bash "$setup"
[[ "$(git config --global user.name)" == 'Test User' ]]
export CLAUDE_CODE_OAUTH_TOKEN=dummy MOCK_CURL_FAIL=1
if bash "$setup"; then echo 'Download failure was ignored' >&2; exit 1; fi
unset MOCK_CURL_FAIL
bash "$setup"
[[ -x "$HOME/.local/bin/claude" ]]
before=$(wc -l < "$HOME/downloads")
bash "$setup"
[[ "$(wc -l < "$HOME/downloads")" == "$before" ]]
case "$(uname -m)" in x86_64) arch=amd64 ;; aarch64|arm64) arch=arm64 ;; *) exit 1 ;; esac
mkdir -p "$tmp/fixture/gh_1.2.3_linux_$arch/bin"
printf '#!/bin/sh\nexit 0\n' > "$tmp/fixture/gh_1.2.3_linux_$arch/bin/gh"
tar -czf "$HOME/fixture.tar.gz" -C "$tmp/fixture" "gh_1.2.3_linux_$arch"
printf '%s  gh_1.2.3_linux_%s.tar.gz\n' "$(sha256sum "$HOME/fixture.tar.gz" | cut -d ' ' -f 1)" "$arch" > "$HOME/fixture-checksums"
export GH_TOKEN=dummy
bash "$setup"
[[ -x "$HOME/.local/bin/gh" ]]
before=$(wc -l < "$HOME/downloads")
bash "$setup"
[[ "$(wc -l < "$HOME/downloads")" == "$before" ]]
# A checksum mismatch must not install a binary.
rm "$HOME/.local/bin/gh"
printf '%064d  gh_1.2.3_linux_%s.tar.gz\n' 0 "$arch" > "$HOME/fixture-checksums"
if bash "$setup"; then echo 'Checksum failure was ignored' >&2; exit 1; fi
[[ ! -e "$HOME/.local/bin/gh" ]]
echo 'Behavior tests passed.' 
