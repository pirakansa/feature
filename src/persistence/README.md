
# Persistence (`persistence`)

A Dev Container Feature that provides a named Docker volume for CLI login-state backups.
Data is stored in the `persistence` volume and survives container recreation.

## How It Works

The feature mounts the volume at `/usr/local/share/persistence` and installs the `persistence-login` command. It does not alter Copilot CLI or GitHub CLI configuration files. For Codex, `restore` replaces `~/.codex/auth.json` with a symlink to the shared login-state file.

Use `save` after signing in to save login state. It keeps Codex authentication local, so it can be updated independently. Use `restore` after creating a new container to restore it; for Codex, this also shares subsequent token updates with every container restored from the same volume.

## Usage

```json
"features": {
  "ghcr.io/pirakansa/feature/persistence:1": {}
}
```

### Save Login State

```sh
persistence-login save codex
persistence-login save copilot-cli
persistence-login save gh-cli
```

### Restore Login State

```sh
persistence-login restore codex
persistence-login restore copilot-cli
persistence-login restore gh-cli
```

## Supported Tools

| Tool | Login-state file |
|------|------------------|
| Codex CLI | `~/.codex/auth.json` (linked to the volume by `restore`) |
| GitHub Copilot CLI | `~/.copilot/config.json` |
| GitHub CLI | `~/.config/gh/hosts.yml` |

## Volume Structure

```
/usr/local/share/persistence/   ← Docker volume mount point
  codex/
    auth.json                   ← Linked from ~/.codex/auth.json after restore
  copilot-cli/
    config.json                 ← Copied from ~/.copilot/config.json
  gh-cli/
    hosts.yml                   ← Copied from ~/.config/gh/hosts.yml
```

---

_Keep this file in sync with `devcontainer-feature.json`._
