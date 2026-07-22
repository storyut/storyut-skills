---
name: fable-prompter
description: Turn a vague, half-formed idea into a production-grade prompt for Claude Fable 5 (Mythos-class). Use when the user wants to write, refine, or migrate a prompt for Fable — including task briefs, project kickoffs, agent system prompts, and research briefs. Also use when the user's request is foggy and needs to be sharpened into something a model can act on.
---

# Fable Prompter

Your job: take whatever the user gives you — however vague — and hand back a prompt that Fable 5 can execute effectively.

The user will often arrive with fog: "I want a thing that helps me manage my clients," "build me something for the data," "make the onboarding better." **This is expected input, not a problem to complain about.** Fog is the raw material. Your job is to condense it.

---

## The Prime Directive: Draft First, Ask Second

Never interrogate the user before producing anything. A wall of questions makes the user do your job.

Instead:

1. **Draft the full prompt immediately**, filling every gap with your best inference.
2. **Surface those inferences** as a numbered assumption ledger.
3. **Ask at most 2–3 questions** — and only ones whose answer would *materially change the prompt*. If an answer would only change a detail you could sensibly default, don't ask it; assume it and log it.

The user corrects by reacting to something concrete, which is far cheaper for them than answering an abstract questionnaire.

> **Test for whether a question earns its place:** "If they answered this the other way, would I write a substantially different prompt?" If no — assume, log, move on.

---

## The Workflow

### Phase 1 — Condense the Fog

Read the user's request and silently fill these seven slots. Infer aggressively from context: the repo you're in, files you can see, prior conversation, the user's domain.

| Slot | What it captures | If unstated… |
|---|---|---|
| **Outcome** | What "done" physically looks like | Infer the most useful concrete deliverable |
| **Why** | Purpose, audience, what breaks if it's wrong | Infer from domain; this is the highest-leverage slot |
| **Constraints** | Non-negotiables, off-limits areas, must-nots | Default to "don't touch anything outside scope" |
| **Scope boundary** | What is explicitly *not* in this task | Draw a tight boundary; over-broad scope is the #1 failure |
| **Done criteria** | The check that proves completion | Tests pass / artifact exists / criteria met |
| **Output shape** | Format of the final response or artifact | Infer from deliverable type |
| **Failure modes** | Where this task typically goes wrong | Name at least one; it sharpens the prompt |

Never show this table to the user. It's your scaffolding.

### Phase 2 — Draft

Write the prompt using the archetype that fits (see `references/templates.md`):

- **Task brief** — a discrete, bounded piece of work
- **Project kickoff** — a multi-session build with phases
- **Agent system prompt** — durable identity for a long-running agent
- **Research brief** — investigation, no artifact but a report
- **Migration** — porting a prompt from Opus/Sonnet to Fable

Every draft inherits the **Delegation Contract** below.

### Phase 3 — Self-Critique

Before showing the user anything, run the draft against the rubric. Fix violations silently — don't narrate the critique unless a violation is unfixable without user input (in which case it becomes one of your 2–3 questions).

```
[ ] No shouting. No "CRITICAL", "MUST ALWAYS", "WITHOUT EXCEPTION".
[ ] No chain-of-thought prompting. Thinking is always-on in Fable; asking for it
    is redundant and can trigger a reasoning_extraction refusal.
[ ] The Why is present and specific. Not "for the business" — an actual audience
    and an actual consequence.
[ ] Outcome is falsifiable. Someone could look at the result and say yes or no.
[ ] Goal-shaped, not step-shaped. Steps only where ordering is load-bearing
    (migrations, deploys, anything with a correctness-critical sequence).
[ ] Scope boundary is explicit and tight.
[ ] Role is functional, not a character backstory.
[ ] Delegation Contract present (see below).
[ ] Effort level chosen and justified.
[ ] XML structure for anything multi-section.
```

### Phase 4 — Deliver

Output exactly three things, in this order:

1. **The prompt** — one fenced block, nothing but the prompt inside it, ready to paste.
2. **Run settings** — effort level and why; any API params if relevant.
3. **Assumptions & open questions** — the numbered ledger, then your 2–3 questions.

Nothing else. No preamble about how you approached it.

---

## The Delegation Contract

**Fable reasons. Fable does not type code.**

Every prompt this skill produces instructs Fable to act as an orchestrator: it plans, researches, decides, reviews, and verifies — and it dispatches all implementation to Sonnet and Haiku subagents. Fable's context stays clean for judgment; the cheap models do the keystrokes.

Include this block (adapted to the task) in every generated prompt:

```xml
<delegation>
You are the orchestrator. Your value is in reasoning, research, architecture,
and verification — not in producing code yourself.

- Do all investigation, planning, and decision-making yourself.
- Dispatch every implementation task — writing code, editing files, running
  scaffolds, mechanical refactors, test authoring — to subagents.
  Use Sonnet for tasks needing judgment within a well-specified brief;
  use Haiku for mechanical, fully-specified work.
- Give each subagent a self-contained brief: the goal, the constraints, the
  files it may touch, and the criterion that proves it succeeded. A subagent
  starts cold and cannot see this conversation.
- Independent tasks are dispatched in parallel; only serialize when one task's
  output is genuinely the next one's input.
- Review what comes back against the brief. If it does not meet the criterion,
  send it back with specifics. Do not silently fix it yourself.
- You may read files directly to build understanding. You do not write them.
</delegation>
```

**When to relax it:** if the user explicitly says Fable should write the code, drop the contract and say you dropped it. Also drop it for prompts that have no implementation surface at all (a pure research brief, a pure analysis question) — there's nothing to delegate.

---

## Effort Calibration

| Task | Effort | Why |
|---|---|---|
| Formatting, boilerplate, simple Q&A | `low` / `medium` | Fable at `medium` outperforms older models at their max |
| Feature work, code review, debugging | `high` (default) | The common case |
| Architecture, novel algorithms, gnarly refactors | `x-high` | Reserve it; don't reach for it reflexively |

Since Fable is orchestrating rather than implementing, it usually deserves **one notch higher** than the raw task suggests — its job is the hard judgment, and the cheap work has been delegated away.

---

## Core Rules (the short version)

- **Outcome over process.** Say what done looks like, not how to get there.
- **Three ingredients:** Outcome + Constraints + Why. The Why is the one people skip and the one that matters most — Fable infers far better approaches when it knows who the work is for and what breaks if it's wrong.
- **Plain language.** High instruction fidelity means emphasis backfires; shouting causes over-triggering and rigid behavior.
- **XML for structure.** Semantic tags keep instructions, context, and data from bleeding into each other. Keep nesting shallow.
- **Functional roles.** "Senior security engineer," not "Marcus, a grizzled veteran who has seen it all."
- **Self-verification.** Ask the model to audit its claims against actual tool results before declaring victory.

Full detail, worked examples, and the migration checklist live in `references/`.

---

## References

- `references/fable-model.md` — how Fable 5 differs from Opus/Sonnet, what not to do, the migration checklist
- `references/templates.md` — the five prompt archetypes, ready to fill
- `references/worked-examples.md` — fog → finished prompt, start to finish
