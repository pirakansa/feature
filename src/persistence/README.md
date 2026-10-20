# Persistence (`persistence`) v2

Installs selected CLI tools as the remote user during container creation and configures GitHub HTTPS access when
creating the container. Debian/Ubuntu-based images are supported.

```json
{
  "features": {
    "ghcr.io/pirakansa/feature/persistence:2": {
      "claude": true,
      "codex": true,
      "gh": true
    }
  }
}
```

All three tool options default to `false`. Existing commands are reused.
The Feature checks prerequisites (Bash, curl, Git, archive tools, coreutils,
and CA certificates) and installs missing packages with apt-get.

Root only installs missing prerequisites, setup scripts, option settings, and
command launchers during image build. `onCreateCommand` installs selected tools
as `remoteUser` into that user's home. Set a non-root `remoteUser` to keep official
installers unprivileged. Network access, proxy variables, and CA trust must be
available during container creation as well as image build.

Launchers in `/usr/local/bin` resolve binaries from the current user's
`~/.local/bin`, so non-interactive processes can use them without shell startup
files. Existing system installations are reused. Tool updates use the same user's
permissions. Other users need their own installations. GitHub CLI supports
x86_64 and arm64 and its download checksum is verified.
Claude Code uses its official installer. Codex uses:

```sh
curl -fsSL https://chatgpt.com/codex/install.sh | CODEX_NON_INTERACTIVE=1 sh
```

Authentication is performed separately after installation (`claude`, `codex login`,
`gh auth login`). The Feature does not copy, persist, or configure credentials.
Authentication normally remains across stop/start of the same container;
recreated containers need authentication again unless configured to retain it.

`onCreateCommand` runs `persistence-setup` as the remote user.
Git identity is managed by the user, for example through dotfiles or:

```sh
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

The Feature does not set or overwrite Git's `user.name` or `user.email`.

When `gh` is installed and usable (including when the `gh` Feature option is enabled), setup
also adds GitHub URL rewrites from `git@github.com:` and `ssh://git@github.com/`
to `https://github.com/` and runs `gh auth setup-git --hostname github.com --force`.
This configures the credential helper before login without making authentication
requests. Repository remote URLs are not modified. Other hosts are unaffected.
No SSH agent socket or SSH keys are required for these GitHub connections.

After creation, authenticate as the remote user:

```sh
gh auth login --hostname github.com --git-protocol https --web
```

Run `persistence-setup` again to reapply Git settings. Existing rewrite entries
are preserved and duplicate entries are not added.

## Migration from v1

v2 removes the shared volume mount and `persistence-login save/restore`.
Existing v1 volumes are not deleted. Recreate the container with `:2` and enable
the desired tools explicitly. Copilot setup is not included.
