# pscaffold

This repo ships two things that evolve together:

- `plugin/` — a Claude Code plugin (`pscaffold`) with the product pipeline skills.
- `template/` + `copier.yml` — the copier template every new product is generated from.

`plugin/PREFERENCES.md` holds the standing decisions the skills rely on; `docs/adr/` explains why.

Working here:
- All files are written in English.
- Template files ending in `.jinja` are rendered by copier; everything else is copied verbatim.
  Escape literal `{{ }}` (GitHub Actions expressions, etc.) with `{% raw %}…{% endraw %}`.
- Never hand-edit lockfiles or generated code under `template/`; regenerate them through a
  rendered project (`just render go /tmp/x`) and copy the results back.
- `just test go` / `just test rust` renders the template into `.render/` and runs the generated
  project's `just verify`. Run it for both backends before declaring template work done.
