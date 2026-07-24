---
name: fablely-spec
description: Design and spec Medium+ work in a fablely project when the solution shape is open or hard to undo, no covering `.fable/work/` file exists, or the user explicitly asks to grill/spec the work.
---

# fablely-spec

Turn one fuzzy unit into one agreed `.fable/work/NNN-slug.md` containing Design, Spec, Clears the bar, and Plan. Grill; never implement. The artifact is authoritative only after the user confirms it.

## 1. Scale by risk

- **Return to Small:** if the shape settles before a second question, hand it back to fablely triage; write no work file.
- **Light:** contained, reversible, one plausible shape. Propose the whole design once. File: Design ≤3 lines plus rejected alternative; behavioral Spec; one Clears-the-bar row or `none at risk`; flat checkbox Plan. No Task/Interfaces or per-step run/expect blocks.
- **Full:** data-loss, auth/security, public API, hard-to-revert, or several plausible shapes. Run the full interrogation and output contract.

If confirmation is unavailable, write `status: specced` and stop. Silence never authorizes implementation.

**Completion criterion:** chosen form matches blast radius, reversibility, and remaining design freedom.

## 2. Settle the design

Ask one question at a time; recommend an answer. Resolve dependent decisions branch by branch. Inspect the codebase instead of asking questions it can answer. Continue while new branches appear.

Settle:

- solution shape, constraints, alternatives, and why they lost
- exact observable behavior and edge cases
- a manual behavioral done criterion
- bite-sized implementation order

Read `.fable/STANDARDS.md` before proposing the shape. For every clause at risk, grill a **Clears the bar** row containing: clause ID, how the design satisfies it, and how a reviewer checks that from the diff. Auth, input, stored data, errors, and public interfaces rarely justify `none at risk`. If no acceptable shape clears a clause, change the design or obtain a waiver recorded in DECISIONS; never defer the conflict to review.

**Completion criterion:** no open design branch; behavior is falsifiable; each at-risk clause has a diff-checkable answer.

## 3. Research only what the tree cannot answer

Use primary sources for external facts. Delegate only when permitted and available; otherwise research inline and do not imply an agent ran. Keep unconfirmed research read-only. Persist `.fable/research/<slug>.md` only after design confirmation or explicit artifact authority, preceded by `unit: NNN <slug>`; follow the fablely schema and cite the file from Design rather than duplicating it.

## 4. Write the work file

Choose the next unused zero-padded number from `.fable/work/`. Follow `../fablely/references/schemas.md` exactly. Full form, in order:

1. `status: specced`, creation date, number
2. **Design:** chosen shape and rejected alternatives
3. **Spec:** observable behavior, edge cases, behavioral done criterion—not merely tests/build
4. **Clears the bar:** at-risk clauses, satisfaction, diff check
5. **Plan:** risk-scaled, test-first, independently checkable steps

Use `references/plan-format.md` as the Plan source of truth: exact paths, interfaces, input→result cases, commands, and expected output; contracts by default, literal code only when a costly wrong guess is plausible. Keep Design, Spec, and Plan in this one file. Plans live nowhere else.

Run plan-format's self-review, show the complete file, and obtain confirmation. Do not implement. After confirmation, return execution to fablely's work-unit lifecycle.

**Completion criterion:** one confirmed work file; schema exact; every Spec line and bar clause maps to a Plan step; no placeholders or unsupported code transcript; no edits outside authorized spec/research artifacts.
