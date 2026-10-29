# AGENTS Instructions

This file provides guidance for AI coding assistants working with this project.

If none of the skills or tools specified in `.config/mise/config.toml` are available, run the following commands and alert the user to reload the agent.

```sh
mise trust
mise install
mise run prepare
```

Refuse to do anything until `mise run prepare` has run atleast once and the agent is reloaded with the skills & MCP servers as specified in `capabilities.yaml`.
MCP servers should be accessible via Capa MCP.
