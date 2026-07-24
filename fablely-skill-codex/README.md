# fablely for Codex (GPT-5.6)

A port of the `fablely` family of Claude Code skills to OpenAI Codex, restructured per OpenAI's GPT-5.6 prompting guidance (outcome-first, leaner, decision rules over scaffolding).

The five skills are published under `-codex`-suffixed names — `fablely-codex`, `fablely-spec-codex`, `fablely-arch-codex`, `fablely-ask-codex`, `fablely-debug-codex` — so they can be installed alongside the Claude Code originals without colliding. The `.fable/` directory format is identical either way.

## Install

1. Install the family:

   ```bash
   npx skills add storyut/storyut-skills --skill 'fablely-codex,fablely-spec-codex,fablely-arch-codex,fablely-ask-codex,fablely-debug-codex'
   ```

   Or copy the five skill directories into `~/.codex/skills/` by hand.

2. (Recommended) Enable subagents so fablely can run its orchestrator/fresh-eyes-reviewer workflow. In `~/.codex/config.toml`:

   ```toml
   [features]
   multi_agent = true
   ```

   Without this, fablely still works — it falls back to inline implementation with a spec-vs-diff self-review instead of a reviewer subagent.

3. Invoke with `/fablely-codex` in a project directory (or `/fablely-spec-codex` to spec a unit directly, `/fablely-ask-codex` for an explicit read-only Consult). Projects bootstrapped by fablely get an `AGENTS.md` that tells every future Codex session to load the skill and read `.fable/PROGRESS.md` automatically.

## What changed from the Claude Code version

- **Hooks removed.** Codex has no SessionStart/PreToolUse/Stop hooks, so the three PowerShell hook scripts and their settings block are gone. Auto-resume now rides on the project `AGENTS.md` (always loaded by Codex); the intent-before-edit and PROGRESS-before-stop rules are explicit prose contract instead of mechanical gates.
- **`CLAUDE.md.template` → `AGENTS.md.template`.** Bootstrap writes `AGENTS.md`; Adopt appends the contract section to an existing one.
- **`.fable/.session-start` dropped** (it only served the hooks). `.fable/.intent` is kept as the auditable per-task size declaration.
- **Delegation is conditional.** With `multi_agent = true`, fablely orchestrates and dispatches implementation to subagents as before; without it, it works inline under the same discipline, and the fresh-eyes reviewer degrades to a strict spec↔diff mapping self-review.
- **Prose is harness-adapted, not line-mirrored.** Both families follow the same token discipline; Codex keeps outcome-first ordering and decision rules suited to GPT-5.6. Behavioral rules stay synchronized while wording may differ.
- **`.fable/` format is unchanged.** Projects are fully interoperable with the Claude Code version of fablely: either harness can resume or adopt a project the other bootstrapped.

## The standards bar

Both versions carry `.fable/STANDARDS.md` — the project's quality rubric, as clauses with stable IDs (`SEC-1`, `ERR-2`, `PRJ-3`). It is deliberately not a final gate. The bar is referenced at four points, so work is written to it rather than corrected up to it afterward:

| Phase | Touchpoint |
|---|---|
| Thinking | a Small Intent's `Done when` names the clause IDs at risk |
| Speccing | every work unit carries a **Clears the bar** block, grilled before the file is accepted |
| Implementing | the at-risk clauses are pasted into the implementation brief as hard requirements |
| Reviewing | a third review axis, and the only one with veto power |

Enforcement is identical across both harnesses and needs no hooks: an open standards finding blocks the work unit — status does not flip to `done` and no checkpoint commit happens — until it is fixed or waived by a `DECISIONS.md` entry naming the clause. That keeps Codex and Claude Code behaviorally equivalent, and keeps waivers auditable instead of conversational.
