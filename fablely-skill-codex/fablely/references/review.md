# Review — work unit lifecycle step 4

Before claiming a work unit done, review the unit's diff along three axes: does it satisfy the spec, does it clear the project's standards bar, and is it well-shaped code. Only the standards axis can block. Fresh eyes are the point: the reviewer — subagent or your own cold pass — sees only the axis's inputs, never your conversation or your reasoning; self-review inherits your blind spots.

**The diff:** when git is available, use the recorded checkpoint SHA and confirm it resolves before reviewing. Include authorized staged, unstaged, and external-path changes. In a non-git project, compare against the pre-change snapshot. An empty or incomplete diff is a blocker to review, not evidence of no change.

## Scale by risk

Judge risk the way `fablely-spec` scales its own grilling: data loss possible, auth/security surface, public API, hard to revert, or several plausible shapes → large/risky, the full treatment below. Otherwise → contained Medium, the scoped treatment.

**Contained Medium unit:** one fresh-eyes review covering all three axes in a single brief — spec↔diff mapping, `STANDARDS.md` clauses, and the smell baseline below. **With permitted subagents:** dispatch one reviewer briefed with every axis's inputs. **Without:** run one cold self-review pass, re-reading the inputs cold, with the same mapping discipline. Report the axes separately under Aggregate.

**Large or risky unit:** each axis gets its own pass. **With permitted subagents:** dispatch them in parallel, each briefed only with its inputs below; the standards axis always gets its own reviewer here, since it is the axis with blocking power. **Without:** run the passes sequentially — Spec, then Standards, then Smell — and do not let one pass steer the next.

## Spec axis

Inputs: the work file's **Spec section only**, plus the diff.

Brief: map every spec line to the code that implements it, and every hunk back to a spec line — anything unmapped in either direction is a finding. Report (a) spec requirements missing or partial; (b) behaviour the spec didn't ask for (scope creep); (c) requirements that look implemented but wrong. Quote the spec line for each finding. Under 400 words.

## Standards axis — the one with teeth

Inputs: `.fable/STANDARDS.md` (pasted in full when briefing a subagent — it has no other access to it), the work file's **Clears the bar block only** — not the Design, not the Plan, since the block is the claim under test — and the diff. Add whatever else the repo documents about how code should be written (`CONTRIBUTING.md`, style guides) when it exists.

Brief: for every clause the Clears-the-bar block claims to satisfy, check the diff actually satisfies it and say how you checked. Then sweep the diff for breaches of clauses the block never mentioned — an unclaimed clause is the likelier place to find one. Report each finding as: clause ID, the hunk quoted, what specifically breaches it. A clause you cannot check from the diff alone is reported as unverifiable, not as passing. Skip anything tooling already enforces. Under 400 words.

**This axis blocks.** An open standards finding stops the unit: status does not flip to `done`, the Completion standards box stays unchecked, and no authorized checkpoint commit happens. Two ways to clear it — fix the code, or record a `DECISIONS.md` entry naming the clause, why it does not apply here, and what was chosen instead. A waiver is a written decision someone reads later; a note in the conversation is not one, and "the reviewer was being pedantic" is not a waiver.

Triaging a finding as wrong is legitimate — reviewers err, and a finding that misreads the code is not a breach; say why in the Outcome. What is never legitimate is leaving a finding you agree with unresolved and unwaived because the unit is otherwise finished.

## Smell axis

Inputs: the smell baseline below (pasted in full when briefing a subagent), plus the diff.

Brief: report any baseline smell, named, with the hunk quoted. Baseline smells are always judgement calls; a documented repo standard or a `STANDARDS.md` clause overrides the baseline where they disagree. Under 400 words. These findings inform the work; unlike the standards axis, they do not block it.

### Smell baseline (Fowler, *Refactoring* ch.3) — what it is → the fix

- **Mysterious Name** — a name that doesn't reveal what it does or holds → rename; if no honest name comes, the design's murky.
- **Duplicated Code** — the same logic shape in more than one hunk or file → extract the shared shape, call it from both.
- **Feature Envy** — a method reaching into another object's data more than its own → move it onto the data it envies.
- **Data Clumps** — the same few fields/params travelling together → bundle them into one type, pass that.
- **Primitive Obsession** — a primitive standing in for a domain concept → give the concept its own small type.
- **Repeated Switches** — the same `switch`/`if`-cascade on the same type recurring → polymorphism, or one map both sites share.
- **Shotgun Surgery** — one logical change forcing scattered edits across many files → gather what changes together into one module.
- **Divergent Change** — one module edited for several unrelated reasons → split so each changes for one reason.
- **Speculative Generality** — abstraction for needs the spec doesn't have → delete it; inline until a real need shows.
- **Message Chains** — long `a.b().c().d()` navigation the caller shouldn't depend on → hide the walk behind one method.
- **Middle Man** — a thing that mostly delegates onward → cut it, call the real target direct.
- **Refused Bequest** — an implementer ignoring most of what it inherits → drop the inheritance, use composition.

## Aggregate

Report the axes separately, never merged or reranked: code can clear every clause while implementing the wrong thing, and implement exactly the spec while breaching every clause in the bar — merging lets one axis mask the other. Triage findings on merit (a reviewer can be wrong too), fix what's real. Standards findings must reach fixed-or-waived before completion; spec and smell findings are fixed on merit.

Then run the done criterion yourself: drive the flow, observe the behaviour.
