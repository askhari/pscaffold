#!/usr/bin/env bash
# One-off GitHub setup for a new repository. Outward-facing: run it yourself after reviewing it.
# Requires an authenticated `gh` with admin rights on the repository.
set -euo pipefail

repo=$(gh repo view --json nameWithOwner -q .nameWithOwner)
echo "Configuring $repo"

gh label create risk:low --color 0e8a16 --description "Green checks are enough" --force
gh label create risk:normal --color fbca04 --description "Needs one human review" --force
gh label create risk:high --color d93f0b --description "Needs explicit owner approval" --force

gh api -X PUT "repos/$repo/environments/dev" >/dev/null
gh repo edit "$repo" --enable-auto-merge --delete-branch-on-merge

gh api -X PUT "repos/$repo/branches/main/protection" --input - <<'JSON'
{
  "required_status_checks": { "strict": true, "contexts": ["ci", "risk-label"] },
  "enforce_admins": false,
  "required_pull_request_reviews": { "required_approving_review_count": 0, "require_code_owner_reviews": false },
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false
}
JSON
echo "Done. Add the dev environment secrets listed in README.md."
