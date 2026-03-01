
# Persistence (persistence)

Persist userland data across dev containers by mounting host-side volumes.

## Example Usage

```json
"features": {
    "ghcr.io/<owner>/<repo>/persistence:1": {
        "claude": true,
        "codex": true,
        "gemini": false,
        "copilot-cli": true,
        "gh-cli": true
    }
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| claude | Mount Claude Code config (`~/.claude`) via volume. | boolean | false |
| codex | Mount Codex config (`~/.codex`) via volume. | boolean | false |
| gemini | Mount Gemini Code Assist config and cache directories via volumes. | boolean | false |
| copilot-cli | Mount GitHub Copilot CLI config (`~/.copilot`) via volume. | boolean | false |
| gh-cli | Mount GitHub CLI config (`~/.config/gh`) via volume. | boolean | false |

## Persistent bin

- Use `/usr/local/share/persistence/bin` as a persistent location for custom executables.
- On container start, files in that directory are symlinked into `~/.local/bin`.
- If `~/.local/bin/<name>` already exists as a regular file, it is kept as-is and not overwritten.
- Ensure `~/.local/bin` is in your PATH, for example: `export PATH="$HOME/.local/bin:$PATH"`.
- If you add files in the persistent bin later, restart the container to resync links.



---

_Note: Keep this README in sync with `devcontainer-feature.json`._
