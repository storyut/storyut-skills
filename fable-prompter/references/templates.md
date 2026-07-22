# Prompt Archetypes

Five shapes. Pick the one that fits, fill it, delete sections that don't earn their place. A prompt with an empty `<examples>` block is worse than one without the block.

All of them assume the Delegation Contract from SKILL.md unless the task has no implementation surface.

---

## 1. Task Brief — a discrete, bounded piece of work

```xml
<role>
{Functional identity: domain + seniority. One sentence.}
</role>

<context>
{The codebase/system. The tech stack. What already exists. What the user has
already tried, if anything.}
</context>

<objective>
{What "done" looks like, stated as an outcome someone could verify by looking
at the result. Not a list of steps.}
</objective>

<why>
{Who this is for. What breaks or is lost if it's wrong. What "good" means to
the person who will use it.}
</why>

<constraints>
{Non-negotiables. Files/directories off limits. Libraries not to introduce.
Conventions to follow.}
</constraints>

<out_of_scope>
{What this task explicitly does NOT include. Prevents scope creep — the most
common failure mode of an autonomous run.}
</out_of_scope>

<delegation>
{The Delegation Contract — see SKILL.md}
</delegation>

<done_when>
{The specific check that proves completion. "All tests in X pass and Y renders
without console errors" — not "the feature works."}
</done_when>
```

---

## 2. Project Kickoff — a multi-session build

Adds phasing and a checkpoint discipline. The key move: Fable produces a plan and *stops*, so the user can correct course before any code exists.

```xml
<role>...</role>

<context>
{Project background. Current state — greenfield, or existing system being
extended. Stack. Team conventions. Deployment target.}
</context>

<objective>
{The end state of the whole project, not just phase one.}
</objective>

<why>
{The business/user reason. What success looks like six months out.}
</why>

<approach>
Work in phases. Before writing any code:

1. Investigate the current state and surface anything that contradicts the
   context above.
2. Produce a phased implementation plan — each phase independently shippable,
   with its own done-criterion.
3. Stop and present the plan. Wait for approval.

After approval, execute phase by phase. At each phase boundary, report what
landed and what you verified before continuing.
</approach>

<constraints>...</constraints>
<out_of_scope>...</out_of_scope>
<delegation>{Delegation Contract}</delegation>

<verification>
Before reporting any phase complete:
- Audit each claim against a tool result from this session.
- Only report work you can point to evidence for.
- If something is not verified, say so explicitly.
</verification>
```

---

## 3. Agent System Prompt — durable identity for a long-running agent

Goes in the system prompt, not the user turn. Holds identity and global rules; task-specific context belongs in the user message.

```xml
<role>
{Who the agent is, permanently. Its domain. Its standing responsibilities.}
</role>

<operating_principles>
{How it makes decisions when the user hasn't specified. Its defaults. What it
does when it's uncertain — ask, or assume and flag?}
</operating_principles>

<constraints>
{Standing boundaries that apply to every task this agent ever gets.}
</constraints>

<delegation>{Delegation Contract}</delegation>

<verification>{Self-audit standard}</verification>

<output_format>
{How it always communicates. Length. Structure. What it leads with.}
</output_format>
```

---

## 4. Research Brief — investigation, output is a report

No delegation contract needed if there's no implementation. But *do* delegate parallel search fan-out to subagents when the surface is wide.

```xml
<role>...</role>

<question>
{The actual question, sharply stated. Not a topic — a question with an answer.}
</question>

<why>
{What decision this research feeds. This determines depth: a go/no-go decision
needs different evidence than idle curiosity.}
</why>

<sources>
{Where to look. What counts as authoritative here. What to distrust.}
</sources>

<delegation>
Dispatch independent lines of investigation to subagents in parallel. Each gets
a self-contained question and returns findings, not raw dumps. You synthesize.
</delegation>

<output_format>
{Structure of the report. Lead with the answer. Evidence after. Explicitly
separate what you verified from what you inferred.}
</output_format>

<done_when>
The question is answered with cited evidence, or you have established that it
cannot be answered from available sources and said why.
</done_when>
```

---

## 5. Migration — porting an existing prompt to Fable

```xml
<role>
You are a prompt engineer migrating a prompt from {old model} to Claude Fable 5.
</role>

<context>
{Paste the original prompt. Note what it was for and any known failure modes —
where it under- or over-triggered on the old model.}
</context>

<objective>
Produce the Fable 5 version of this prompt, preserving intent while adapting to
Fable's higher instruction fidelity and always-on thinking.
</objective>

<constraints>
Apply the migration checklist in references/fable-model.md. Preserve every
behavior the original prompt actually depended on — do not trim a guardrail
without saying which one and why it is now redundant.
</constraints>

<output_format>
1. The migrated prompt, in one block.
2. A change log: what you removed, what you added, and why for each.
</output_format>
```

---

## Few-Shot Examples — when to bother

Include examples only when the task has non-obvious expectations. The most valuable example is rarely the happy path — it's the one that teaches the model *when to stop and ask*.

```xml
<examples>
<example>
<input>Refactor getUserById to handle soft-deleted users.</input>
<output>
Found it — `getUserById` in /src/services/user.ts doesn't filter on `deleted_at`.
Dispatched the fix to a Haiku subagent (single-predicate change, fully specified)
plus a regression test asserting a soft-deleted user returns null. Both landed;
the test fails against the old code and passes against the new.
</output>
</example>

<example>
<input>Refactor getUserById to use caching.</input>
<output>
Before I dispatch this I need the invalidation strategy — it determines the whole
design, and guessing wrong means throwing the work away.

1. Invalidate on user update, or is eventual consistency acceptable?
2. Expected TTL?
3. Redis, or in-memory?
</output>
</example>
</examples>
```

The first shows execution *through delegation*. The second shows the model refusing to proceed on an underspecified task — which is the behavior you actually want from an orchestrator, because it's the one whose mistakes are expensive.
