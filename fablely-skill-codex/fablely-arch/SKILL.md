---
name: fablely-arch
description: Scan a fablely project for deepening opportunities — refactors that turn shallow modules into deep ones — present ranked candidates, and hand the chosen one to fablely-spec.
---

# fablely-arch

Surface architectural friction and propose **deepening opportunities** — refactors that put more behaviour behind smaller interfaces. The aim is testability and navigability. You scan and propose; design belongs to `fablely-spec` and execution to the fablely work-unit lifecycle.

## Vocabulary

Use these terms exactly — not "component", "service", "API", or "boundary". Consistent language is the point:

- **Module** — anything with an interface and an implementation; scale-agnostic (function, class, package, tier-spanning slice).
- **Interface** — everything a caller must know to use the module correctly: the signature plus invariants, ordering constraints, error modes, required configuration, performance characteristics.
- **Depth** — leverage at the interface: how much behaviour a caller (or test) can exercise per unit of interface learned. Deep = a lot behind a little; shallow = interface nearly as complex as the implementation.
- **Seam** — a place where behaviour can be altered without editing in that place; the location where a module's interface lives.
- **Adapter** — a concrete thing satisfying an interface at a seam. A role, not a substance.
- **Leverage** — what callers get from depth: one implementation paying back across N call sites and M tests.
- **Locality** — what maintainers get from depth: change, bugs, knowledge, and verification concentrate in one place.

Principles: **the deletion test** — imagine deleting the module; if complexity vanishes it was a pass-through, if it reappears across N callers it was earning its keep. **The interface is the test surface** — wanting to test *past* the interface means the module is probably the wrong shape. **One adapter = a hypothetical seam, two = a real one** — don't introduce a seam nothing actually varies across.

## Process

### 1. Explore

Scope before you scan — deepening pays off where change happens, so weight the parts of the codebase that change. If the user named a direction — a module, a subsystem, a pain point — take it. Otherwise walk back the commit history (`git log --oneline`) for hot spots and let those paths pull attention first; if changes are scattered with no hot spot, widen the net.

Read `.fable/MISSION.md` for what the project is, `MAP.md` for where things live, and `DECISIONS.md` for settled calls you must not re-litigate.

Then walk the codebase — with subagents available (`spawn_agent`), dispatch one to do the walking — organically, not by rigid heuristics, noting friction:

- Understanding one concept requires bouncing between many small modules.
- Shallow modules — interface nearly as complex as the implementation.
- Pure functions extracted "for testability" while the real bugs hide in how they're called (no locality).
- Tightly-coupled modules leaking across their seams.
- Parts untested, or hard to test through their current interface.

Apply the deletion test to anything suspected shallow — "yes, deleting concentrates complexity" is the signal you want.

### Failure routing

| Trigger | First response | If still unresolved |
|---|---|---|
| Subagents are unavailable or not permitted | Explore inline with the same read-only brief | Narrow the scan to the user-named area or the strongest history-backed path; do not stall or imply delegation occurred. |
| History has no usable hot spot | Use MISSION, MAP, tests, and current call sites to select a bounded area | Label confidence as limited; do not invent a change-frequency claim. |
| No candidate passes the deletion and one-adapter tests | Report that no evidence-backed deepening opportunity was found | Stop without manufacturing a speculative candidate. |
| A candidate conflicts with DECISIONS | Drop it unless observed friction justifies reopening the decision | If justified, name the dated decision and the concrete evidence for reopening it. |

### 2. Present candidates

Present candidates directly in your reply as markdown — no report file, nothing written to the tree. For each:

- **Files** — the modules involved
- **Problem** — the friction the current shape causes
- **Solution** — plain-English description of what would change
- **Benefits** — in terms of locality and leverage, and how tests improve
- **Before / after** — a compact text sketch of the interface each way
- **Strength** — `Strong` / `Worth exploring` / `Speculative`

Use the project's own names from MISSION/MAP for the domain and the vocabulary above for the architecture. If a candidate contradicts a `DECISIONS.md` entry, surface it only when the friction genuinely warrants revisiting the decision, and mark it plainly: *"contradicts 2026-05-02 — worth reopening because…"*. Don't list every theoretical refactor a decision forbids.

End with the one candidate you'd tackle first and why, then ask which the user wants to explore. Do **not** propose concrete interfaces yet — that's design work, and it happens in the grilling.

**CHECKPOINT · STOP:** wait for the user to select a candidate. Do not enter `fablely-spec`, write a DECISIONS entry, or mutate project files before that selection.

### 3. Handoff

The chosen candidate goes to `fablely-spec`, which grills the design — constraints, the shape of the deepened module, what sits behind the seam, which tests survive — and writes the work unit. Execution then follows the fablely lifecycle.

When the user rejects a candidate for a load-bearing reason, offer to append it to `DECISIONS.md` so future scans don't re-suggest it. Skip ephemeral reasons ("not worth it right now") and self-evident ones.
