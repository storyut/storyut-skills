---
name: fablely-arch-codex
description: Codex port. Scan a fablely project for evidence-backed deepening opportunities, rank them, and hand the user-selected candidate to fablely-spec-codex.
---

# fablely-arch-codex

Find refactors that put more behavior behind smaller interfaces. Scan and propose only; `fablely-spec-codex` owns design and fablely owns execution.

## Vocabulary

Use these terms exactly:

- **Module:** any interface plus implementation, at any scale.
- **Interface:** everything callers must know: signature, invariants, ordering, errors, configuration, performance.
- **Depth:** behavior gained per unit of interface learned; deep means much behind little.
- **Seam:** where behavior can change without editing the caller; the module interface.
- **Adapter:** a concrete implementation at a seam.
- **Leverage:** one implementation serving many callers/tests.
- **Locality:** change, bugs, knowledge, and verification concentrated together.

Tests: **deletion**—if removing a module makes complexity vanish, it was pass-through; if complexity spreads into callers, it earned its keep. **Interface is the test surface**—testing past it signals the wrong shape. **One adapter is hypothetical; two make a seam real.**

## 1. Explore read-only

Honor a user-named area. Otherwise use recent history to find change hot spots; if none, bound the scan from MISSION, MAP, tests, and call sites. Read MISSION, MAP, and DECISIONS before judging.

When `[features] multi_agent = true`, delegation is permitted, and the capability is available, send one read-only explorer; otherwise inspect inline. Look for scattered concept knowledge, shallow modules, “testable” helpers whose caller interactions hold the bugs, leaking seams, and behavior hard to test through its interface. Apply the deletion and adapter tests.

Drop candidates that conflict with DECISIONS unless current friction justifies reopening the dated decision. If none survives, report that plainly; never manufacture one. Label weak evidence or missing history as limited confidence.

**Completion criterion:** every candidate has observed friction, passes the deletion test, and represents a real or justified seam.

## 2. Present candidates

Write no report file. For each candidate give:

- files
- problem
- plain-language solution
- locality, leverage, and test benefit
- compact before/after interface sketch
- strength: `Strong`, `Worth exploring`, or `Speculative`

Use project domain names and the vocabulary above. Mark any reopened decision with its date and evidence. Recommend one candidate and why; do not design concrete interfaces yet.

**CHECKPOINT · STOP:** wait for selection. Do not invoke `fablely-spec-codex`, mutate files, or record a decision before the user chooses.

## 3. Handoff

Send the chosen candidate to `fablely-spec-codex` to grill the module shape, seam contents, constraints, and surviving tests, then write the work unit. If the user rejects it for a durable reason, offer a DECISIONS entry; skip temporary or self-evident reasons.
