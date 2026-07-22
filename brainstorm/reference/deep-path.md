# Deep path — parallel silent divergence

Entered from SKILL.md after step 2. Run D1→D6, return to SKILL.md step 4 (converge) and step 5 (save), then D7.

For `--auto`, jump to the Auto mode section at the end of this file; it reuses D1–D4 and replaces the rest.

Both sides generate independently, before either sees the other's ideas. **The silence is the point** — turn-taking suppresses ideas (production blocking, Diehl & Stroebe 1987), nominal groups beat interacting ones ~50% on count, non-redundancy *and* quality (Mullen, Johnson & Salas 1991), and for LLMs specifically, building sequentially on shared context collapses diversity ([arXiv 2605.30150](https://arxiv.org/abs/2605.30150)).

The step-2 technique scaffolds **the user's solo divergence only**. The personas scaffold your side — don't also assign yourself a roleplay technique, or you double-count personas.

## D1. Map the situation — before you name anyone

List **who actually touches this thing**, in concrete roles, by proximity:

1. **Centre** — the people the topic is *about*, who live inside it daily.
2. **One ring out** — those who serve, supply, host, moderate, fund, or clean up after ring 1.
3. **Edge** — those who arrived and bounced, quit, got priced out, were never let in, or show up once a year.
4. **Downstream** — those who absorb the consequences without choosing to be involved.

Personas get **drawn from this map**, never invented beside it.

**If you can't populate three rings with roles you know exist, ask — don't invent.** An invented map produces invented people who all sound right, which is this step's failure one level harder to spot. One question does it: *"who else is around this — who serves it, who left, who deals with the fallout?"*

## D2. Select 4 personas, fresh per session

Never a fixed roster and never one carried from a prior session — a roster means every session you ever run draws on the same four minds.

- **Every persona stands somewhere on the map.** If you can't state in one sentence what they physically do that puts them in contact with the topic, they aren't a candidate.
- **None is the domain's professional solver** — nobody paid to design, build, strategise or consult on this exact problem, because expertise pulls toward the obvious frame. *Being inside the situation is not expertise*: the eight-year regular, the venue's cleaner and the parent in the car park are all deeply situated and none is the expert.
- **At least three rings.** Four from the centre is a fan club, not a divergence.
- **Each has a life, not a title** — "regular at the same Thursday night for eight years, just had a kid", not "community member".
- They **differ on at least one hard axis**: money, tempo, geography, physicality, age, how much they have to lose.
- **No creative archetypes** — no founders, designers, innovators, artists, futurists.

> **Why ordinary, and why the creative ban — do not revert this.** Measured: ordinary personas took unique idea-combinations 88 → 210 and raised between-participant semantic variation 2.6×. Creative-entrepreneur personas scored *worse*, 164 vs 210. The intuitive choice is the losing one. Source: [Examining and Addressing Barriers to Diversity in LLM-Generated Ideas](https://arxiv.org/abs/2602.20408).
>
> **Ordinary ≠ unrelated — this rule keeps failing that way.** An earlier version read "not an expert" as "unrelated walk of life" and dispatched a long-haul trucker at a question about rhythm-game communities. What comes back is metaphor — *my CB repeater on the ridge, therefore a tip jar* — reasoning from the persona's own world and mapping the conclusion sideways. It reads diverse and is worth almost nothing, because nobody in it has ever stood where the problem is. The measured effect is **ordinary vs. celebrated**, not distant vs. near. Ordinary *and* situated.

## D3. De-jargon the question per persona, before dispatch

Someone stacking pallets can't answer "how should we handle multi-tenant state hydration" — they return mush or the generic assistant voice, and you've paid for four agents and received one. Translate into their plain language, in terms of the thing they actually touch: "when two people use the same terminal, how do we keep one person's stuff out of the other's?" The translation is itself a diversity lever — plain phrasing admits answers the original forecloses.

## D4. Dispatch all 4 in parallel, in a single message

Fresh general-purpose agents, never forks of this conversation — a fork inherits the whole framing and collapses four voices into one. Each brief carries:

- **The situation anchor** — where this persona stands on the map, what puts them in contact with the topic, what they stand to lose or gain. Two or three sentences of concrete detail; this is what stops the agent drifting back to the assistant voice.
- **The de-jargoned question**, in their terms.
- **Reason step by step before answering.** Not optional: chain-of-thought lifts unique combinations 83 → 152 and cancels the fixation personas alone introduce; personas + CoT reach 248, beating the human baseline of 197 (arXiv 2602.20408).
- **Ground every idea in the topic's own world** — each idea names something that could actually happen in the situation, in the situation's terms. Lived experience from elsewhere belongs in the *reasoning* ("I know what it's like when the thing you rely on quietly disappears"), never as the idea. An idea that only works as an analogy doesn't count.
- **6–8 ideas** to `brainstorms/.diverge/<dash-case-topic>/<persona-slug>.md`: `## Reasoning` first, then `## Ideas` as a numbered list of **one line each**, no paragraphs. D6 clusters those one-liners; without them the reveal re-parses four essays.
- **Read nothing else in `brainstorms/.diverge/`.** The other three agents are writing there right now.

**Don't read the agent output yet, and don't show the user.** Seeing your half before writing theirs anchors them, and the phase bought nothing.

## D5. While the agents run, the user does a solo divergence

On the step-2 technique. 6–8 ideas, sent as one message.

*Seed escape hatch.* If they genuinely have nothing they can ask for a seed — say it isn't free. Give a **question, not an idea**: "what does the failure look like?" shapes their search far less than "what about a mobile app?" shapes their solution space. If they insist on an idea, give it, say plainly that it anchors them, and record the seeding in the summary.

## D6. Reveal

Read the raw pool once the user's list has landed — **only this session's folder**, `brainstorms/.diverge/<dash-case-topic>/`. Prior sessions sit in sibling folders; never let one leak in.

**Drop ungrounded ideas first.** An idea that only holds together as an analogy to the persona's other life gets cut; say how many you cut. This is the one merit judgment permitted, narrow on purpose: it tests whether an idea is *about the topic at all*, not whether it's good. More than one or two per persona means the personas came from too far out — say so.

Cluster the survivors semantically and surface **one representative per cluster, capped at the user's own count**. They wrote 7, they see 7.

**Pick for distance, never merit.** Clustering judges how far apart ideas are, not which is better. The moment it becomes a quality filter it launders out the weird outliers the agents existed to produce, and you spent four agents to arrive back at the obvious. **Equally representative → the weirder one wins.**

Reveal both sides at once. Name each idea's persona by their **position in the situation** ("the eight-year regular", "the parent in the car park"), not by slug — it fuels the riff, keeps the machinery auditable, and lets the user flag a wrongly-placed persona immediately. Give the raw pool path in the reveal; nothing is hidden, the full ~28 just aren't dumped into the conversation.

**Then run the alternating riff** on SKILL.md step 3's rules, cross-pollinating the two revealed lists. Then SKILL.md step 4.

## D7. Ask for feedback, after the summary is saved

The deep path is unproven **as an assembly** — every component has a measured result, this pipeline was assembled by hand and never tested end to end. Real sessions are its only test.

Ask once, and accept "no" without pushing:

> "Any feedback on how that session ran? I can fold it back into the skill."

Apply what they give directly to the skill, and **append an entry to [`feedback-log.md`](feedback-log.md)** saying what changed and why. Append-only: it exists so deliberate decisions don't get quietly reverted by a future session lacking the context.

Worth reporting:

- Clustering laundered out the interesting ideas — the revealed 7 feel safer than the raw 28.
- Four personas, four flavors of one answer.
- A persona from too far outside the situation — analogies from their own world, or several cut as ungrounded.
- The opposite: all from the centre, and the pool reads as one long insider conversation.
- The solo divergence felt like homework.
- The latency didn't earn its keep on this class of topic.

## Auto mode (`--auto`)

Entered from SKILL.md instead of steps 1–3. You generate the whole idea set; the user reviews it at the reveal. The 50/50 rule is waived here and only here — it's waived by explicit flag, the same carve-out `--deep` has, and is not a bug to fix.

Run A1→A5, then SKILL.md step 4 (converge) and step 5 (save), then D7.

**A1. One batched question, then silence.** Ask the framing question and D1's cast question in a single message — what the real goal or constraint is, *and* who else is around this: who serves it, who left, who deals with the fallout. Say this is the only interruption. Do not pick a technique: the step-2 technique scaffolds the user's solo divergence, and auto mode has none.

**A2. Run D1→D4 unchanged** — situation map from their answer, 4 personas, de-jargoned per persona, dispatched in parallel. D5 does not run; the user is writing nothing.

**A3. Cut and cluster.** Apply D6's ungrounded cut, then cluster on distance to **8 representatives**. No user count to cap at, so the number is fixed. Distance-not-merit and weirder-wins-ties hold exactly as in D6 — the absence of a human in the loop makes them *more* load-bearing, not less, because nobody else is there to notice the outliers going missing.

**A4. Round 2 — cross-pollination, in parallel.** Re-dispatch the same four personas as fresh agents. Each brief carries its original situation anchor and de-jargoned question, plus **the 8 representatives minus that persona's own contributions** — so they build on other people, not restate themselves. Ask for step-by-step reasoning, then **3–4 ideas** that build on, combine, or push back against what they were shown, still grounded in the topic's world. Write to `brainstorms/.diverge/<dash-case-topic>/round-2/<persona-slug>.md`, same `## Reasoning` / one-line `## Ideas` shape, and still read nothing else in `.diverge/`. Cut ungrounded, cluster to **4–6**.

**A5. Present the full set — no ranking.** Show ~12–14 one-liners in two groups, *independent* (A3) and *built on* (A4), each tagged with its persona's position in the situation. Order by ring or by generation order, never best-first: with no alternating turns to enforce it, position in a list is the only ranking signal left, and using it smuggles judgment into a phase that forbids it. State how many were cut as ungrounded and give the pool path. Then hand off — the user says what resonates before SKILL.md step 4 begins.

Auto mode is even less proven than the deep path — one model's four personas, twice, with nobody breaking the frame. Run D7, and watch additionally for: the two groups reading as one voice; round 2 restating round 1 rather than building; the batched question being too thin to build a real map from.
