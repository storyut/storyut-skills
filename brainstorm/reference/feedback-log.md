# Feedback log

Append-only. One entry per accepted piece of user feedback (`deep-path.md` D7).

**Why this file exists.** Several rules in this skill are counterintuitive and backed by measured results that contradict the obvious choice — the ordinary-over-creative persona ban is the clearest example. Without a record of *why*, a future session reads such a rule as a mistake and "fixes" it. Before reverting or overriding anything in SKILL.md or `deep-path.md`, read this file. If a rule is listed here as a deliberate decision, it is not a bug.

Newest entries at the bottom. Never edit or delete past entries — if a decision is reversed, append the reversal and say what changed.

## Format

```
### YYYY-MM-DD — <short title>
**Session:** <topic that prompted the feedback> (fast | deep)
**Feedback:** <what the user said, in their framing>
**Change:** <what was edited, and where>
**Rationale:** <why this is right — enough that a future session won't revert it>
```

---

### 2026-07-17 — Skill rebuilt around idea-diversity research

**Session:** n/a — design session, no brainstorm was run
**Feedback:** User asked for the skill to be improved from research into generating unique ideas, and grilled the design branch by branch.
**Change:** Full rewrite of SKILL.md. Added the fast/deep split, the deep path's parallel persona divergence (step 3-DEEP), the reveal-and-cluster step (step 4), and this feedback loop (step 7). Re-scoped the roleplay section of `techniques.md` to the user's solo phase. Added persona/seed/provenance fields to `summary-template.md`.
**Rationale:** The original skill's core mechanic — strict alternating turns, each side building on the prior idea — is production blocking (Diehl & Stroebe 1987) plus anchoring, i.e. the specific structure the literature indicts. Nominal groups beat interacting groups ~50% on count, non-redundancy, *and* quality (Mullen/Johnson/Salas 1991). The fix was to split alternation's two jobs: it stays as the *collaboration* guarantee and the cross-pollination phase, but no longer structures initial generation on the deep path.

Decisions made deliberately, with their costs accepted — do not silently revert:

- **Deep path is opt-in, not default.** Research-optimal and pleasant-to-use-on-a-Tuesday are different targets. The papers measured idea counts, not whether anyone reached for the tool twice. A skill with 30s of latency and a token cost at the door is a skill nobody opens for small topics.
- **Clustering picks for distance, never merit; weirdest wins ties.** Selecting ~7 of ~28 is judgment, which step 3 otherwise forbids. It's permitted *only* because judging distance ≠ judging quality. If this drifts into a quality filter, the phase launders out the outliers it was paid to produce.
- **Ordinary personas, creative archetypes banned.** Counterintuitive and measured: ordinary 210 vs creative-entrepreneur 164 unique combinations. This is the rule most likely to get "fixed" by someone reasoning from intuition.
- **The seed is a question, not an idea.** The seed exists so the solo phase isn't a wall for users who arrive with nothing; it stays a question because an idea-seed anchors them, which is the exact harm the phase prevents.
- **50/50 is preserved at the conversation level, not the raw-pool level.** The full pool stays on disk and its path is disclosed. Volume parity in the dialogue is what stops the skill degrading into a list dump.

**Known untested.** The deep path is unproven as an assembly — each component has a result behind it, nobody measured this pipeline. The first few real sessions are its only test. Watch for: clustering laundering the interesting ideas; four personas returning four flavors of one answer; solo divergence feeling like homework; latency not earning its keep.

---

### 2026-07-22 — Personas must be situated, not merely ordinary

**Session:** n/a — hardening pass prompted by the rhythm-game-community session's raw pool (deep)
**Feedback:** "I need the subagents to be pivoted to the roles they are IN the situations/environment, currently it just spawns roles that are not really the persona related to that topic."
**Change:** Step 3-DEEP restructured into a→d. Added a **situation map** (four rings of proximity: centre / one ring out / edge / downstream) that personas must be drawn from, a requirement to draw from ≥3 rings, and a **situation anchor** in every agent brief. Narrowed the old "none is an expert in the topic's domain" to "none is the domain's **professional solver**", with an explicit note that being inside the situation is not expertise. Added a grounding rule (ideas must name something that could happen in the topic's world; the persona's other life belongs in the reasoning, not the idea) and a matching ungrounded-idea cut in step 4. Mirrored the situated rule onto the fast path's diversity levers and into `techniques.md`'s Figure Storming note.
**Rationale:** The previous wording collapsed "not an expert" into "unrelated", and the last session dispatched a long-haul trucker, a postal worker, a nursing student and a retail parent at a question about rhythm-game community monetization. The output reasons entirely by analogy — *I chipped in for the CB repeater on the ridge, so: a tip jar* — because no persona had ever stood where the problem is. It reads diverse and is worth almost nothing. Crucially **this does not weaken the ordinary-persona finding**: arXiv 2602.20408 measured ordinary vs. *celebrated/creative* personas, not near vs. far from the topic. Ordinary and situated are compatible, and situated is what makes the ideas usable.

Do not silently revert:

- **"No domain expert" means no professional solver, not no proximity.** The eight-year regular, the venue cleaner and the parent in the car park are all deeply situated and none is the expert. Widening this back to "unrelated walk of life" reintroduces the trucker.
- **≥3 rings, not 4 from the centre.** The opposite failure is equally real — four insiders is a fan club and the pool reads as one long insider conversation. The rings exist to force spread *within* the situation rather than away from it.
- **The ungrounded-idea cut in step 4 is deliberately narrow.** It tests whether an idea is about the topic at all, not whether it's good. It runs *before* clustering precisely so clustering stays a distance judgment and the weirdest idea still wins ties.

### 2026-07-22 — Divergence pool scoped per topic

**Session:** n/a — same hardening pass
**Feedback:** none; bug found while reading the previous session's output on disk.
**Change:** Agents now write to `brainstorms/.diverge/<dash-case-topic>/<persona-slug>.md`; step 4 reads only the current session's folder. Path updated in `summary-template.md`.
**Rationale:** The pool was a single flat `.diverge/` folder, so a second deep session would drop its four files next to the first session's and step 4's "read the raw pool" would pull an unrelated topic's ideas into the reveal — silently, and looking exactly like legitimate persona output. Slug collisions would also overwrite the earlier session's pool, which the summary file still links to as its provenance record.

### 2026-07-22 — Four hardening fixes found while re-reading the deep path

**Session:** n/a — same hardening pass, user asked for the remaining findings to be applied
**Feedback:** none directly; these came from re-reading step 3-DEEP end to end after the situated-persona rewrite.
**Change:**
1. Step 3-DEEP a — **ask rather than invent the situation map** when three rings can't be populated from real knowledge.
2. Step 3-DEEP d — persona files now have a fixed shape: `## Reasoning` then `## Ideas` as **one-line** numbered entries.
3. Step 3-DEEP d — agents are told **not to read the rest of `.diverge/`**, and must be fresh general-purpose agents, never forks of the main conversation.
4. Step 6 — **never overwrite an existing summary**; suffix `-2`, `-3` and link the prior one.
**Rationale:**
1. The situated-persona rule makes the map load-bearing, which makes an *invented* map the new failure mode — and a fabricated cast is harder to spot than a trucker, because everyone on it sounds right. One question to the user is the cheapest accuracy in the session.
2. The previous session's persona files were 4–7K of prose each; step 4 reads all four, then has to re-parse essays into comparable units before it can cluster. One-liners make clustering a real operation instead of a reading exercise. Reasoning stays in the file — it's still required, just not in the way.
3. Two silent leaks in a phase whose entire value is silence. The four agents write into one folder *concurrently*, so any that lists or reads it sees its peers' ideas — the exact cross-contamination step 3-DEEP pays to avoid. Forking is the worse version: a fork inherits the full framing and prior turns, so four "independent" personas would all be reasoning from one shared anchor, which is the anchoring the parallel design exists to break (arXiv 2605.30150).
4. Re-running a topic is the *documented* trigger for the deep path ("a fast session already ran and produced samey ideas") — so the overwrite case isn't an edge case, it's the intended workflow destroying its own input. The prior summary is both the reason for the re-run and the shortlist the new session should be measured against.

### 2026-07-22 — Deep path split out of SKILL.md (token brew)

**Session:** n/a — /brew pass on the skill itself
**Feedback:** none; user asked for a token audit.
**Change:** SKILL.md cut 2830 → 639 words by moving the entire deep path to `reference/deep-path.md` (old steps 3-DEEP, 4 and 7 → D1–D7). Fast-path steps renumbered: old 5 (converge) → 4, old 6 (save) → 5. Step references in `techniques.md` and this file's header updated. No rule was deleted — every "do not revert" decision in this log survives verbatim in `deep-path.md`.
**Rationale:** ~70% of SKILL.md was deep-path material that only fires on `--deep`, which is opt-in and rare, yet it was loaded on every fast session. The counterintuitive persona rules need their full reasoning attached; a disclosed file keeps that reasoning intact instead of shaving it. One level of disclosure only — `deep-path.md` is read whole when the deep path is chosen.

Do not silently revert:

- **Deep-path content stays out of SKILL.md.** Folding it back inline reintroduces the cost on every fast session, and the pressure to then compress the persona rationale — which is the material this log exists to protect.

### 2026-07-22 — `--auto` flag added

**Session:** n/a — design session with the user
**Feedback:** "I need a new execution flag which is full on automatic brainstorm that hands off all the idea by you. I'm the one who reviews them after all ideas are present."
**Change:** New `--auto` path, specced as an Auto mode section in `deep-path.md` (A1–A5) reusing D1–D4. Skips SKILL.md steps 1–3. One batched question (framing + situation cast), personas dispatched, cluster to 8, second parallel round of the same personas cross-pollinating, cluster to 4–6, present ~12–14 unranked. Returns to SKILL.md step 4 for convergence with the user. SKILL.md path block and `argument-hint` updated; `summary-template.md` gained an auto path value and a round-2 line.
**Rationale:** `--auto` could not be the fast path with the user's turns deleted — the user's ideas are what break the anchor every other turn, so removing them leaves one model generating sequentially against its own accumulating context, which is the diversity collapse arXiv 2605.30150 documents and the deep path was built to fix. Reusing the persona machinery was the only defensible engine. Round 2 restores the cross-pollination the riff provided, in parallel and with each persona shown the pool *minus their own ideas*, so building-on doesn't degrade into restating.

Do not silently revert:

- **The 50/50 rule is waived by `--auto`, and only by `--auto`.** This directly contradicts the 2026-07-17 entry's "50/50 is preserved at the conversation level". That decision still stands for fast and deep; `--auto` is an explicit opt-in carve-out, the same shape `--deep` has. Reading `--auto` as a violation of the invariant and deleting it is the predicted failure.
- **Auto skips step 2 (pick a technique) deliberately.** The technique only ever scaffolded the user's solo divergence, which auto mode doesn't have. Re-adding it gives the technique no job and re-introduces the double-counted-personas failure the deep path already fixed.
- **A5 forbids best-first ordering.** With no alternating turns, list position is the only ranking signal left, and using it smuggles merit judgment into a phase that forbids it — the same laundering risk as the clustering step, now in the presentation.
- **Fixed caps (8, then 4–6) replace "capped at the user's own count".** There is no user count in auto mode. The caps are arbitrary but must stay *fixed*, or the cap becomes a judgment call about how many ideas are good enough.
