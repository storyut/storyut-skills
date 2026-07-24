---
name: fablely-debug
description: Diagnose hard bugs and performance regressions with a reproducible red loop, ranked hypotheses, targeted instrumentation, and a regression test. Use when something is broken, failing, throwing, flaky, or slow.
---

# fablely-debug

Build a tight feedback loop first; let evidence consume hypotheses. Skip a phase only with an explicit reason.

A debug/diagnose request authorizes read-only investigation and existing commands, not persistent harnesses, instrumentation, tests, or fixes. Obtain mutation authority before those actions.

In a writable fablely project, read MAP and relevant DECISIONS. Before the first authorized mutation, write one `small: diagnose <symptom>` intent: `Check first` = repro claim; `Touches` = harness/instrumented paths; `Done when` = loop command and expected red plus the STANDARDS clause IDs at risk. That intent stands through the fix.

## 1. Build the red loop

Prefer the cheapest unattended signal that reaches the real bug:

1. focused test
2. HTTP/CLI invocation with fixture and assertion/diff
3. browser script over DOM, console, or network
4. captured trace/event replay
5. minimal harness with controlled dependencies
6. property/fuzz repetition
7. `git bisect run` or old/new differential
8. structured human steps with captured output, last resort

Make it sharp (exact user symptom), deterministic (pin time/RNG/filesystem/network), and fast. For flaky bugs, measure and raise repro rate with repetition, stress, and narrowed timing; a pinned high rate is acceptable.

If no loop is possible, stop: list attempts and request a reproducing environment, captured artifact, or instrumentation authority. Do not hypothesize without a loop.

**Completion criterion:** name a command already run and paste its output; it is red-capable on the exact symptom, unattended, seconds-fast, and deterministic or has a measured high repro rate.

## 2. Reproduce and minimise

Run the loop red and confirm it matches the user's failure, not a nearby one. Remove inputs, callers, config, data, and steps one at a time, rerunning after each cut.

**Completion criterion:** the smallest red scenario remains; removing any element makes it green. It becomes the hypothesis surface and prospective regression test.

## 3. Rank hypotheses

Before testing any, list 3–5 falsifiable causes. Each predicts an observation or one-variable change that would strengthen or kill it. Show the ranking to the user, then continue without blocking if they are absent.

## 4. Probe

Map each probe to one prediction and vary one thing. Prefer debugger/REPL breakpoints, then boundary logs; never “log everything.” Tag temporary logs with one unique `[DEBUG-...]` prefix. For performance, establish a timing/profile/query-plan baseline before bisection or changes.

**Completion criterion:** one hypothesis survives targeted falsification and explains the minimal repro; diagnosis is evidence, not plausibility.

## 5. Test and fix—only when authorized

Extend the standing intent's Done when with the loop command. A diagnosed fix is Small because the repro is its spec; send only a structural fix (public interface, multiple components, hard to undo) to `fablely-spec` with the minimal repro.

At the correct call-site seam, convert the minimal repro to a regression test, watch it fail, apply the smallest causal fix, watch it pass, then rerun the original unminimised loop. If no correct seam exists, do not add a shallow confidence test; record the missing seam in LESSONS and recommend architectural work after the fix.

## 6. Clean and report

Require: original loop green; regression test green or absent seam documented; every `[DEBUG-...]` artifact removed by prefix search; throwaway harnesses deleted. Report no stronger than red/green evidence.

In writable fablely projects, update PROGRESS with cause/evidence and append generalizable causes or lying tests to LESSONS when discovered. Create checkpoint history only when authorized; otherwise report it in the handoff. If the cause is architectural, recommend `/fablely-arch` with the concrete seam/locality evidence.

**Completion criterion:** cause demonstrated, authorized fix proven against both minimal and original scenarios, temporary diagnostics gone, and remaining uncertainty explicit.
