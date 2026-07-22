---
name: fablely-ask
description: "Answer a read-only question about a project that has a `.fable/` directory — how something works, why it is shaped that way, what the current state is, or what an external library actually does. Use for fablely's Consult lane: the answer is words, not edits. Do not use when the request is to change something, and do not use in a project without `.fable/`; the standalone `/ask` skill covers questions everywhere else."
---

# fablely-ask

## Goal

Answer the question. Nothing else happens — no intent stamp, no PROGRESS update, no files touched. This is fablely's **Consult** lane, and a Consult that quietly edits something has broken the one promise the lane makes.

A good answer is understandable with zero prior knowledge of this project, and no claim in it is stronger than the evidence behind it.

## You are read-only

Hard boundary, no exceptions inside this skill:

- No `.fable/.intent`, no `PROGRESS.md` update, no `LESSONS.md` or `DECISIONS.md` entry, no `research/` file. Consult changes nothing, so there is nothing for project memory to record.
- No edits to code, config, or docs — not even an obvious one-line fix you spot while reading.
- Read-only git and shell only: `status`, `log`, `show`, `diff`, searching, reading. Nothing that mutates the tree, the index, or the stash.

If the answer turns out to require a change, say what the change would be and stop. Return to fablely's triage so the work gets sized — Trivial, Small, or a work unit — and stamped properly. Discovering a fix mid-answer is not authority to apply it; the user asked a question, and answering it with a diff is answering a question they didn't ask.

The one thing worth flagging even though you can't act on it: if you notice memory is drifting from reality, say so in the answer. The user can decide whether that becomes work.

## Where answers come from

Four sources, in the order you should usually reach for them:

1. **`.fable/` memory** — `DECISIONS.md` for *why it's like this*, `PROGRESS.md` for *what's true right now*, `LESSONS.md` for *what already went wrong here*, `MAP.md` for *where things live*, `work/NNN-*.md` for the design and outcome of a specific unit. A "why" question is very often already answered in DECISIONS, in the words of whoever decided it — reconstructing that from the code instead gives a worse answer, and a guess where a record exists.
2. **The codebase** — the ground truth for what the system actually does today.
3. **Official docs and primary sources** — for facts outside the tree: library behavior, API contracts, specs. Primary sources, not secondary write-ups of them.
4. **Web search** — when the question genuinely needs the wider world and the above can't answer it.

Read only as much as the question needs. A question about one function does not require loading the whole of project memory.

## Memory is a claim, not proof

`.fable/` records what a past session believed. Most of it is true; the parts that aren't are exactly the parts that mislead hardest.

- Attribute it: "DECISIONS.md records that X was chosen over Y because Z" — not "the project uses X because Z", which launders a record into a fact.
- When the answer turns on current project state, check the state rather than repeating what PROGRESS says about it. That is fablely's drift detection, and it costs one `git status`.
- When memory and the tree disagree, the tree wins and the disagreement goes in the answer. A stale record is itself worth knowing about.
- A question about history — what was tried, what was rejected, what already failed — is the one case where memory *is* the primary source. LESSONS.md is the authority on what went wrong here, because nothing else on disk records it.

## Phrase claims at their evidence level

fablely's evidence ladder applies to answers, not just to work:

- **Observed** — you drove the flow, or read the code that does it, and can point at it. Cite the path.
- **Recorded** — project memory says so and you did not re-verify it. Attribute it to the file.
- **Documented** — an official source says so. Link it.
- **Inferred** — you reasoned it out from what you read. Say that you inferred it.

Never flatten these into a confident-sounding paragraph. "The retry logic backs off exponentially" and "I'd expect the retry logic to back off exponentially" are different claims, and the second one dressed as the first is how a wrong answer gets built on later.

Say plainly when you don't know, and say what you'd have to read or run to find out.

## Structure the answer

Written for someone with zero knowledge of this project:

- Lead with the answer. Not the investigation, not what you read first — the actual answer to what was asked.
- Then the *why* or the mechanism, at whatever depth the question warrants.
- Cite specifics as `path/to/file.ts:42` so the user can go look. An answer that can't be checked is worth less than one that can.
- Expand a project term the first time it appears. Something named in `MAP.md` is not self-explanatory to someone reading the answer cold.
- Keep it as short as the question allows. A three-line question rarely needs a page.

If the question has several parts, answer each one — a partial answer that looks complete is worse than one that names what it skipped.

## Scope

One question, or one cluster of related questions, then stop. If answering surfaces a larger issue — a bug, a design problem, an inconsistency — name it in a sentence at the end and let the user decide whether it becomes work. Do not fix it, do not spec it, and do not expand the answer into an unrequested audit.
