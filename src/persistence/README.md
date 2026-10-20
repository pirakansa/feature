# Persistence (`persistence`) v2

Sets up CLI tools and Git identity from environment variables when a container is created.
Supports Debian/Ubuntu-based images. GitHub CLI downloads support x86_64 and arm64.

## Usage

Set the desired `HOST_*` variables in the environment used to start Dev Containers,
then add the Feature and explicit forwarding to `devcontainer.json`:

```json
{
  "features": {
    "ghcr.io/pirakansa/feature/persistence:2": {}
  },
  "remoteEnv": {
    "PATH": "${containerEnv:PATH}:${containerEnv:HOME}/.local/bin",
    "CLAUDE_CODE_OAUTH_TOKEN": "${localEnv:HOST_CLAUDE_CODE_OAUTH_TOKEN}",
    "GH_TOKEN": "${localEnv:HOST_GH_TOKEN}",
    "GIT_USER_NAME": "${localEnv:HOST_GIT_USER_NAME}",
    "GIT_USER_EMAIL": "${localEnv:HOST_GIT_USER_EMAIL}"
  }
}
```

For PATH, replace `${containerEnv:HOME}` with the remote user's actual home directory
if it differs from the container user's home. The Feature also adds `~/.local/bin`
to PATH for Bash interactive and login shells. `remoteEnv` applies to Dev Container
processes such as terminals and lifecycle commands; use your container runtime's
environment configuration when other processes also need the variables.

| Container variable | Action when nonempty |
| --- | --- |
| `CLAUDE_CODE_OAUTH_TOKEN` | Install Claude Code using its official installer if missing |
| `GH_TOKEN` | Install GitHub CLI from its official release if missing |
| `GIT_USER_NAME` | Set `git config --global user.name` |
| `GIT_USER_EMAIL` | Set `git config --global user.email` |

Generate the Claude token on the host with `claude setup-token`. GitHub CLI uses
`GH_TOKEN` directly; no `gh auth login` or credential-file backup is needed.
Tokens remain in the environment and are not written to configuration by this Feature.
CLI authentication is used at runtime; setup does not validate tokens or make paid requests.

The Feature checks for Bash, curl, Git, tar, gzip, awk, coreutils commands, and
a CA certificate bundle during image build. It uses apt-get to install only missing
prerequisites; when all are present, it skips package installation. Its `onCreateCommand` runs
`persistence-setup` as the remote user, installing tools into that user's home.
Empty or missing variables are skipped, and existing CLI installations are reused.
Git identity values are applied whenever setup runs; repository-local settings still take precedence.
Download or installation failures fail setup. Network access is required for missing tools.

After adding variables to an existing container, forward them into its environment
and run `persistence-setup`, or recreate the container. It can safely be run again.

## Migration from v1

v2 removes the shared `persistence` volume mount and `persistence-login save/restore`.
It currently supports Claude Code, GitHub CLI, and Git identity; Codex and Copilot
setup are not included. Existing v1 volumes are not deleted. Switch to `:2` and
configure the variables above. Recreate the container to remove the old mount.
