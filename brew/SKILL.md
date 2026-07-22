---
name: brew
description: Write a new agent skill, or brew an existing one down to the fewest tokens that hold the same behaviour. Use when the user asks to create, draft, or design a skill — or to audit, review, compress, or cut the token cost of a SKILL.md.
---

Goal: **predictability** — the agent takes the same _process_ every run, not produces the same output. Brew to the fewest tokens that hold that process.

Write agent-first: the reader parses, it is not persuaded. **Bold terms** and the rationale behind the passes live in [`REFERENCE.md`](REFERENCE.md) — read it when a check fires and you are unsure how to apply it, or when the user reports the skill _misbehaving_ rather than long (failure-mode table).

## Branches

- **write** — a new skill. Run every step.
- **brew** — an existing skill. Read it, start at step 4. If its layout fights the hierarchy, rebuild from zero rather than compress in place.

## 1. Frame

One sentence on what it does, one on when it fires. Skip if the user gave both.

## 2. Choose invocation

- Model-invoked (keep `description`) only if the agent or another skill must reach it unprompted — that description sits in the context window every turn.
- Otherwise `disable-model-invocation: true`, description cut to a human-facing one-liner. Costs nothing.

## 3. Set degrees of freedom

Decide before writing; it decides where the tokens go.

| Task | Shape |
|---|---|
| Many valid approaches, context-dependent | Direction only — no procedure |
| A preferred pattern, some variation fine | Template with parameters |
| One sequence, errors are costly | Numbered steps, each ending on a checkable **completion criterion** |

## 4. Draft long, then brew

Write the skill out fully — you cannot compress what you have not said. Then run the passes **in order**; each is safer than the one after it.

1. **Delete, don't rewrite.** Run the **no-op** test on every sentence _in isolation_: does it change behaviour versus the model's default? Delete whole failing sentences instead of trimming words out of them. Governs sentences, not structure — rebuilding the layout is free.
2. **Cut what the reader already has.** The model holds domain background, common formats and tools, justifications of standard practice. The agent-reader needs no rationale, motivation, transitions or narrative. Keep the non-default: your conventions, your ordering, your constraints.
3. **Fold duplicates.** One meaning, one **single source of truth**.
4. **Collapse into leading words.** A triad restating one quality ("fast, deterministic, low-overhead" → _tight_), or a sentence gesturing at one idea, collapses into a single pretrained token carrying the same behaviour. Prefer a word the model already holds; a coined one costs the definition tokens it saves.
5. **Push down, don't delete.** Material only _some_ branches need moves behind a context pointer, one level deep from SKILL.md — never a chain of files. Table of contents on any disclosed file past 100 lines. What every branch needs stays inline.
6. **Hold one notation.** Prose in Markdown. Reserve XML tags for blocks the agent must treat verbatim.
7. **Stop at the floor.** Restore a cut when the agent starts asking the user something the skill used to answer, or when two runs take different paths through one branch. Restore a concrete example before prose.
8. **Tighten the surviving prose.** Last — the only pass that rewrites. Moves, with examples in [`REFERENCE.md`](REFERENCE.md#prose-edits): bullet by default, keeping a sentence only where its connective logic (_because / unless / then_) carries behaviour; delete qualifiers and implied modifiers; unwind preposition chains by rewriting the sentence whole; flip negatives positive; put the doer in front of the verb. Re-run the no-op test on everything you touched; restore the original wherever the rewrite moved behaviour, not word count.

Budget: SKILL.md ≤1000 tokens (~650 words); 500 lines is the ceiling, not the target. Over budget with pass 7's floor holding → split or disclose, never shave. Report before → after tokens and percentage cut.

## 5. Deliver

Write to the path the user gave, or show inline if they gave none.

**Completion criterion:** frontmatter valid; every sentence passed the no-op test in isolation, including pass 8's rewrites; no meaning appears twice; every step ends on a bound the agent can check; one notation throughout; SKILL.md ≤1000 tokens, or the overage justified by the floor; token delta reported. The brew branch also reports each cut as `line N — <pass> — <what went>` for individual veto; a from-zero rebuild reports behaviour delta instead — what the old skill did that the new one does not.
