---
name: fablely
description: Claude Code project-continuity workflow backed by `.fable/` and optional lifecycle hooks. Use when `.fable/PROGRESS.md` exists, CLAUDE.md points to it, the user asks to bootstrap/adopt fablely, or state must be recovered after interruption or compaction. Never auto-adopt an ordinary repository or a directory merely containing a fablely artifact.
---

# fablely

Keep enough truthful state on disk that a fresh session can resume safely. Completion requires claims bounded by observed evidence, current `PROGRESS.md`, durable rationale/lessons on disk, and work that clears `STANDARDS.md`.

User instructions, permissions, CLAUDE.md hierarchy, and repository rules outrank this skill. Fablely coordinates authorized work; it grants no authority to scaffold, mutate git, delegate, or exceed path scope.

## 1. Activate

| Observed state | Mode | Action |
|---|---|---|
| `.fable/PROGRESS.md` exists or CLAUDE.md points to it | **Resume** | Run the resume protocol before state-dependent work. |
| Empty directory; user explicitly requests fablely scaffolding | **Bootstrap** | Draft the scaffold; stop at the setup checkpoint. |
| Existing project; user explicitly requests adoption | **Adopt** | Reconstruct read-only; stop at the setup checkpoint. |
| Otherwise | **Inactive** | Continue normally; create no fablely, hook, CLAUDE.md, or git state. |

Explicit exclusions and “no scaffolding” win. **Completion criterion:** one mode selected from observable state and authority.

## 2. Triage the deliverable

| Lane | Test | Protocol |
|---|---|---|
| **Consult** | Answer/explain/investigate; no edits | Answer read-only inline. `/fablely-ask` is the user-invoked shortcut, not an automatic dependency. Drift-check only state-dependent claims. |
| **Diagnose** | Broken, failing, throwing, or slow | Use `fablely-debug`. One `small: diagnose <symptom>` intent stands through an authorized fix. |
| **Trivial** | Fully specified mechanical edit | One-line intent, execute, verify, update PROGRESS. |
| **Small** | Contained, reversible, one obvious shape | Four-line intent, execute, verify, update PROGRESS. |
| **Medium+** | Several plausible shapes or hard to undo: public interface, multiple components, security/data risk, migration | Use `fablely-spec` for one `.fable/work/NNN-slug.md`, then execute it. |

New behavior alone is not Medium+. Re-triage when facts expand or settle the shape. A diagnosed bug is Small unless its fix is structural. Consult ends with the answer; discovered work returns here instead of sliding into edits.

## 3. Gate mutation with intent

Before the first authorized mutation in an active project, read every target and `STANDARDS.md`, then write `.fable/.intent`:

- Trivial: `trivial: <change>`
- Small: `small: <goal>`, `Check first: ...`, `Touches: ...`, `Done when: <observable result or command + expected output; STANDARDS clause IDs at risk or none at risk>`
- Medium+: `unit: NNN <slug>`; the work file is the full intent

One intent covers one work arc. Extend a diagnosis intent with its red loop; do not restamp for the fix. `none at risk` is invalid for auth, input parsing, error paths, or stored data without rereading the bar. Include authorized external/protected paths.

Bootstrap/Adopt use the approved proposal as pre-write intent. An allowlist excluding `.fable/` forbids intent and memory writes. If PreToolUse blocks, report the scope conflict and request authority or bypass; never evade it through shell mutation. If Stop blocks because PROGRESS cannot be written, report lost continuity and let its one-block guard release the next stop.

**Completion criterion:** intent exists before mutation and names a falsifiable done condition plus the bar at risk.

## 4. Resume

1. Read PROGRESS, then the active work unit. Load other memory only as needed.
2. Compare recorded branch/SHA and expected changes with actual git state; record intentional non-git use.
3. On drift, say so, reconstruct from status/history/tree, and rewrite PROGRESS before implementation. Preserve unexplained changes.
4. Spot-check one or two concrete memory claims against the tree.
5. State current truth and one next action, then continue.

Inspect overlapping dirty edits. Continue when both can be preserved; use **CHECKPOINT · STOP** only when ownership or intended behavior cannot be inferred. Never clean the tree by stash, revert, overwrite, reset, or branch switch without authority.

## 5. Bootstrap or Adopt

Use `templates/`. Before writing, present the exact scaffold, hook/settings and `.gitignore` changes, plus each git action; then **CHECKPOINT · STOP**. Approval covers only listed items.

- **Bootstrap:** derive MISSION; present `STANDARDS.md` unchanged and ask which clauses do not apply; after approval create selected files, hooks, and empty `.fable/work/`. Do not instantiate `work-unit.md` or overwrite existing settings/CLAUDE.md.
- **Adopt:** inspect code, docs, standards, linter config, and history read-only. Draft MISSION, MAP, DECISIONS, STANDARDS, CLAUDE.md contract, hooks/settings, and `.gitignore`. Preserve documented conventions, add stable `PRJ-` clauses, and report existing breaches instead of lowering the bar. If declined, write nothing and continue inactive. Never initialize git unless separately requested.

Install and test hooks through `references/hooks.md`.

## 6. Execute a work unit

1. Read and critique Design, Spec, status, and remaining Plan; reconcile contradictions with the tree before coding.
2. Set `status: in-progress` and point PROGRESS at the unit and step.
3. Complete one checkbox at a time; record deviations where the next session will see them.
4. On failure, diagnose, make one evidence-based correction, and rerun. If the same blocker persists or authority is missing, update PROGRESS and stop with actual output.
5. Review the complete diff by risk through `references/review.md`. An open standards finding blocks completion until fixed or waived in DECISIONS.
6. Exercise affected behavior when feasible; record what was not observed.
7. Clear the standards box first, then promote durable decisions/lessons, write Outcome, collapse PROGRESS to a concise pointer, and perform only authorized git actions.

Delegation is optional and permission-bound. Keep state, design decisions, acceptance, and final verification here. A cold implementation brief includes goal, allowed files, constraints, runnable success criterion, the Clears-the-bar block, and the full text of at-risk standards clauses. Reproduce delegated results before accepting them; never finish with an authorized agent still running.

## 7. Preserve truth

`references/schemas.md` is authoritative for project memory. Keep PROGRESS under about 40 lines and rewrite it to current truth before every file-changing turn ends, including blocked turns. MISSION changes need scope approval; STANDARDS weakening needs approval plus a DECISIONS entry; DECISIONS and LESSONS append; MAP regenerates after structural changes.

Use the evidence hierarchy in `references/evidence.md`. A passing inherited test proves only its assertions passed. Never manufacture red by damaging user code. Record lying tests in LESSONS when discovered.

Git mutations require user or established-workflow authority. Preserve unrelated dirty work and exclude it from commits. Authorized checkpoints use `checkpoint(NNN): <outcome>` and record branch/SHA; one repository cannot checkpoint external paths.

## Failure routes

- Missing/malformed PROGRESS or unresolved SHA: reconstruct read-only; never invent state.
- Plan contradicts code: amend Design/Spec/Plan; stop if user-visible scope changes.
- Missing STANDARDS: propose the template at the next checkpoint and use its clauses as the declared working bar.
- Hook failure: satisfy its reported invariant; disable only with user authority if the hook is faulty.
- Permission prevents continuity writes: honor the boundary and report the unrecorded state.

Final reports lead with outcome, exact evidence, remaining uncertainty, and any required decision.

## Resources

- `references/schemas.md` — memory schemas
- `references/evidence.md` — evidence levels and claim phrasing
- `references/review.md` — risk-scaled three-axis review
- `references/hooks.md` — Claude Code hook behavior, install, and tests
- `templates/CLAUDE.md.template`, `templates/fable/`, `templates/hooks/` — scaffolds
- User-invoked `fablely-ask` — strict Consult shortcut; `fablely-debug` — diagnosis; `fablely-spec` — Medium+ design
