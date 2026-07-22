---
name: fablely-codex
description: Codex port of the fablely project-continuity workflow backed by a `.fable/` directory. Use when a project already contains `.fable/`, its AGENTS.md directs agents to `.fable/PROGRESS.md`, or the user explicitly asks to bootstrap or adopt fablely for a multi-session project. Also use to recover stale project state after interruption or compaction. Do not auto-adopt an ordinary repository merely because work begins there.
---

# fablely-codex

## Goal

Keep enough truthful state on disk that another session can resume safely after an interruption. A task is complete only when:

- the claim is no stronger than the observed evidence
- `.fable/PROGRESS.md` describes the actual state before a file-changing turn ends
- durable rationale and lessons live on disk, not only in chat
- the work clears `.fable/STANDARDS.md`, the project's own quality bar

The bar is an input, not a final inspection. A gate at the end can only pull work up to the bar after the fact; a bar consulted while designing, cited while speccing, and handed to whoever implements means the work was never below it. Read STANDARDS before proposing a shape, not after writing the diff.

The user's request, system instructions, repository instructions, and tool permissions outrank this skill. Fablely records and coordinates authorized work; it never creates authority to add scaffolding, initialize git, branch, commit, delegate, or touch paths outside the request.

## Activation gate

Choose the mode from the directory and the user's authority:

| Condition | Mode | Action |
|---|---|---|
| `.fable/` exists or AGENTS.md points to it | **Resume** | Load and verify project memory before state-dependent work. |
| Empty directory and user explicitly wants fablely/project scaffolding | **Bootstrap** | Show the planned files and git actions, then wait at the checkpoint below. |
| Existing project without `.fable/` and user explicitly asks to adopt fablely | **Adopt** | Reverse-engineer the project read-only, then wait at the checkpoint below. |
| No `.fable/` and no explicit adoption request | **Inactive** | Do not create `.fable/`, AGENTS.md, `.gitignore`, branches, or commits. Continue the user's task normally without this skill. |

Mentions of `fablely` as an artifact to inspect or edit do not authorize adopting the containing workspace. If the user excludes a path or forbids scaffolding, that boundary wins immediately.

## Triage

After activation, classify the deliverable—not the wording:

| Size | Deliverable | Protocol |
|---|---|---|
| **Consult** | Read-only answer, explanation, or investigation | Answer through `fablely-ask-codex`. Run drift detection only when the answer depends on current project state. Do not stamp intent or update PROGRESS when nothing changed. |
| **Diagnose** | Something is broken, throwing, failing, or slow | Run `fablely-debug-codex` read-only first. Stamp `small: diagnose <symptom>` only before an explicitly authorized mutation; once stamped, it stands through the fix. |
| **Trivial** | Fully specified mechanical change | Write one `trivial:` line to `.fable/.intent`, execute, verify, update PROGRESS. |
| **Small** | Contained, reversible, one obvious shape — including a feature or a redesign whose shape is not in question | Write the four-line Intent below, execute, verify, update PROGRESS. |
| **Medium+** | The shape is genuinely open (several plausible designs), *or* the change is hard to undo: public interface, multiple components, security/data risk, stored-data migration | Create or update one `.fable/work/NNN-slug.md` through `fablely-spec-codex`, then execute its plan. |

New behavior alone does not make work Medium+. Open shape or irreversibility does. One feature with one obvious shape is Small.

Re-triage both ways. Upward when facts expand the work; downward when they contract it — if one exchange settles the shape, it was Small, so stamp the Intent and execute. Do not spec a typo, do not hide an open design question inside a Small intent, and do not write a work file for a change that is already settled.

A diagnosed bug is Small by default: the red loop is the done criterion and the minimised repro is the spec. Escalate only when the fix itself is structural.

Consult is a lane, not a preamble: a question answered through `fablely-ask-codex` ends with the answer. If it reveals work worth doing, bring it back here to be sized and stamped rather than sliding from answering into editing.

## Intent before mutation

In an active fablely project, write `.fable/.intent` before the first authorized mutation. Read every target file first.

- Trivial: `trivial: <change>`
- Small: four lines—`small: <goal>`, `Check first: ...`, `Touches: ...`, `Done when: <command or observable behavior and expected result, plus the STANDARDS clause IDs this work puts at risk>`
- Medium+: `unit: NNN <slug>`; the work file is the full intent

`Done when` names clause IDs — `SEC-3`, `ERR-1` — or `none at risk` when the change genuinely touches no clause. Naming them costs a moment and forces the bar into view before the first edit rather than after the diff exists. `none at risk` on a change touching auth, input parsing, error paths, or stored data is a triage error; re-read the clause before claiming it.

One intent covers one arc of work. A `small: diagnose` intent stands through the fix that follows it — extend its `Done when` with the loop command rather than re-stamping.

State a Small Intent once in commentary, then proceed. Include external paths and protected paths explicitly when work crosses the project root. Intent does not override the user's allowlist.

Bootstrap and Adopt are exceptions: their first writes occur only after their explicit checkpoint, so the proposed scaffold serves as the pre-write intent.

## Resume protocol

1. Read `PROGRESS.md` first, then the active work unit if one is in flight. Read MISSION, DECISIONS, LESSONS, or MAP only as needed.
2. Compare the recorded branch and checkpoint SHA with actual git state. Compare recorded expected local changes with `git status`. If the project is intentionally non-git, record that and skip git-only checks.
3. If memory and reality differ, say so, reconstruct state from status/history/tree, and rewrite PROGRESS before implementation. Preserve unexplained user changes.
4. Spot-check one or two concrete claims from PROGRESS against the tree.
5. State the current state and one next action, then perform the requested work.

If an unexplained edit overlaps the requested change, inspect the diff. Continue when both changes can be preserved; use a **CHECKPOINT · STOP** only when ownership or desired semantics cannot be inferred safely. Never stash, revert, overwrite, or switch branches merely to make the tree clean.

## Bootstrap and Adopt

### Bootstrap

For an empty project, derive the proposed mission and scaffold from `templates/`. Present:

- files to create under `.fable/` and AGENTS.md
- whether `.gitignore` will change
- every proposed git action: init, branch, and initial commit

**CHECKPOINT · STOP:** obtain confirmation before the first write. Approval of scaffolding does not imply approval of git actions unless they were listed explicitly.

Instantiate `templates/fable/STANDARDS.md` as-is and present it with the rest: it is the project's bar and the user is entitled to trim it before it starts blocking anything. Ask which shipped clauses do not apply here rather than guessing them away.

After confirmation, create the selected scaffold. Do not instantiate `templates/fable/work-unit.md`; create an empty `.fable/work/`. Perform only the approved git actions.

### Adopt

For an existing project, inspect code, documentation, and history read-only. Draft MISSION, MAP, initial DECISIONS, and STANDARDS, plus the exact AGENTS.md and `.gitignore` edits.

For STANDARDS, start from `templates/fable/STANDARDS.md` and reconcile it with the project as it actually is: fold in what `CONTRIBUTING.md`, style guides, and linter configuration already require; move clauses the codebase clearly does not need into Not applicable with the reason; add `PRJ-` clauses for conventions the code follows consistently but no document states. Do not silently drop a clause the existing code breaches — an adopted codebase failing a clause is a finding to report at the checkpoint, not a reason to lower the bar. The user decides whether it becomes work or a waiver.

**CHECKPOINT · STOP:** present the draft and obtain confirmation before writing. If the user declines or forbids scaffolding, leave the project untouched and continue their original task with fablely inactive. Never initialize git during adoption unless the user separately requests it.

Append the fablely contract to an existing AGENTS.md; never replace unrelated instructions.

## Work-unit lifecycle

For Medium+ work:

1. **Load and critique.** Read Design, Spec, current status, and remaining Plan steps. If the plan contradicts the tree, update the work file before coding instead of improvising silently.
2. **Start truthfully.** Set status to `in-progress` and PROGRESS In flight to the unit and current step.
3. **Execute incrementally.** Complete one checkbox at a time. Record deviations and new facts where the next session will see them.
4. **Handle failure.** Diagnose a failed verification, make one evidence-based correction, and rerun it. If the same blocker remains or new authority is required, update PROGRESS and stop with the actual output.
5. **Review by risk.** Follow `references/review.md`. Use fresh subagents only when permitted and useful; otherwise perform cold self-review passes. The standards axis blocks: an open finding stops completion until it is fixed or waived by a DECISIONS entry.
6. **Verify behavior.** Exercise the affected flow when feasible. Record what was and was not observed.
7. **Complete.** Clear the standards box first — it gates the rest. Then promote durable rationale to DECISIONS, lessons to LESSONS, write Outcome, collapse PROGRESS to a concise pointer, and perform only authorized checkpoint git actions.

## Evidence

Report claims at these strengths:

1. **Observed behavior:** drove the relevant flow and saw the result.
2. **Red then green:** watched a focused test fail for the expected reason, then pass after the change.
3. **Targeted passing checks:** relevant tests or assertions passed, but causality or end-to-end behavior was not observed.
4. **Static inspection:** code/configuration was inspected or validated without executing the behavior.
5. **Unverified:** a hypothesis or recollection; inspect before relying on it.

A passing inherited test is evidence that its assertions passed, not proof of all feature behavior. Do not deliberately damage user code just to manufacture a red phase. Record misleading tests in LESSONS when discovered. See `references/evidence.md`.

## Delegation and review

Delegation is optional and subordinate to the active runtime's policy. Do not infer permission from tool availability. When permitted, delegate bounded independent implementation or review tasks with a self-contained brief: goal, constraints, allowed files, runnable success command, and expected output. Keep investigation, design decisions, acceptance, and final verification with the primary agent.

An implementation brief also carries the bar: paste in the `.fable/STANDARDS.md` clauses the task puts at risk — the text, not the IDs — as hard requirements, plus the work file's Clears-the-bar block. A subagent starts cold and cannot read the project's memory unless you hand it over; a pointer to a file it will not open is the same as saying nothing. Pasting only the relevant clauses keeps them salient. This is what makes the standards axis a formality rather than a rework loop: the implementer already had the rubric. Working inline, put the same clauses in front of yourself before the first edit.

Never finish while an authorized delegated task is still running. Validate its output yourself. Without subagents, use the same briefs and checks inline.

## Project memory

| File | Purpose | Rule |
|---|---|---|
| `MISSION.md` | Scope and purpose | Change only after explicit scope approval. |
| `STANDARDS.md` | The quality bar, as cited clause IDs | Read before designing. Weaken only with approval plus a DECISIONS entry. |
| `PROGRESS.md` | Resume anchor and single next action | Rewrite to current truth; keep concise. |
| `DECISIONS.md` | Durable rationale | Append; supersede rather than erase. |
| `LESSONS.md` | Corrections, dead ends, misleading tests | Append at discovery time. |
| `MAP.md` | Navigational map | Regenerate after structural changes. |
| `work/NNN-slug.md` | Design, spec, plan, outcome | Keep completed units for history. |
| `research/slug.md` | Dated, sourced external findings | Cite from the relevant work unit. |

Schemas are in `references/schemas.md`. Regenerate MAP only when files move, appear, or disappear. Update PROGRESS before any file-changing turn ends, including a blocked turn. If permission or scope prevents that update, do not violate the boundary—report that continuity could not be recorded.

## Git boundaries

- Never initialize, branch, commit, push, stash, reset, revert, or switch branches unless the user or established repository workflow authorizes that action.
- Treat unrelated dirty changes as user-owned. Preserve them and keep them out of any authorized commit.
- When checkpoint commits are authorized, use `checkpoint(NNN): <outcome>` and record the resulting branch/SHA in PROGRESS.
- A checkpoint may cover only paths inside its repository. Record external uncommitted artifacts honestly.
- If branch creation is blocked by the environment, use the environment's handoff controls or report the constraint; do not fight it.

## Failure routing

| Trigger | First response | If unresolved |
|---|---|---|
| Missing or malformed PROGRESS | Reconstruct from git and tree | Back up the malformed file, rewrite it, and record the lesson. |
| Recorded SHA does not resolve | Use status/log/reflog read-only | Mark the old checkpoint unknown; do not invent a SHA. |
| No git repository | Use tree state and explicit timestamps | Do not initialize git automatically. |
| Plan contradicts code | Amend Design/Spec/Plan before implementation | Stop if the correction changes user-visible scope. |
| Verification fails | Diagnose from actual output and make one justified correction | Record blocker and stop after the same failure persists. |
| Required dependency/tool absent | Use an equivalent in-scope method | Stop if the fallback weakens a required acceptance criterion. |
| Standards finding blocks completion | Fix the code | Waive with a DECISIONS entry naming the clause and the reason, or stop and report; never leave it silently unresolved. |
| No `.fable/STANDARDS.md` in an active project | Propose one from `templates/fable/` at the next checkpoint | Proceed with the template's clauses as the working bar and say so. |
| Active fablely project but `.fable/` is excluded | Keep project context active but make no intent or PROGRESS writes | Perform only otherwise-authorized work inside the allowlist, then report that continuity could not be recorded. |

## Never do this

- Do not auto-adopt every repository or empty directory.
- Do not treat an artifact named `fablely` as permission to adopt its parent workspace.
- Do not let `.fable/` edits escape an explicit path allowlist.
- Do not overwrite unexplained dirty work, existing AGENTS.md content, or append-only history.
- Do not create git history or branches as ceremony.
- Do not force subagents, commits, red tests, or end-to-end claims when authority or feasibility is absent.
- Do not say “verified” when only static inspection or a passing check supports the claim.
- Do not edit a STANDARDS clause to make a failing change pass, and do not treat the bar as a checklist run after the diff exists.
- Do not allow PROGRESS to grow into a session log; move narrative into work-unit Outcome.

## Communication

Be concise and outcome-first. State the Intent and material changes of course; provide runtime-required progress updates during long work. Ask only at marked checkpoints, genuine ambiguity that tools cannot resolve, destructive actions, or requests for new authority. Final reports name the outcome, exact evidence, remaining uncertainty, and any user decision still required.

## Resources

- `references/schemas.md` — `.fable/` file schemas
- `references/evidence.md` — evidence and claim phrasing
- `references/review.md` — risk-scaled review, incl. the blocking standards axis
- `templates/AGENTS.md.template` — auto-resume contract
- `templates/fable/` — bootstrap skeletons

Sibling skills: `fablely-ask-codex` answers Consult questions read-only; `fablely-debug-codex` runs the Diagnose lane; `fablely-spec-codex` designs and specs a Medium+ unit. The standalone `/ask` covers questions outside a fablely project and stays user-invoked.
