# pscaffold maintenance commands. Run inside `devbox shell` (or prefix with `devbox run --`).

set shell := ["bash", "-euo", "pipefail", "-c"]

render_dir := justfile_directory() / ".render"

# List recipes.
default:
    @just --list

# Render the template into DEST using the given backend (go|rust).
render backend dest *extra:
    scripts/render.sh {{backend}} {{dest}} {{extra}}

# Render and run the generated project's full verification.
test backend:
    just render {{backend}} {{render_dir}}/{{backend}}
    cd {{render_dir}}/{{backend}} && devbox run -q -- just verify

# Lint the repo's own shell scripts, the template's Claude config and the workflows.
lint:
    shellcheck template/.claude/hooks/*.sh template/scripts/*.sh scripts/*.sh
    jq empty template/.claude/settings.json template/.claude/pscaffold.json
    actionlint .github/workflows/*.yml template/.github/workflows/template-update.yml
