---
name: fablely-spec
description: Use when a project with a .fable/ directory needs a unit of work designed and specced — a non-trivial request with no covering file in .fable/work/ — or when the user asks to grill or spec a piece of work with /fablely-spec.
---

# fablely-spec

## Overview

One job: turn a fuzzy unit of work into one settled file, `.fable/work/NNN-slug.md`, holding the design, the spec, and the implementation plan together. You grill; you do not execute.

You're invoked automatically by fablely's triage when a Medium+ request has no covering work file, or directly by the user via `/fablely-spec`. Either way, the work isn't real until it's written down and agreed to — not before.

## Scale the artifact to the risk

Judge risk by observable properties — blast radius, reversibility, how much design is genuinely open. Both the grilling **and the file it produces** scale:

- **Hand it back.** If the design settles before you have asked a second question, this was never Medium+. Say so and return it to fablely's triage as Small. You are not obliged to produce a file for every request that reaches you, and a work file for a settled change is pure ceremony.
- **Light** (contained, revertible, one plausible shape): propose the complete design in a single message and ask the user to correct it. One round-trip if it lands, then the light file: Design ≤ 3 lines naming the alternative you rejected; Spec = the behavioral done criterion; one Clears-the-bar row or `none at risk`; Plan = a flat checkbox list. No Task headers, no Interfaces blocks, no per-step run/expect pairs.
- **Full** (data loss possible, auth/security surface, public API, hard to revert, several plausible shapes): run the interrogation loop below and the full Output contract. This is where the friction pays for itself.

Either way, the work isn't real until the file is written and confirmed. If the user cannot confirm — a non-interactive run, an autonomous session — write the file, mark it `status: specced`, and stop there with the file as your report. Implementing an unconfirmed spec is self-approval, and "the user wasn't available" doesn't convert silence into a yes.

## The interrogation loop

Interview the user relentlessly about every aspect of the work until you reach shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one by one before moving to the next branch.

- Ask questions one at a time, waiting for the answer before continuing — the user can't hold five open decisions in their head while answering the first one.
- For every question, offer your recommended answer. Give the user something to react to or override, not a blank page.
- If the codebase can answer a question, explore the codebase instead of asking.
- Do not write the work file until the user confirms shared understanding. If you're still surfacing new branches of the design tree, keep interrogating.

Cover, at minimum: what shape the solution takes and what alternatives were rejected and why; exact observable behavior including edge cases; what "done" looks like when someone drives the flow by hand; and the sequence of bite-sized steps that gets there.

## Clearing the bar is part of the design

Read `.fable/STANDARDS.md` before you propose a shape — it is a design input, not a checklist run against the finished spec. A design that ignores the bar until review has already picked the shape that will fail it.

Every work file carries a **Clears the bar** block: for each clause the unit puts at risk, the ID, how the design satisfies it, and how a reviewer will check that from the diff alone. Then grill the block like any other part of the design, before the file is accepted:

- Which clauses does this actually put at risk? Anything touching input, auth, stored data, error paths, or a public interface almost certainly touches one. A block claiming "none at risk" on that kind of work is the first thing to push on.
- "How a reviewer checks" has to be checkable from the diff. "Handled correctly" is not an answer; "the parse happens in `handler.parse_request`, so no unvalidated field reaches the service layer" is.
- If a clause can't be satisfied by any shape you both like, that is a design finding, not a review finding. Resolve it here — change the shape, or agree the clause is waived and record it in `DECISIONS.md` naming the clause. Deferring it to review means discovering it after the code exists, which is the expensive time to discover it.

This block is what the standards reviewer is tested against later, and it is what gets pasted into an implementation brief. A vague block produces vague implementation and an unreviewable diff.

## Research

When a design question turns on facts outside the tree — library behavior, API contracts, prior art — dispatch a background research agent rather than guessing or stalling the interrogation. If delegation is unavailable or forbidden, investigate inline against the same primary-source standard and continue the interrogation; do not imply a background agent ran.

Research stays read-only during unconfirmed design work. Persist findings to `.fable/research/<slug>.md` only after the design is confirmed or the user explicitly authorizes a persistent research artifact; before that first write, satisfy fablely's intent rule with `unit: NNN <slug>`. Use one file per investigation, cite every claim's primary source, follow fablely's `references/schemas.md`, and cite the file from the work unit's Design section instead of restating it. If the codebase can answer the question, read the codebase — research is for facts that live outside the tree.

## Output contract

The file is `.fable/work/NNN-slug.md`, where `NNN` is the next unused number (zero-padded, starting at `001`) and `slug` is a short kebab-case name for the unit of work. Check `.fable/work/` for the highest existing number before assigning the next one.

In full form it contains, in order (light form collapses 2–5 as above):

1. **Status header** — `status: specced`, the date created, and the work unit number.
2. **Design** — the shape you chose, and the alternatives you considered along with why they lost. This is the "why" that keeps the spec from drifting into something nobody remembers agreeing to.
3. **Spec** — exact observable behavior, edge cases, and done criteria. The done criterion is behavioral: drive the affected flow and observe the result — not "tests pass" or "code compiles."
4. **Clears the bar** — the `STANDARDS.md` clauses at risk, how the design satisfies each, and how a reviewer checks it from the diff.
5. **Plan** — bite-sized, independently checkable steps with test-first ordering, exact paths, exact interfaces, exact commands, and expected output. Depth is risk-scaled: contracts by default (paths, signatures, input → expected behavior, no full code bodies), literal inline code only where a competent executor could plausibly guess wrong and the mistake is expensive — the full rule is in `references/plan-format.md` and it is not optional.

Design, spec, and plan live in one file deliberately — split across files they drift into contradicting each other the first time either one gets edited alone.

The full schema is in the fablely skill's `references/schemas.md`. Follow it exactly; this document describes the shape, that file is the source of truth for field names and formatting.

## Handoff

Once the file is written and the user has confirmed it, your job is done. Execution belongs to the fablely skill's work unit lifecycle — load-and-critique, step-by-step execution, review against the Spec and the standards bar, then the checkpoint commit: one per completed work unit, tests green, standards axis clear, never on the default branch, never pushed.

You do not implement anything yourself. If you find your hands moving toward an edit while specced work is still open, stop — that's the execution phase's job, not yours.

## One home for plans

Plans live in `.fable/work/`, nowhere else. Do not reach for any other plan-writing skill or write plans to any other location — two plan locations is how a project ends up with contradictory plans a few directories apart, each claiming to be current. Everything needed to write a fablely plan is in this skill and `references/plan-format.md`.
