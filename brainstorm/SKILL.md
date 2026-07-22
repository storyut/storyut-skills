---
name: brainstorm
description: Run a 50/50 collaborative brainstorm session with the user — alternating-turn idea generation, no judgment until convergence. Fast by default; `--deep` adds a parallel silent-divergence phase for higher idea diversity. Use when the user runs /brainstorm or explicitly asks to brainstorm together on a topic, decision, or problem.
argument-hint: "What do you want to brainstorm about? (--deep for the full divergence pipeline, --auto to hand the whole generation half to Claude)"
---

The user wants to think *with* you, not hand you the thinking. You generate roughly half the ideas yourself, in alternating turns (waived only by `--auto`). More than one idea from you in a row during a riff phase breaks the format.

**Fast (default)** — steps 1 → 2 → 3 → 4 → 5. Conversational, starts instantly, no subagents.

**`--deep`** — after step 2, follow [`reference/deep-path.md`](reference/deep-path.md); it returns here at step 4. Use when the topic is high-stakes, the user is stuck in an obvious frame, or a fast session already produced samey ideas.

**`--auto`** — the user hands you the whole generation half and reviews the finished set. Skip steps 1–3 and follow the auto-mode section of [`reference/deep-path.md`](reference/deep-path.md); it returns here at step 4.

**Never run `--deep` or `--auto` unprompted** — each spawns agents on the user's time and budget.

## 1. Frame

Ask one sharpening question to pin down the real goal or constraint — audience, scope, what "good" looks like, what's off the table. One question, not a stack. Skip if the user's opening message already answers it.

## 2. Pick a technique

Read [`reference/techniques.md`](reference/techniques.md) and pick by the topic's shape:

- Open-ended / need volume → generative
- Stuck / need a fresh angle → reframing
- Structured exploration of one idea → analytic

State the pick and why, in one sentence. The user's override wins.

## 3. Generate — alternating turns, no judgment

- User contributes one idea → you contribute one idea → repeat. Number them as they land (U1, C1, U2, C2…).
- You may build on the immediately prior idea, but never critique, rank, or evaluate here — judgment kills volume, so defer all of it to convergence.
- 6–8 ideas per side, then stop and ask: "converge now, or keep generating?" Same fixed-round-then-ask pattern if they want more.

Free diversity levers for your own turns:

- De-jargon the framed question to yourself before answering it. Domain phrasing forecloses answers; plain phrasing reopens them.
- Answer from somewhere specific **inside the topic's world** — the person queuing, the one who quit last year, the one who cleans up afterwards. Rotate the vantage point between turns. A vantage point from an unrelated walk of life produces analogy, not ideas.
- Never adopt a creative archetype (founder, designer, innovator, futurist). This is a ban, not a preference: ordinary personas measured 210 unique idea-combinations against 164 for creative-entrepreneur ones ([source](https://arxiv.org/abs/2602.20408)). The intuitive pick is the losing one.

## 4. Converge

Judgment is now welcome. Run a short analytic pass together over the full list, narrowing to a shortlist of 1–3:

- How-Now-Wow (originality × feasibility) for creative/product topics.
- SWOT for a single decision being evaluated (go/no-go, choose-between).
- Five Whys or Gap Analysis when a shortlisted idea needs root-cause or feasibility digging.

Ask which ideas resonate before declaring a shortlist. On `--deep` and `--auto`, converge over the revealed set; the raw pool stays available for digging.

## 5. Save the summary

Write `brainstorms/<dash-case-topic>.md` in the current project directory (create the folder if needed), structured by [`reference/summary-template.md`](reference/summary-template.md). Tell the user the path.

Never overwrite an existing file — it's a prior session on the same topic, and re-running a topic usually means that session is the context for this one. Write `<dash-case-topic>-2.md` (then `-3`…) and link the earlier one at the top.

On `--deep` and `--auto`, finish with D7, the feedback step in `reference/deep-path.md`.

## Sources

- Techniques: [Asana](https://asana.com/resources/brainstorming-techniques)
- Persona and chain-of-thought diversity effects: [arXiv 2602.20408](https://arxiv.org/abs/2602.20408)
- Deep path's own sources are cited inline in `reference/deep-path.md`.
