# Products are generated and updated with copier

Products are created from a copier template instead of a GitHub template repository, because
copier records the template version in `.copier-answers.yml` and `copier update` can later
merge template improvements (hooks, workflows, SDK bumps) into existing products. A GitHub
template copies once and never updates, which does not scale across several products.
