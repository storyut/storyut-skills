---
name: brew
description: Write a new agent skill, brew an existing one down to the fewest tokens that hold its behaviour, or patch a skill from an observed failed run. Use when the user asks to create, draft, design, audit, compress, repair, or learn from a misbehaving skill.
---

Goal: **predictability** — the same process each run, not the same output. Keep the fewest tokens that hold it.

Write agent-first: the reader parses, it is not persuaded. [`REFERENCE.md`](REFERENCE.md) defines **bold terms** and the passes' rationale; read it when a check is unclear or the skill misbehaves rather than runs long.

## Branches

- **write** — a new skill. Run every step.
- **brew** — an existing skill. Read it, start at step 4. If its layout fights the hierarchy, rebuild from zero rather than compress in place.
- **patch** (`--patch`) — repair an existing skill from session evidence. Read and run [`PATCH.md`](PATCH.md); run step 4 afterward only when the patch creates duplication or the user also requests compression.

## 1. Frame

One sentence on what it does, one on when it fires. Skip if the user gave both.

## 2. Choose invocation

- Model-invoked: keep `description` only when the agent or another skill must reach it unprompted. It loads every turn.
- User-invoked: set `disable-model-invocation: true` and use a human-facing one-line description. It has zero context load.

## 3. Set degrees of freedom

Choose before writing; this allocates the tokens.

| Task | Shape |
|---|---|
| Many valid approaches, context-dependent | Direction only — no procedure |
| A preferred pattern, some variation fine | Template with parameters |
| One sequence, errors are costly | Numbered steps, each ending on a checkable **completion criterion** |

## 4. Draft long, then brew

Write the skill fully, then run these passes **in order** from safest to riskiest.

1. **Delete, don't rewrite.** Apply the **no-op** test to each sentence alone: does it change behaviour versus the model default? Delete failures whole. Rebuild structure freely.
2. **Cut what the reader already has.** Delete domain background, common formats and tools, standard-practice rationale, motivation, transitions, and narrative. Keep non-default conventions, order, and constraints.
3. **Fold duplicates.** One meaning, one **single source of truth**.
4. **Collapse into leading words.** Replace restatements of one quality with one pretrained token carrying that behaviour (`fast, deterministic, low-overhead` → _tight_). A coined word costs the definition it saves.
5. **Push down, don't delete.** Move branch-specific material behind a context pointer, one file deep. Keep shared material inline. Add a table of contents when a disclosed file exceeds 100 lines.
6. **Hold one notation.** Prose in Markdown. Reserve XML tags for blocks the agent must treat verbatim.
7. **Stop at the floor.** Restore a cut when the agent asks what the skill used to answer or two runs diverge within one branch. Restore a concrete example before prose.
8. **Tighten surviving prose.** Last, apply the [`prose edits`](REFERENCE.md#prose-edits): bullets unless connective logic carries behaviour; delete qualifiers and implied modifiers; unwind preposition chains; flip negatives positive; put the doer first. Re-run the no-op test; restore wording when behaviour moved.

Budget: SKILL.md ≤1000 tokens (~650 words); 500 lines is a ceiling. If pass 7 holds above budget, split or disclose. Report before → after tokens and percentage cut.

## 5. Deliver

Write to the path the user gave, or show inline if they gave none.

**Completion criterion:** valid frontmatter; every sentence passes the no-op test alone; no duplicated meaning; each step ends on a checkable bound; one notation; SKILL.md ≤1000 tokens or pass 7 justifies the overage; token delta reported. Brew also reports each cut as `line N — <pass> — <what went>` for veto. A from-zero rebuild instead reports what the old skill did that the new one does not.
