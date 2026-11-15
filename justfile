# pscaffold maintenance commands. Run inside `devbox shell` (or prefix with `devbox run --`).

set shell := ["bash", "-euo", "pipefail", "-c"]

render_dir := justfile_directory() / ".render"

# List recipes.
default:
    @just --list

# Render the template into DEST using the given backend (go|rust).
render backend dest *extra:
    rm -rf {{dest}}
    copier copy --trust --defaults --vcs-ref=HEAD \
      -d project_name="Sample Product" -d backend={{backend}} {{extra}} \
      {{justfile_directory()}} {{dest}}

# Render and run the generated project's full verification.
test backend:
    just render {{backend}} {{render_dir}}/{{backend}}
    cd {{render_dir}}/{{backend}} && devbox run -q -- just verify

# Lint the repo's own shell scripts and the plugin manifest.
lint:
    shellcheck template/.claude/hooks/*.sh
    jq empty .claude-plugin/marketplace.json plugin/.claude-plugin/plugin.json
    actionlint .github/workflows/*.yml
