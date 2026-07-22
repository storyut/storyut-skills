# Patch a failed run

Repair the controlling instruction, not the disappointing output. Evidence means observable prompts, responses, actions, tool results, and skill text; never infer hidden reasoning.

## 1. Reconstruct

Use the current transcript or the session artifact the user provides. Record:

- expected behaviour;
- observed behaviour;
- the first observable divergence;
- the skill text and version that governed the run.

Ask only for missing evidence that could change the diagnosis.

**Completion criterion:** one failure is reproducible as `given / expected / observed / first divergence`, with every claim tied to available evidence.

## 2. Diagnose

Read the whole skill and every reference its failing path requires. Use [`REFERENCE.md`](REFERENCE.md#failure-modes) to classify the failure. Separate:

- **instruction failure** — missing, ambiguous, conflicting, misplaced, stale, or too weak to beat the model default;
- **execution failure** — the instruction was adequate but the model, tool, environment, or unavailable information defeated it.

Patch only an instruction failure. For an execution failure, stop with the evidence and the proper non-skill remedy.

**Completion criterion:** a causal claim names the evidence, failure class, and exact instruction that controlled—or should have controlled—the divergence.

## 3. Design the patch

Change the smallest existing source of truth. Add a rule only when none governs the behaviour. Encode the general decision boundary, not session-specific wording or the desired answer.

Write two regression scenarios before editing:

- the original case, which must now take the desired path;
- the nearest counterexample, which must preserve the old valid path.

**Completion criterion:** the proposed wording distinguishes both scenarios without contradicting another branch.

## 4. Apply and replay

Edit the skill, its directly affected references, and required repo metadata. Replay both scenarios with the same harness when available; otherwise trace each scenario through the written steps and label that check a dry run. If either fails, revise the diagnosis before revising the wording.

**Completion criterion:** both scenarios pass; the skill remains valid; unrelated behaviour and invocation are unchanged.

## 5. Report

Return `evidence → cause → patch → regressions`, name any uncertainty, and distinguish replayed checks from dry runs. Report changed files and token delta. Do not claim the skill learned autonomously: the durable change is the patch.

**Completion criterion:** the user can veto the diagnosis, wording, or either regression independently.
