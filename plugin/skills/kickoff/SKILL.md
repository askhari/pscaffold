---
name: kickoff
description: Product interview for a new product — turn a fuzzy idea into a decided brief (problem, users, MVP, roadmap, constraints) in docs/brief.md. First step of the pscaffold pipeline; hands off to `architect`. Use when starting a new product or on "kickoff", "brainstorm the product", "what should we build".
argument-hint: "[product directory or one-line idea]"
---

# kickoff

Interview the user until the product is decided, then write `docs/brief.md`. Stay at product
altitude — what to build and for whom. Stack, architecture and repo layout belong to
`architect`; if the conversation drifts there, note the point for later and come back.

## Before asking anything

1. Read the standing preferences: `PREFERENCES.md` shipped with this plugin
   (`../../PREFERENCES.md` relative to this skill's directory) or, if the user keeps a copy, the path they give.
   Never ask what it already settles.
2. If the product directory already has `docs/brief.md`, this is an amendment: read it and
   only revisit what the user wants to change.
3. Read any material the user points to (notes, competitors, sketches) instead of asking.

## Interview

One question at a time. For each, give your recommended answer and why, then wait.

1. **Problem and users** — one sentence in the user's words: who has what pain, and why now.
2. **Core loop** — the one thing a user does repeatedly that delivers the value.
3. **MVP boundary** — the smallest slice that is demoable and worth shipping. Name everything
   else explicitly and move it to the roadmap.
4. **Platforms and usage** — which of iOS / iPadOS / Android / web matter for the MVP, and
   which flows must work offline (the default is "mobile works offline, web is online").
5. **Accounts and data** — who signs in, with what (email/password, Google, Microsoft, Apple),
   what data a user owns, whether data is shared between users or organizations.
6. **Constraints** — deadline, budget ceiling for infrastructure, compliance or privacy
   (personal data, minors, health, payments), store requirements, "never do X".
7. **Success signal** — how we will know the MVP works (one or two observable measures).

Push back on scope creep: an MVP with more than a handful of roadmap items inside it is
not an MVP.

## Output

Create the product directory if needed (`git init` it) and write `docs/brief.md`:

```markdown
# <Product name>

## Problem
## Users
## Core loop
## MVP
- <capability> — one line each
## Roadmap
1. <item> — one line each, ordered; these become `spec` inputs
## Constraints
## Out of scope
## Success signal
## Glossary
- **Term** — definition (every domain word coined in the interview)
```

Keep it tight; it is read by every later skill and by agents that build features. Do not
write `CLAUDE.md` — the template generates a short one later.

Finish by telling the user the next step: run `architect` on this directory.
