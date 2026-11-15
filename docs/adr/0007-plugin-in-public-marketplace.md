# The plugin lives in a public marketplace; the template states its contract

The `pscaffold` plugin moved to the public `askhari/claude-plugins` marketplace, next to
`navigate`, so anyone can install it without credentials and one repo publishes every plugin.
This repo keeps only the template. The plugin's skills depend on names and formats the
template provides, so that dependency is written down in `CONTRACT.md` with a version number
that each product declares in `.claude/pscaffold.json`; the skills refuse a product whose
contract they do not speak instead of half-working. Updates stay pull-based: copier records
the template source in each product, and a scheduled workflow in the product proposes
updates, so the template never needs to know which products exist.
