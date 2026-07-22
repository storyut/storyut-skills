---
name: fablely-debug
description: Diagnosis loop for hard bugs and performance regressions. Use when the user says "diagnose"/"debug this", or reports something broken/throwing/failing/slow.
---

# fablely-debug

## Overview

A discipline for hard bugs: build a tight feedback loop first, then let bisection, hypotheses, and instrumentation consume it. Skip phases only when explicitly justified.

Works in any project. In a project with `.fable/`, it plugs into fablely: before the first mutating step (harness files, instrumentation), stamp `.fable/.intent` with `small: diagnose <symptom>` — **Check first**: the repro claim you'll verify; **Touches**: harness and instrumented files; **Done when**: the Phase 1 loop command, red. A loop you watched go red then green is fablely evidence level 2 — report at that level, never above (fablely's `references/evidence.md`). Orient with `MAP.md` before exploring; check `DECISIONS.md` for constraints in the area you're touching.

## Phase 1 — Build a feedback loop

**This is the skill.** Everything else is mechanical. With a tight pass/fail signal that goes red on *this* bug, you will find the cause; without one, no amount of staring at code will save you. Spend disproportionate effort here — be aggressive, be creative, refuse to give up.

Ways to construct one, in rough order:

1. **Failing test** at whatever seam reaches the bug — unit, integration, e2e.
2. **Curl / HTTP script** against a running dev server.
3. **CLI invocation** with a fixture input, diffed against a known-good snapshot.
4. **Headless browser script** (Playwright / Puppeteer) asserting on DOM/console/network.
5. **Replay a captured trace** — save a real payload / event log, run it through the code path in isolation.
6. **Throwaway harness** — a minimal subset of the system (one service, mocked deps) exercising the bug path in a single call.
7. **Property / fuzz loop** — for "sometimes wrong output": 1000 random inputs, look for the failure mode.
8. **Bisection harness** — bug appeared between two known states: automate "boot at state X, check" so `git bisect run` can consume it.
9. **Differential loop** — same input through old vs new version (or two configs), diff the outputs.
10. **Human-in-the-loop script** — last resort. If a human must click, drive *them* with a structured script whose captured output feeds back to you.

**Tighten it.** Treat the loop as a product: faster (cache setup, skip unrelated init, narrow scope), sharper (assert the specific symptom, not "didn't crash"), more deterministic (pin time, seed RNG, isolate filesystem, freeze network). A 2-second deterministic loop is a debugging superpower; a 30-second flaky one is barely a loop.

**Non-deterministic bugs:** chase reproduction *rate*, not a clean repro — loop the trigger 100×, parallelise, add stress, narrow timing windows. A 50%-flake bug is debuggable; 1% is not.

**If you genuinely cannot build a loop:** stop and say so, list what you tried, and ask for (a) access to an environment that reproduces it, (b) a captured artifact (HAR, log dump, core dump, recording with timestamps), or (c) permission to add temporary instrumentation. Do **not** hypothesise without a loop.

**Done when** you can name one command you have **already run** (paste the invocation and output) that is: **red-capable** (drives the actual bug path and asserts the user's exact symptom — able to catch this bug, not just "runs without erroring"), **deterministic** (or a pinned, high repro rate), **fast** (seconds), and **runnable unattended**. Reading code to build a theory before this command exists is the exact failure this skill prevents.

## Phase 2 — Reproduce + minimise

Run the loop; watch it go red. Confirm it produces the failure mode the **user** described — not a nearby different failure; wrong bug = wrong fix — and capture the exact symptom so later phases can verify the fix addresses it.

Then shrink to the **smallest scenario that still goes red**: cut inputs, callers, config, data, and steps one at a time, re-running after each cut. Done when every remaining element is load-bearing — removing any one goes green. The minimal repro shrinks the Phase 3 hypothesis space and becomes the Phase 5 regression test. Do not proceed until reproduced **and** minimised.

## Phase 3 — Hypothesise

Generate **3–5 ranked, falsifiable hypotheses** before testing any — single-hypothesis generation anchors on the first plausible idea. Each states its prediction: "if X is the cause, then changing Y makes the bug disappear / changing Z makes it worse." No prediction = a vibe; discard or sharpen it.

Show the ranked list to the user before testing — domain knowledge re-ranks instantly ("we just deployed a change to #3"). Don't block on it; proceed with your ranking if they're away.

## Phase 4 — Instrument

Each probe maps to one Phase 3 prediction; change one variable at a time. Prefer a debugger/REPL breakpoint over logs, targeted logs at the boundaries that distinguish hypotheses over that, and never "log everything and grep". Tag every debug log with a unique prefix (e.g. `[DEBUG-a4f2]`) so cleanup is a single grep.

For performance regressions, logs are usually wrong: establish a baseline measurement (timing harness, profiler, query plan), then bisect. Measure first, fix second.

## Phase 5 — Fix + regression test

With the diagnosis in hand, the fix executes under the standing `small: diagnose` intent — extend its `Done when` with the loop command rather than re-stamping. A diagnosed bug is Small however much behavior the fix changes: you already hold what a spec would produce, in stronger form. Only a structural fix — interface change, multiple components, hard to revert — goes to `fablely-spec` for a work unit, with the minimised repro attached.

Write the regression test **before** the fix — but only at a **correct seam**: one where the test exercises the real bug pattern as it occurs at the call site. Turn the minimised repro into a failing test there, watch it fail, apply the fix, watch it pass, then re-run the Phase 1 loop against the original (un-minimised) scenario.

If no correct seam exists, **that itself is the finding** — a test at a too-shallow seam gives false confidence. Record it in `LESSONS.md` and flag it for the Phase 6 recommendation.

## Phase 6 — Cleanup + post-mortem

Before declaring done: original repro re-run and green; regression test passing (or the absent seam documented); all `[DEBUG-...]` instrumentation removed (grep the prefix); throwaway harnesses deleted. When a checkpoint commit is authorized, state the confirmed hypothesis in its message so the next debugger learns. Without commit authority, create no Git history: in a writable fablely project record the cause in PROGRESS and in LESSONS when it generalizes; outside fablely, or when `.fable/` is excluded, report it in the final handoff only.

Capture while it's fresh (in `.fable/` projects):

- A test that lied — passed while the code was broken, or covered only the happy path → `LESSONS.md`, at that moment, not later.
- Then ask: **what would have prevented this bug?** If the answer is architectural — no good test seam, tangled callers, hidden coupling — recommend `/fablely-arch` with the specifics. Make the recommendation after the fix is in, not before: you know more now than when you started.
