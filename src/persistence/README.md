
# Persistence (`persistence`)

A Dev Container Feature that persists AI tool configurations and credentials across container rebuilds.
Data is stored in a named Docker volume (`persistence`) and survives container recreation.

## How It Works

At install time, the feature creates `/usr/local/share/persistence/<name>` directories and symlinks them to the corresponding paths in the home directory.

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
| `opencode` | Persist Opencode configuration (`~/.config/opencode`) and data (`~/.local/share/opencode`) in separate volume paths | boolean | false |

## Volume Structure

```
/usr/local/share/persistence/   ← Docker volume mount point
  claude/                       ← Linked to ~/.claude
  codex/                        ← Linked to ~/.codex
  gemini/                       ← Linked to ~/.gemini
  google-vscode-extension/      ← Linked to ~/.cache/google-vscode-extension
  cloud-code/                   ← Linked to ~/.cache/cloud-code
  copilot-cli/                  ← Linked to ~/.copilot
  gh-cli/                       ← Linked to ~/.config/gh
  opencode-config/              ← Linked to ~/.config/opencode
  opencode-local-share/         ← Linked to ~/.local/share/opencode
```

---

_Keep this file in sync with `devcontainer-feature.json`._
