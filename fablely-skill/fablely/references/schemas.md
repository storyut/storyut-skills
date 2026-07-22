# `.fable/` file schemas

`PROGRESS.md` is rewritten in place. `DECISIONS.md` and `LESSONS.md` are append-only. `MAP.md` is regenerated wholesale from the tree. `MISSION.md` is written once and edited only on an explicit scope change. `STANDARDS.md` is edited deliberately, and only with the user's say-so.

## MISSION.md

Purpose: the fixed statement of what this project is and isn't, set once at the start.

```markdown
# Mission

## What

One paragraph: what this project is.

## Why

Who it's for, and what breaks if it's wrong.

## Scope

### In

- ...

### Out

- ...

## Done means

Falsifiable criteria — statements that can be checked true or false, not vibes.
```

Rule: a scope change requires the user's explicit say-so plus an entry in `DECISIONS.md` recording the boundary move. Don't drift the scope by quietly editing this file mid-task.

## PROGRESS.md

Purpose: the resume anchor — the one file a session reads first to pick up where the last one left off.

```markdown
# Progress

## Current state

One short paragraph of what is true right now.

## Verified

What has been verified, and at what evidence level (see evidence.md) —
e.g. "billing flow driven end-to-end 2026-07-14" vs "unit tests green, unexercised".

## In flight

Work unit + step, or "nothing".

## Next action

Exactly one action. Not a list.

## Expected local changes

Paths intentionally dirty, excluding the PROGRESS.md update itself; or "none".

## Checkpoint

Branch, git SHA, and ISO timestamp; or `git: not in use` plus timestamp.
```

Rules:
- Rewrite in place — this file has no history, it only describes now. Rewriting means deleting what no longer describes now, not appending a new paragraph beside the old one.
- Keep it under ~40 lines. If it's growing, something belongs in `DECISIONS.md`, `LESSONS.md`, or a work file instead.
- When a work unit completes, its presence in Current state collapses to one line: unit number, one-clause outcome, pointer to that unit's `work/NNN-slug.md` Outcome section. The narrative — what was tried, what changed, why — belongs in the work file's Outcome, never in PROGRESS. A PROGRESS.md that only ever grows is a session log wearing the wrong filename.
- Never record a claim above its evidence level. "Verified" means verified, not "should work."
- Update before any stop if the tree changed since the last update.
- Update immediately when context is getting tight — what survives compaction is what's on disk, not what's in the conversation.

## STANDARDS.md

Purpose: the project's quality bar — the rubric that says what "well implemented" means here, so the bar is an input to the work rather than something a human supplies afterward.

```markdown
# Standards

## <Category>

- **<ID> — <the rule, as a falsifiable statement.>** Elaboration if needed.

## Not applicable

<ID> — why it does not apply to this project.

## Project-specific

- **<PRJ-N> — <rule>**
```

Rules:
- Every clause carries a stable ID (`SEC-1`, `ERR-2`, `PRJ-3`). IDs are cited in work units' Clears-the-bar blocks, in Small Intents' `Done when`, and in review findings. Never renumber an existing ID — retire it into Not applicable instead, or the citations elsewhere in `.fable/` start pointing at the wrong rule.
- Edited deliberately and with the user's say-so, like MISSION. Weakening or deleting a clause is a scope-level decision and gets a `DECISIONS.md` entry naming the clause and the reason. Silently dropping a clause the work failed is how the bar erodes to the level of the last thing that was hard.
- Adding a project-specific clause is cheap and needs no ceremony beyond telling the user. Promote a `LESSONS.md` entry here once the same mistake has recurred — a lesson is a record of one past failure, a standard is a guard against the next one.
- Keep clauses falsifiable. "Handle errors properly" cannot be reviewed against; "no empty catch, no ignored error return" can.
- A clause the project routinely violates on purpose is worse than no clause. Trim it.

## DECISIONS.md

Purpose: a durable log of why the project is shaped the way it is, so nobody re-litigates a settled call from scratch.

```markdown
## YYYY-MM-DD — <short decision title>

**Chose:** X
**Over:** Y
**Because:** Z
**Revisit if:** ... (optional)
```

Rules: append only — never rewrite or delete an old entry, even if it turns out wrong. A superseded decision gets a *new* entry that names the entry it replaces. The history of having-been-wrong is itself useful; don't erase it.

## LESSONS.md

Purpose: a durable log of mistakes, dead ends, and things that looked fine but weren't — written so the next session doesn't repeat them.

```markdown
## YYYY-MM-DD — <short lesson title>

**What happened:**
**The lesson:**
**Applies when:**
```

Rules: append only. Capture the entry at the moment of correction or dead end, not reconstructed at session end from memory — the details are freshest right then. Lying tests always get an entry: a test that passes while the code is broken, or one that covers only the happy path so a broken branch slips through. This is the single most valuable thing a future session can learn about the suite, because a green checkmark otherwise reads as trustworthy.

## MAP.md

Purpose: an orientation map of the codebase — where things live and where the docs are — generated fresh from the current tree.

```markdown
<!-- Regenerated from the tree. Do not hand-edit; regenerate instead. -->

# Map

Generated: YYYY-MM-DD, <git SHA>

## Entry points

## Layout

| Path | Responsibility |
| --- | --- |

## Docs

Where the documentation lives.
```

Rules: when files are added, moved, or removed, regenerate the whole file from the tree. Patching it by hand is how it starts lying — a hand-edited line survives the next real change and nobody notices until it's wrong. Cap the depth at entry points plus the top two directory levels, one responsibility line each — a map that inventories every file is too expensive to keep regenerating, and a map nobody regenerates lies.

## work/NNN-slug.md

Purpose: one self-contained unit of work — design, spec, and plan together — written by the fablely-spec skill.

```markdown
# NNN — <name>

status: specced | in-progress | done
created: YYYY-MM-DD

## Design

The shape chosen. Alternatives considered, and why they lost.

## Spec

Observable behavior, edge cases, done criteria — behavioral: drive the flow, observe.

## Clears the bar

Per `STANDARDS.md` clause this unit puts at risk: the ID, how the design
satisfies it, and how a reviewer will check. "Not at risk" for the rest.

## Plan

Bite-sized checkbox steps, test-first, exact paths, exact commands, expected
output — task structure per fablely-spec's references/plan-format.md.

## Completion

- [ ] Standards axis clear: no open finding, or each waived by a DECISIONS.md entry
- [ ] Durable why promoted to DECISIONS.md
- [ ] Lessons promoted to LESSONS.md
- [ ] PROGRESS.md entry collapsed to one line
- [ ] Authorized checkpoint git action completed, or "not authorized" recorded
- [ ] Status flipped to done

## Outcome

What actually happened, what evidence was observed, and what remains limited.
```

Rules: `NNN` is the next unused zero-padded number starting from `001`. The standards box gates the rest: status does not flip to `done` and no checkpoint commit happens while a standards finding is open and unwaived. Design, spec, and plan stay in one file — splitting them across files is how they end up contradicting each other as one gets updated and the others don't. Done work files are kept for the record but never read on resume; `PROGRESS.md` is what resume reads. Outcome is the one exception worth reading: `PROGRESS.md` points to it by design.

## research/slug.md

Purpose: findings from one investigation of facts outside the tree — library behavior, API contracts, prior art — written by a research agent dispatched via fablely-spec, cited from work files' Design sections.

```markdown
# <question investigated>

date: YYYY-MM-DD

## Answer

The finding, stated plainly.

## Evidence

Per claim: the claim, then the primary source that owns it (link or path).

## Sources

- <url or path> — what it is
```

Rules: one file per investigation; `slug` is short kebab-case. Prefer primary sources. A claim without checkable evidence does not belong. Research is dated reference material, not timeless memory.

## Not project memory

`.fable/hooks/` holds the three hook scripts. `.fable/.session-start` is a machine-written timestamp and `.fable/.intent` is the per-task intent stamp (both gitignored). None of these are project memory — don't read them for context, don't write project state into them.
