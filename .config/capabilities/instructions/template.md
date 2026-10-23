## Generated project context

### Project Context

Read `README.md`, dependency manifests, and relevant source files to learn the
project's purpose, architecture, and commands. The application language and
framework depend on the generated project.

- **Project Type**: Project scaffolded from [copier-mr-mise](https://github.com/MRDGH2821/copier-mr-mise)
- **Key Technologies**: mise, hk, MegaLinter, cspell, capa
- **Purpose**: Standardized starting point with tool management, git hooks, and quality checks
- **Template updates**: `copier update` (review scripts in the template's `copier.yml`)

### Recommendations

#### Configuration directory

If this project is a tool, CLI, or library that reads its own configuration,
make it resolve that configuration from a project-level `.config/` directory
(e.g. `.config/<project-name>.toml`) in addition to any other supported
locations. This template already keeps its own tool configs there
(`.config/cspell.json`, `.config/rumdl.toml`, `.config/cliff.toml`); extending
the same convention to what this project ships keeps consumers' repo roots tidy.

References:

- <https://github.com/numtide/prj-spec> — project directory specification
- <https://dot-config.github.io/> — the `.config/` directory convention
- <https://github.com/pi0/config-dir> — reference implementation for resolving it
