# Reference — brew

Disclosed reference for [`SKILL.md`](SKILL.md). Four sections: **Vocabulary** (what the bold terms mean), **Failure modes** (diagnosing a skill that misbehaves), **Prose edits** (pass 8 worked examples), **Why the passes are ordered this way** (the evidence).

## Vocabulary

Grouped by axis. Every term is a lever on **predictability**.

### Predictability

The degree to which a skill makes the agent behave the same _way_ each run — same process, not same output. A brainstorming skill should predictably diverge: its tokens vary, its behaviour does not. The root virtue; token cost and maintainability are symptoms of it, not rivals.

### Invocation — how a skill is reached

- **Model-invoked** — keeps its `description`, so the agent can fire it on its own and other skills can reach it. The human can still type its name too: model-invocation _includes_ user reach, never replaces it. Pays **context load** forever.
- **User-invoked** — `disable-model-invocation: true`, description stripped to a human one-liner. Invisible to the agent, reachable only by name. Zero context load; nothing but the human can fire it, including other skills.
- **Description** — the machine-readable trigger, and the one context pointer a model-invoked skill must keep loaded at all times. Its presence _is_ the invocation axis.
- **Context pointer** — a reference held in context that names out-of-context material and encodes when to reach it. Its _wording_, not its target, decides how reliably the agent reaches it. Must-have material behind a weak pointer is a variance bug: sharpen the wording first, inline it only if that fails.
- **Context load** — what a model-invoked skill costs the agent's window every turn. The brake on splitting into more model-invoked skills.
- **Cognitive load** — what a user-invoked skill costs the human, who becomes the index of which skills exist. Do not minimise it: it is the price of human agency. Cure it, when user-invoked skills multiply, with a **router skill** — one user-invoked skill naming the others and when to reach for each.
- **Granularity** — how finely you divide skills. Two cuts: _by invocation_, split off a model-invoked skill when it needs a distinct trigger word of its own; _by sequence_, split a run of steps when the later ones need hiding.

### Information hierarchy — how content is arranged

Content ranked by how immediately the agent needs it:

1. **Steps** — ordered actions in SKILL.md. Primary tier. Each ends on a completion criterion.
2. **Reference, in-file** — definitions, rules, facts consulted on demand. Often a legitimately flat peer-set (every rule of a review on one rung) — a fine arrangement, not a smell.
3. **Reference, disclosed** — pushed into a sibling file behind a context pointer, loaded only when the pointer fires.

- **Progressive disclosure** — the move down that ladder. **Branching** licenses it: inline what every branch needs, disclose what only some reach. It protects the hierarchy's legibility; the token saving is a side effect.
- **Branch** — a distinct way a skill can be invoked, so different runs take different paths through it.
- **Co-location** — where the hierarchy decides _how far down_ a piece sits, co-location decides _what sits beside it_: a concept's definition, rules and caveats under one heading, so reading one part brings its neighbours.
- **External reference** — reference outside the skill system entirely: a plain file, no description, not invocable, that any skill can point at. The only shared home two user-invoked skills can use, since neither can fire the other.

### Steering — shaping runtime behaviour

- **Leading word** — a compact concept already in the model's pretraining that the agent thinks _with_ while running the skill (_lesson_, _fog of war_, _tracer bullets_, _tight_, _red_). Repeated as a token, never as a sentence, it accumulates a distributed definition and anchors a whole region of behaviour in the fewest tokens. It serves predictability twice: in the body it anchors execution, in the description it anchors invocation — especially when the same word lives in your prompts, docs and code. Coining your own works only if you define it, and you pay in definition tokens what a pretrained word gives free.
- **Completion criterion** — the condition telling the agent a unit of work is done. Two independent axes. _Clarity_ (can it tell done from not-done?) resists premature completion, and needs steps to bite. _Demand_ (how much it requires) sets **legwork** — "every modified model accounted for" forces thorough work where "produce a change list" does not — and reaches past steps, so it can bind flat reference too ("every rule applied"). The strongest criteria are both checkable and exhaustive.
- **Legwork** — the digging the agent does within a single step: reading files, exploring, finding what it needs rather than offloading to the user. Never written as its own step; latent in the wording. Raised by a demanding completion criterion or a strong leading word.
- **Post-completion steps** — the steps after the current one. Visible, they pull the agent forward into premature completion.
- **Single source of truth** — each meaning in exactly one authoritative place, so changing behaviour is a one-place edit.
- **Relevance** — whether a line still bears on what the skill does. Lost either by never bearing on the task, or by going stale as the world it describes changes.

## Failure modes

Use when the user reports the skill behaving wrongly, not merely being long.

| Symptom | Failure mode | Cure |
|---|---|---|
| A step ends before the work is genuinely done; attention slips to _being done_ | **Premature completion** — a between-steps failure; needs steps to occur | Sharpen the completion criterion first — local and cheap. Only if it is irreducibly fuzzy _and_ you observe the rush, hide the later steps by splitting. Hiding works only across a real context boundary (user-invoked hand-off, subagent dispatch); an inline call leaves them in context and clears nothing. |
| Changing one behaviour needs edits in several places; one idea feels louder than it should | **Duplication** — the same meaning given more than one home | Fold to one source of truth. It is the accidental inverse of a leading word, which repeats a _token_ on purpose, never the meaning. |
| You core down through stale layers to find what is still live | **Sediment** — old content that settled because adding feels safe and removing feels risky | A pruning discipline: check every line for relevance on every edit. |
| Too long, though every line is live and unique | **Sprawl** — length itself, whatever its cause | The hierarchy: disclose reference behind pointers, split by branch or sequence so each path carries only what it needs. |
| A line you cannot point at any behaviour change from | **No-op** — the model already does it by default | Delete it. A line can be relevant and still be a no-op. A leading word too weak to beat the default (_be thorough_ when the agent is already thorough-ish) is a no-op; the fix is a stronger word (_relentless_), not a different technique. |
| The agent asks the user what the skill used to answer; two runs diverge on one branch | **Over-brewed** — compacted below the floor | Restore the cut — a concrete example before prose. See below. |

The no-op test is model-relative, not reader-relative. Two people disagreeing over whether a line is a no-op disagree about the default, and settle it by running the skill, not by arguing.

## Prose edits

Pass 8, applied sentence by sentence to whatever survived passes 1–7.

| Move | Before → after |
|---|---|
| Bullet by default | A list of peers written as prose pays for its connectives. Keep a sentence only where _because / unless / then / so that_ carries behaviour the bullet would drop — a bullet states a rule, a sentence states a rule's condition. |
| Delete qualifiers | _actually, really, basically, very, somewhat, kind of, extremely_ — "It would really be a very good idea" → "We should" |
| Delete implied modifiers | the verb already carries the meaning: "anticipate in advance" → "anticipate"; "completely revolutionize" → "revolutionize" |
| Unwind preposition chains | four or more _in/for/at/on/through/over_ links means the sentence is built wrong; rewrite it whole rather than tinkering. "The reason for the failure of the basketball team of the University…" → "UNC's team lost because…" |
| Flip negatives positive | "do not have more than five years" → "have fewer than five years". A negative costs extra words and makes the reader do the inversion. |
| Put the doer first | "The constitution was written by John Adams" → "John Adams wrote the constitution". Passive is not wrong, only wordier — keep it where the doer is unknown, irrelevant, or the agent itself. |

Two more moves from the same tradition already have homes upstream, and running them here duplicates work: redundant pairs ("each and every" → one of them) belong to pass 3, and phrase-for-word swaps ("due to the fact that" → "because") to pass 4, where a leading word does the same job harder.

## Why the passes are ordered this way

**Delete before rewrite.** Extractive compression — dropping tokens and keeping the rest verbatim — keeps a compressed prompt faithful to the original; the LLMLingua line of work builds compressors as token _classification_ rather than generation for exactly this reason, and reports capability preserved at high compression ratios. Paraphrase is generative, so it can drift meaning while appearing to save tokens. Pass 8 is the one place brew rewrites anyway, and it runs last for that reason: by then the structural passes have removed everything a rewrite might have destroyed the evidence for, and each rewritten sentence goes back through the no-op test. A sentence that changed behaviour under pass 8 has drifted, not compressed — restore it.

**Budget by fragility, not uniformly.** LLMLingua's budget controller allocates compression unevenly across a prompt rather than squeezing every region equally. The degrees-of-freedom table in SKILL.md is the same idea applied by hand: fragile, one-right-sequence material keeps its detail; open-ended material compresses to direction. The two errors are not equally visible: over-specifying an open task shows up as the agent doing the wrong thing, while under-specifying a fragile one shows up only as variance across runs, so testing a single run misses it.

**There is a floor, and it is task-dependent.** In a large-scale annotation experiment, concise prompts matched or beat verbose ones on sentiment while _losing_ accuracy on toxicity — a harder, more nuanced judgement. Compaction is therefore not monotone: it wins where the model has strong priors and loses where the task is unfamiliar. This is why pass 7 is a stopping rule rather than another cut.

**Notation costs accuracy, and consistency costs the least.** Formatting choice alone swings accuracy on a fixed task — a Microsoft/MIT study reports up to ~40 points on GPT-3.5-turbo, and FormatSpread reports up to 76 points of spread on Llama-2-13B. Markdown runs roughly 15% leaner than equivalent XML for prose, since XML pays for closing tags. Since no single format wins everywhere, pick one and hold it: mixing notations in one file is worse than either choice made consistently.

**Only include what the agent does not already know.** Anthropic's skill-authoring guidance: challenge each piece with "does the agent really need this explanation?", keep SKILL.md under 500 lines, keep disclosed references one level deep so partial reads still see the whole scope, and give one recommended option with an escape hatch rather than a menu.

**Budget in tokens, not lines.** 500 lines is a ceiling a well-brewed SKILL.md never approaches — a skill can sit far under it and still burn the window on prose the agent skims. ~1000 tokens is the working target, and the miss is diagnostic: over it, the skill is usually carrying reference that belongs behind a pointer (pass 5) or rationale that belongs to a human reader (pass 2). Shaving words to fit is the one wrong response — it trades behaviour for a number while pass 7's floor is the only cut that should ever bind.

**Structure is not prose.** Pass 1 forbids paraphrase because paraphrase drifts meaning under cover of saving tokens. Reordering, re-heading and re-bulleting move no meaning, so they carry no drift risk — an existing skill whose layout fights the hierarchy is cheaper rebuilt from zero than compressed in place. The cost is auditability: a from-zero rebuild has no line-by-line cut list, so it owes a behaviour delta instead.
