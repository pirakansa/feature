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
# Control gh availability independently of the host installation.
command() {
    if [[ "$#" == 2 && "$1" == -v && "$2" == gh && "${TEST_GH_AVAILABLE:-false}" != true ]]; then
        return 1
    fi
    builtin command "$@"
}
export -f command
# Stage the setup entry point without installing into the host filesystem.
source_dir=$(dirname "$setup")
if [[ -f "$source_dir/persistence-common.sh" ]]; then
    common="$source_dir/persistence-common.sh"
else
    common=/usr/local/lib/persistence/common.sh
fi
sed -e "s|/usr/local/lib/persistence/common.sh|$common|" \
    -e '\|^    /usr/local/bin/persistence-install-tools$|d' "$setup" > "$tmp/setup"
setup="$tmp/setup"
bash "$setup"
[[ ! -e "$HOME/downloads" && ! -e "$HOME/.gitconfig" ]]
# Identity environment variables are ignored; user-managed settings are preserved.
git config --global user.name 'Existing User'
git config --global user.email 'existing@example.com'
export GIT_USER_NAME='Ignored User' GIT_USER_EMAIL='ignored@example.com'
bash "$setup"
[[ "$(git config --global user.name)" == 'Existing User' ]]
[[ "$(git config --global user.email)" == existing@example.com ]]

cat > "$tmp/bin/gh" <<'EOF'
#!/bin/bash
set -eu
[[ "$*" == 'auth setup-git --hostname github.com --force' ]]
printf '%s\n' "$*" >> "$HOME/gh-calls"
git config --global --replace-all credential.https://github.com.helper '!gh auth git-credential'
EOF
chmod +x "$tmp/bin/gh"
export TEST_GH_AVAILABLE=true
git config --global --add url.https://github.com/.insteadOf 'git://github.com/'
bash "$setup"
bash "$setup"
[[ "$(git ls-remote --get-url git@github.com:owner/repo.git)" == https://github.com/owner/repo.git ]]
[[ "$(git ls-remote --get-url ssh://git@github.com/owner/repo.git)" == https://github.com/owner/repo.git ]]
[[ "$(git ls-remote --get-url https://github.com/owner/repo.git)" == https://github.com/owner/repo.git ]]
[[ "$(git ls-remote --get-url git@example.com:owner/repo.git)" == git@example.com:owner/repo.git ]]
[[ "$(git config --global --get-all url.https://github.com/.insteadOf | wc -l)" == 3 ]]
[[ "$(wc -l < "$HOME/gh-calls")" == 2 ]]
echo 'GitHub URL rewrite and helper setup tests passed.'
