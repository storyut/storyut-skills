---
name: fablely
description: Claude Code project-continuity workflow backed by `.fable/`, a concise CLAUDE.md contract, and optional lifecycle hooks. Use when `.fable/` exists, CLAUDE.md directs Claude to `.fable/PROGRESS.md`, or the user explicitly asks to bootstrap or adopt fablely for a multi-session project. Use to recover truthful state after resume or compaction. Do not auto-adopt an ordinary repository or a directory merely because an artifact is named fablely.
---

# fablely

## Goal

Keep enough truthful state on disk that a fresh Claude Code session can resume safely after interruption or compaction. A task is complete when:

- claims match the strongest evidence actually observed
- `.fable/PROGRESS.md` describes reality before a file-changing turn ends
- durable rationale and lessons live on disk, not only in conversation
- the work clears `.fable/STANDARDS.md`, the project's own quality bar

The bar is an input, not a final inspection. A gate at the end can only pull work up to the bar after the fact; a bar consulted while designing, cited while speccing, and handed to whoever implements means the work was never below it. Read STANDARDS before proposing a shape, not after writing the diff.

The user's request, Claude Code permissions, CLAUDE.md hierarchy, and repository instructions outrank this skill. Fablely coordinates authorized work; it never grants authority to add scaffolding, initialize git, branch, commit, delegate, or touch paths outside the request.

## Activation gate

Choose from observable state and explicit authority:

| Condition | Mode | Action |
|---|---|---|
| `.fable/PROGRESS.md` exists or loaded CLAUDE.md points to it | **Resume** | Load and verify project memory before state-dependent work. |
| Empty directory and user explicitly wants fablely/project scaffolding | **Bootstrap** | Present the proposed files, hooks, and git actions; wait for confirmation. |
| Existing project without `.fable/` and user explicitly asks to adopt fablely | **Adopt** | Reconstruct the project read-only; wait for confirmation. |
| No `.fable/` and no explicit adoption request | **Inactive** | Continue the user's task normally. Create no fablely files, hooks, CLAUDE.md entries, or git state. |

An artifact or skill directory named `fablely` does not activate its parent workspace. Explicit exclusions and “no scaffolding” instructions win immediately.

## Triage

After activation, classify the deliverable:

| Size | Deliverable | Protocol |
|---|---|---|
| **Consult** | Read-only answer, explanation, or investigation | Answer through `fablely-ask`. Run drift detection only if the answer depends on current project state. No intent or PROGRESS update when nothing changed. |
| **Diagnose** | Something is broken, throwing, failing, or slow | Run `fablely-debug`. Stamp `small: diagnose <symptom>` once; it stands through the fix. |
| **Trivial** | Fully specified mechanical change | Stamp `trivial: <change>`, execute, verify, update PROGRESS. |
| **Small** | Contained, reversible, one obvious shape — including a feature or a redesign whose shape is not in question | Write the four-line Intent below, execute, verify, update PROGRESS. |
| **Medium+** | The shape is genuinely open (several plausible designs), *or* the change is hard to undo: public interface, multiple components, security/data risk, stored-data migration | Create or update one `.fable/work/NNN-slug.md` through `fablely-spec`, then execute it. |

New behavior alone does not make work Medium+. Open shape or irreversibility does. One feature with one obvious shape is Small.

Re-triage both ways. Upward when new facts expand the work; downward when they contract it — if one exchange settles the shape, it was Small, so stamp the Intent and execute. A work file for a settled change is ceremony, not continuity.

A diagnosed bug is Small by default: the red loop is the done criterion and the minimised repro is the spec. Escalate only when the fix itself is structural.

Consult is a lane, not a preamble: a question answered through `fablely-ask` ends with the answer. If it reveals work worth doing, bring it back here to be sized and stamped rather than sliding from answering into editing. Re-triage is cheap; an unstamped mutation is the failure the intent gate exists to prevent.

## Intent before mutation

In an active fablely project, write `.fable/.intent` before the first authorized mutation. Read every target file first.

- Trivial: `trivial: <change>`
- Small: `small: <goal>`, `Check first: ...`, `Touches: ...`, `Done when: <command or observable behavior and expected result, plus the STANDARDS clause IDs this work puts at risk>`
- Medium+: `unit: NNN <slug>`; the work file contains the full intent

`Done when` names clause IDs — `SEC-3`, `ERR-1` — or `none at risk` when the change genuinely touches no clause. Naming them costs a moment and forces the bar into view before the first edit rather than after the diff exists. `none at risk` on a change that touches auth, input parsing, error paths, or stored data is a triage error; re-read the clause before claiming it.

One intent covers one arc of work. A `small: diagnose` intent stands through the fix that follows it — extend its `Done when` with the loop command rather than re-stamping.

State a Small Intent once, then proceed. Include external and protected paths when work crosses the project root. The PreToolUse hook enforces this for Edit/Write; shell and other mutation paths remain the model's responsibility.

An explicit file allowlist that excludes `.fable/` also excludes intent and PROGRESS writes. Honor it. Account for both Claude lifecycle gates: if PreToolUse denies Edit/Write, report the contract conflict and request authority for the intent write or hook bypass before mutating; if Stop later blocks because PROGRESS cannot be updated, report the unrecorded continuity and let its one-block loop guard release the next stop. Never evade either gate through an unapproved shell mutation, write excluded metadata, or silently widen the allowlist.

Bootstrap and Adopt are exceptions: their first writes occur only after their checkpoint, so the presented scaffold is the pre-write intent.

## Resume protocol

1. Read PROGRESS first, then the active work unit if one is in flight. Load other memory only as needed.
2. Compare recorded branch/SHA and expected local changes with actual git state. In an intentionally non-git project, record that and skip git-only checks.
3. If memory differs from reality, say so, reconstruct from status/history/tree, and rewrite PROGRESS before implementation. Preserve unexplained user changes.
4. Spot-check one or two concrete claims from PROGRESS against the tree.
5. State the current state and one next action, then perform the requested work.

Inspect overlapping dirty edits before continuing. Continue when both changes can be preserved. Use **CHECKPOINT · STOP** only when ownership or intended behavior cannot be inferred safely. Never clean the tree by stashing, reverting, overwriting, or switching branches without authority.

## Bootstrap and Adopt

### Bootstrap

For an empty project, derive the mission and scaffold from `templates/`. Present:

- `.fable/`, CLAUDE.md, hook, settings, and `.gitignore` changes
- each proposed git action: init, branch, and initial commit

**CHECKPOINT · STOP:** obtain confirmation before writing. Approval of scaffolding authorizes only the items listed; git actions need explicit inclusion.

Instantiate `templates/fable/STANDARDS.md` as-is and present it with the rest: it is the project's bar and the user is entitled to trim it before it starts blocking anything. Ask which shipped clauses do not apply here rather than guessing them away.

After confirmation, create the selected scaffold, an empty `.fable/work/`, and the approved hooks. Do not instantiate the work-unit template. Preserve existing settings and CLAUDE.md content.

### Adopt

Inspect code, docs, and history read-only. Draft MISSION, MAP, initial DECISIONS, STANDARDS, the CLAUDE.md contract, hook/settings changes, and `.gitignore` entries.

For STANDARDS, start from `templates/fable/STANDARDS.md` and reconcile it with the project as it actually is: fold in what `CONTRIBUTING.md`, style guides, and linter configuration already require; move clauses the codebase clearly does not need into Not applicable with the reason; add `PRJ-` clauses for conventions the code follows consistently but no document states. Do not silently drop a clause the existing code breaches — an adopted codebase failing a clause is a finding to report at the checkpoint, not a reason to lower the bar. The user decides whether it becomes work or a waiver.

**CHECKPOINT · STOP:** present the draft before writing. If the user declines or forbids scaffolding, leave the project untouched and continue the original task with fablely inactive. Never initialize git during adoption unless separately requested.

## Work-unit lifecycle

For Medium+ work:

1. **Load and critique.** Read Design, Spec, status, and remaining steps. If they contradict the tree, update the work file before coding.
2. **Start truthfully.** Set status to `in-progress` and PROGRESS In flight to the unit and current step.
3. **Execute incrementally.** Complete one checkbox at a time. Record deviations where the next session will see them.
4. **Handle failure.** Diagnose a failed check, make one evidence-based correction, and rerun it. If the same blocker remains or new authority is required, update PROGRESS and stop with actual output.
5. **Review by risk.** Follow `references/review.md`; use isolated subagents only when permitted and useful. The standards axis blocks: an open finding stops completion until it is fixed or waived by a DECISIONS entry.
6. **Verify behavior.** Exercise the affected flow when feasible and record what was not observed.
7. **Complete.** Clear the standards box first — it gates the rest. Then promote rationale to DECISIONS, lessons to LESSONS, write Outcome, collapse PROGRESS to a concise pointer, and perform only authorized git actions.

## Evidence

Report claims at these levels:

1. **Observed behavior:** drove the relevant flow and saw the result.
2. **Red then green:** watched a focused test fail for the expected reason, then pass.
3. **Targeted passing checks:** relevant assertions passed without proving causality or the complete flow.
4. **Static inspection:** inspected code or validated configuration without executing behavior.
5. **Unverified:** hypothesis or recollection; inspect before relying on it.

A green inherited test proves its assertions passed, not that every feature path works. Prefer red/green when practical; never damage user code merely to manufacture red. Record misleading tests in LESSONS. See `references/evidence.md`.

## Claude Code delegation

Use the main conversation for project state, design decisions, acceptance, and final verification. Claude Code subagents start with isolated context and do not inherit the conversation or previously loaded skills.

Delegate only when the user/runtime permits it and the task benefits from independent context: parallel read-heavy investigation, specialized analysis, or fresh-eyes review. Keep a simple edit in the main agent. A complete brief includes goal, why it matters, allowed files, constraints, relevant skill content or pointers, and a runnable success criterion. Reproduce the result before accepting it.

An implementation brief also carries the bar: paste in the `.fable/STANDARDS.md` clauses the task puts at risk — the text, not the IDs — as hard requirements, plus the work file's Clears-the-bar block. A subagent starts cold and cannot read the project's memory unless you hand it over; a pointer to a file it will not open is the same as saying nothing. Pasting the relevant clauses rather than the whole file keeps them salient. This is what makes the standards axis a formality rather than a rework loop: the implementer already had the rubric.

Do not delegate when the user says to work directly. Do not assume a particular model tier; select or inherit the model according to configured capability and task risk. Never finish while an authorized subagent is still running.

## Project memory

| File | Purpose | Rule |
|---|---|---|
| `MISSION.md` | Scope and purpose | Change only after explicit scope approval. |
| `STANDARDS.md` | The quality bar, as cited clause IDs | Read before designing. Weaken only with approval plus a DECISIONS entry. |
| `PROGRESS.md` | Resume anchor and one next action | Rewrite to current truth; keep concise. |
| `DECISIONS.md` | Durable rationale | Append; supersede rather than erase. |
| `LESSONS.md` | Corrections, dead ends, misleading tests | Append at discovery time. |
| `MAP.md` | Navigational map | Regenerate after structural changes. |
| `work/NNN-slug.md` | Design, spec, plan, outcome | Keep completed units for history. |
| `research/slug.md` | Dated, sourced external findings | Cite from the relevant work unit. |

Schemas are in `references/schemas.md`. Update PROGRESS before any file-changing turn ends, including a blocked turn. If permission or scope prevents that update, honor the boundary and report that continuity could not be recorded.

## Git boundaries

- Use read-only git commands for drift detection.
- Initialize, branch, commit, push, stash, reset, revert, or switch only when the user or established repository workflow authorizes it.
- Preserve unrelated dirty work and exclude it from any authorized commit.
- When checkpoint commits are authorized, use `checkpoint(NNN): <outcome>` and record branch/SHA in PROGRESS.
- Record external or uncommitted artifacts honestly; one repository cannot checkpoint another path.

## Claude Code hooks

CLAUDE.md and skills are contextual instructions, not enforcement. Keep the CLAUDE.md contract concise, specific, and non-conflicting. Hooks enforce fixed lifecycle points:

- **SessionStart:** on startup/resume/clear/compact, inject the resume pointer and establish a baseline.
- **PreToolUse (Edit|Write):** deny direct file edits until this session has an intent; it deliberately does not claim to cover shell mutations.
- **Stop:** block once when project files changed after the last PROGRESS update.

The scripts resolve paths from `CLAUDE_PROJECT_DIR`, preserve existing settings, and fail open on internal error. Install and test them using `references/hooks.md`. Hooks are a backstop; they do not replace the workflow or expand authority.

## Failure routing

| Trigger | First response | If unresolved |
|---|---|---|
| Missing/malformed PROGRESS | Reconstruct from git and tree | Back up, rewrite, record the lesson. |
| Recorded SHA missing | Use status/log/reflog read-only | Mark checkpoint unknown; do not invent one. |
| No git repository | Use tree state and timestamps | Do not initialize git automatically. |
| Plan contradicts code | Amend Design/Spec/Plan | Stop if user-visible scope changes. |
| Verification fails | Diagnose and make one justified correction | Record blocker after the same failure persists. |
| Standards finding blocks completion | Fix the code | Waive with a DECISIONS entry naming the clause and the reason, or stop and report; never leave it silently unresolved. |
| No `.fable/STANDARDS.md` in an active project | Propose one from `templates/fable/` at the next checkpoint | Proceed with the template's clauses as the working bar and say so. |
| Hook blocks unexpectedly | Read its returned reason and satisfy the stated invariant | Disable only with user authority if the hook itself is faulty. |
| No active fablely project and the user forbids fablely files or scaffolding | Keep fablely inactive | Complete the original task without scaffolding. |

## Boundaries

- Keep fablely inactive outside explicitly adopted projects.
- Treat explicit path allowlists and user-owned dirty work as hard boundaries.
- Use hooks for deterministic timing and concise positive instructions for model behavior.
- Keep PROGRESS current rather than accumulating a session log.
- Describe static checks as static checks and passing tests as passing tests.
- Treat STANDARDS as a floor to design against, not a checklist to satisfy afterward — and never edit a clause to make a failing diff pass.
- Leave git history, branches, and subagent use unchanged unless authorized.

## Communication

Be concise and outcome-first. State the Intent and material changes of course; provide progress updates required by the active harness. Ask at marked checkpoints, genuine ambiguity tools cannot resolve, destructive actions, or requests for new authority. Final reports name the outcome, exact evidence, remaining uncertainty, and any user decision still required.

## Resources

- `references/schemas.md` — `.fable/` schemas
- `references/evidence.md` — evidence and claim phrasing
- `references/review.md` — risk-scaled review, incl. the blocking standards axis
- `references/hooks.md` — hook configuration and tests
- `templates/CLAUDE.md.template` — concise auto-resume contract
- `templates/fable/` and `templates/hooks/` — bootstrap skeletons

Sibling skills: `fablely-ask` answers Consult questions read-only; `fablely-debug` runs the Diagnose lane; `fablely-spec` designs and specs a Medium+ unit. The standalone `/ask` covers questions outside a fablely project and stays user-invoked.
