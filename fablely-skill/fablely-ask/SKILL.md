---
name: fablely-ask
description: Answer one read-only question inside an existing fablely project.
disable-model-invocation: true
---

# fablely-ask

Answer the user's question and change nothing. This is a user-invoked Consult shortcut, not an automatic fablely dependency.

## Hard boundary

- No intent, PROGRESS, research, LESSONS, DECISIONS, code, config, doc, index, stash, or git-history mutation.
- Use only read/search and read-only git/shell commands.
- If an answer requires a change, describe it and stop; return proposed work to fablely triage.
- Report memory drift, but do not repair it here.

**Completion criterion:** the tree and project memory are byte-for-byte untouched.

## Find the answer

Read only what the question needs, usually in this order:

1. `.fable/`: DECISIONS for why, PROGRESS for recorded state, LESSONS for failed paths, MAP for location, work files for a unit's design/outcome.
2. Code: ground truth for current behavior.
3. Official docs, source, or specifications for external contracts.
4. Wider web only when primary sources and the tree cannot answer.

Treat memory as a recorded claim, not proof. Attribute it (“DECISIONS records…”). Verify state-dependent claims against the tree/status; when they disagree, the tree wins and the answer names the drift. For historical questions, memory is the primary source.

Phrase each material claim as:

- **Observed:** driven behavior or inspected code; cite `path:line`.
- **Recorded:** unverified project memory; name the file.
- **Documented:** official source; link it.
- **Inferred:** reasoning from inspected evidence; label it.

Say what remains unknown and what evidence would resolve it. Never turn a prediction into a fact.

## Answer

Lead with the answer, then the mechanism/why at the requested depth. Define project terms on first use and cite checkable specifics. Answer every related part, but stop after this question cluster. Name any larger bug/design issue in one closing sentence; do not fix, spec, or audit it.
