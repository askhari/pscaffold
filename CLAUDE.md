# pscaffold

This repo is the copier template every pscaffold product is generated from (`template/` +
`copier.yml`). `docs/adr/` explains why it looks the way it does.

The `pscaffold` plugin that drives products (skills, `PREFERENCES.md`) lives in the public
marketplace repo `askhari/claude-plugins`, under `plugins/pscaffold`. What the plugin relies on
is written down in `CONTRACT.md`: any change to a clause there is compatible or breaking, and
a breaking one bumps the contract version (`CONTRACT.md` and `template/.claude/pscaffold.json`)
and needs a matching plugin release. Record every release in `CHANGELOG.md` with its contract
version.

Working here:
- All files are written in English.
- Template files ending in `.jinja` are rendered by copier; everything else is copied verbatim.
  Escape literal `{{ }}` (GitHub Actions expressions, etc.) with `{% raw %}…{% endraw %}`.
- Never hand-edit lockfiles or generated code under `template/`; regenerate them through a
  rendered project (`just render go /tmp/x`) and copy the results back.
- `just test go` / `just test rust` renders the template into `.render/` and runs the generated
  project's `just verify`. Run it for both backends before declaring template work done.
- Nothing personal in the template: no owner, account or host defaults. This repo is public.
