## AI-generated artifact locations

- For agent-plugin artifacts, use the plugin's dedicated subdirectory under `docs/` when it has one; keep its contents there (for example, `docs/superpowers/`).
- If the plugin instead stores artifacts in a repository-root directory, move/use `.agents/<plugin-id>/` (for example, move `paad/` to `.agents/paad/`).
- For other AI-generated artifacts, use `.agents/<artifact-type>/`, such as `.agents/logs/` for AI work logs or `.agents/research/` for research.
