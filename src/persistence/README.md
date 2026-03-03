
# Persistence (`persistence`)

A Dev Container Feature that persists AI tool configurations, credentials, and custom executables across container rebuilds.
Data is stored in a named Docker volume (`persistence`) and survives container recreation.

## How It Works

1. **At install time**: Creates `/usr/local/share/persistence/<name>` directories and symlinks them to the corresponding paths in the home directory.
2. **At container start** (`postStartCommand`): Symlinks executables found in `/usr/local/share/persistence/bin/` into `~/.local/bin/`. Existing files are not overwritten.

If a target path already exists (for example `~/.codex` or `~/.config/gh`), this feature skips creating that symlink and leaves the existing path unchanged.

## Usage

```json
"features": {
    "ghcr.io/<owner>/<repo>/persistence:1": {
        "claude": true,
        "codex": true,
        "gh-cli": true,
        "opencode": true
    }
}
```

## Options

| Option | Description | Type | Default |
|--------|-------------|------|---------|
| `claude` | Persist Claude Code configuration (`~/.claude`) in the volume | boolean | false |
| `codex` | Persist OpenAI Codex CLI configuration (`~/.codex`) in the volume | boolean | false |
| `gemini` | Persist Gemini Code Assist configuration (`~/.gemini`) and cache (`~/.cache/google-vscode-extension`, `~/.cache/cloud-code`) in the volume | boolean | false |
| `copilot-cli` | Persist GitHub Copilot CLI configuration (`~/.copilot`) in the volume | boolean | false |
| `gh-cli` | Persist GitHub CLI credentials (`~/.config/gh`) in the volume | boolean | false |
| `opencode` | Persist Opencode configuration (`~/.config/opencode`) in the volume | boolean | false |

## Volume Structure

```
/usr/local/share/persistence/   ← Docker volume mount point
  bin/                          ← Place custom executables to persist here
  claude/                       ← Linked to ~/.claude
  codex/                        ← Linked to ~/.codex
  gemini/                       ← Linked to ~/.gemini
  google-vscode-extension/      ← Linked to ~/.cache/google-vscode-extension
  cloud-code/                   ← Linked to ~/.cache/cloud-code
  copilot-cli/                  ← Linked to ~/.copilot
  gh-cli/                       ← Linked to ~/.config/gh
  opencode/                     ← Linked to ~/.config/opencode
```

## Persistent bin (`persistence/bin`)

Files placed in `/usr/local/share/persistence/bin/` are automatically symlinked into `~/.local/bin/` at container start.

- Existing files at `~/.local/bin/<name>` will not be overwritten.
- Ensure `~/.local/bin` is included in your PATH:
  ```sh
  export PATH="$HOME/.local/bin:$PATH"
  ```
- If you add files after the container has started, restart the container to re-sync the links.

---

_Keep this file in sync with `devcontainer-feature.json`._
