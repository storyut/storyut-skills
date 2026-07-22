# Review — work unit lifecycle step 4

Before claiming a work unit done, review its diff along three axes: spec mapping, the project's standards bar, and code smell. Fresh eyes are valuable, but subagents are optional and permission-bound.

**The diff:** with git, use the recorded checkpoint and include authorized staged, unstaged, and external-path changes. Confirm the ref resolves. Without git, compare against the pre-change snapshot. An empty or incomplete diff blocks review.

## Which shape to dispatch

- **Contained Medium:** one cold main-agent pass covering all three axes. If permitted and useful, one isolated reviewer receives the Spec, `.fable/STANDARDS.md`, the Clears-the-bar block, the smell baseline, and the diff, and reports each axis separately.
- **Large or risky:** independent passes. If permitted, use parallel Claude Code subagents, each receiving only its axis inputs — the standards axis always gets its own reviewer here, since it is the one axis with blocking power. Otherwise perform sequential cold passes.

## Spec axis

The reviewer sees: the work file's **Spec section only**, plus the diff.

Brief: map every spec line to the code that implements it, and every hunk back to a spec line — anything unmapped in either direction is a finding. Report (a) spec requirements missing or partial; (b) behaviour the spec didn't ask for (scope creep); (c) requirements that look implemented but wrong. Quote the spec line for each finding. Under 400 words.

## Standards axis — the one with teeth

The reviewer sees: `.fable/STANDARDS.md` **pasted in full**, the work file's **Clears the bar block only** (not the Design, not the Plan — the block is the claim under test), and the diff. Add whatever else the repo documents about how code should be written (`CONTRIBUTING.md`, style guides) when it exists.

Brief: for every clause the Clears-the-bar block claims to satisfy, check the diff actually satisfies it and say how you checked. Then sweep the diff for breaches of clauses the block never mentioned — an unclaimed clause is the likelier place to find one. Report each finding as: clause ID, the hunk quoted, and what specifically breaches it. A clause you cannot check from the diff alone is reported as unverifiable, not as passing. Skip anything tooling already enforces. Under 400 words.

**This axis has veto power.** An open standards finding blocks the work unit: status does not flip to `done`, the Completion standards box stays unchecked, and no authorized checkpoint commit happens. Two ways to clear it — fix the code, or record a `DECISIONS.md` entry naming the clause, why it does not apply here, and what was chosen instead. A waiver is a decision that gets written down and read later; it is not a note in the conversation, and "the reviewer was being pedantic" is not a waiver.

Triaging a standards finding as wrong is legitimate — reviewers err, and a finding that misreads the code is not a breach. Say why in the work file's Outcome. What is never legitimate is leaving a finding you agree with unresolved and unwaived because the unit is otherwise finished.

## Smell axis

The reviewer sees: the smell baseline below **pasted in full** — the subagent has no other access to it — plus the diff.

Brief: report any baseline smell, named, with the hunk quoted. Baseline smells are always judgement calls; a documented repo standard or a `STANDARDS.md` clause overrides the baseline where they disagree. Under 400 words. Findings here inform the work; unlike the standards axis, they do not block it.

For a combined review, fold the briefs into one message while keeping findings separated by axis. A Claude Code subagent starts cold; include every required input rather than relying on conversation context.

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

Report the three axes separately, never merged or reranked: code can clear every standard while implementing the wrong thing, and implement exactly the spec while breaching every clause in the bar — merging lets one axis mask the other. Triage findings on merit (a reviewer can be wrong too), fix what's real. Standards findings must reach fixed-or-waived before completion; spec and smell findings are fixed on merit.

Then run the done criterion yourself: drive the flow, observe the behaviour.
