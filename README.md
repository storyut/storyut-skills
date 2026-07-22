# storyut-skills

Agent skills for Claude Code, plus a maintained port of the big ones to OpenAI Codex.

[简体中文](README.zh-CN.md)

## Install

With [`npx skills`](https://github.com/vercel-labs/skills), which lists them for you to pick from:

```bash
npx skills add storyut/storyut-skills
```

Or take specific ones, globally instead of per-project:

```bash
npx skills add storyut/storyut-skills --skill 'tldr,brew' --global
```

All 18 skills are exposed, including both fablely families. The Codex port is published under `-codex`-suffixed names (`fablely-codex`, `fablely-spec-codex`, …) so it installs alongside the Claude Code originals without colliding.

You don't need the installer either. The files are the product, so cloning and copying works just as well:

```bash
git clone https://github.com/storyut/storyut-skills.git
cp -r storyut-skills/tldr ~/.claude/skills/
cp -r storyut-skills/fablely-skill/fablely .claude/skills/   # fablely lives one level down
```

Invoke a skill by typing its name as a slash command (`/tldr`, `/brew`), or just describe the task and let the agent pick it up from the `description` field.

## What's here

### The fablely family: project continuity

The reason this repo exists. Long-running work dies from amnesia: the session gets interrupted, the context gets compacted, and the next session confidently rebuilds something that already exists or reports "done" on something it never ran.

fablely fixes that by keeping truthful state on disk in a `.fable/` directory, under one rule: **no claim is stronger than the evidence actually observed.** "The test suite passes" means you watched it pass, not that the code looks right.

| Skill | What it does |
|---|---|
| [`fablely`](fablely-skill/fablely/SKILL.md) | The orchestrator. Triages incoming requests by size, runs the work-unit lifecycle, enforces intent-before-edit and PROGRESS-before-stop. Bootstraps `.fable/` into a project, or adopts an existing one. |
| [`fablely-spec`](fablely-skill/fablely-spec/SKILL.md) | Turns a fuzzy request into one settled file: design, spec, and plan together. It grills you; it does not execute. |
| [`fablely-arch`](fablely-skill/fablely-arch/SKILL.md) | Scans for *deepening opportunities*: refactors that put more behaviour behind smaller interfaces. Proposes ranked candidates, hands the chosen one to `fablely-spec`. |
| [`fablely-ask`](fablely-skill/fablely-ask/SKILL.md) | The Consult lane. Answers questions about the project and touches nothing: no intent stamp, no PROGRESS write, no edits. |
| [`fablely-debug`](fablely-skill/fablely-debug/SKILL.md) | A diagnosis loop for hard bugs and perf regressions: build a tight feedback loop first, then spend it on bisection and hypotheses. Works standalone; plugs into fablely when `.fable/` exists. |

Projects get a `.fable/STANDARDS.md`, the quality bar as numbered clauses (`SEC-1`, `ERR-2`) that are referenced while the work is being *designed*, not applied as a gate afterward. An open finding blocks the unit until it's fixed or waived by an auditable `DECISIONS.md` entry.

#### Why there's a Codex port

Because continuity that only survives inside one vendor's tool isn't continuity.

The whole premise of fablely is that project state lives on disk, not in a context window. That is what lets a fresh session pick up where the last one died. But if that state is only legible to Claude Code, you've just moved the amnesia one level up: switch to Codex for a session and you're back to re-deriving what was already decided. Models also change, and harnesses come and go faster than the projects they're used on.

So `.fable/` is treated as a frozen, harness-neutral format, and both ports read and write it identically. A project bootstrapped by Claude Code resumes cleanly under Codex and vice versa. You can switch mid-project, or use whichever one is better at the task in front of you, without losing the thread.

What differs is only what has to. The Codex port is restructured for GPT-5.6 (outcome-first, decision rules over scaffolding, roughly a third shorter), and Codex has no lifecycle hooks, so guarantees that ride on hooks in Claude Code ride on `AGENTS.md` prose instead. Behaviour is ported; the wording is not. The divergences are deliberate and [documented](fablely-skill-codex/README.md).

### Writing and thinking

| Skill | What it does |
|---|---|
| [`brew`](brew/SKILL.md) | **The meta-skill.** Write a new skill, or brew an existing one down to the fewest tokens that still hold its behaviour. This is the house style the rest of the repo is written in. |
| [`brainstorm`](brainstorm/SKILL.md) | A 50/50 brainstorm. The agent generates roughly half the ideas, in alternating turns, with no judgment until convergence. `--deep` adds a parallel silent-divergence phase; `--auto` hands the whole generation half over. |
| [`fable-prompter`](fable-prompter/SKILL.md) | Turns a vague idea ("build me something for the data") into a production prompt for Claude Fable 5. Fog is expected input rather than a complaint. |
| [`be-a-human-zh`](be-a-human-zh/SKILL.md) | 写、改、重写中文，消灭 AI 味。Hard banned-phrase rules rather than vibes. |

### Everyday

| Skill | What it does |
|---|---|
| [`ask`](ask/SKILL.md) | Answer a question, read-only, from the codebase / web / official docs. Explicitly ignores whatever workflow the project wants to impose. |
| [`tldr`](tldr/SKILL.md) | Exactly 5 sentences, one bolded takeaway, one verdict line. Not 4, not 6. |
| [`wakaranai`](wakaranai/SKILL.md) | Explains the same thing three times (beginner, practitioner, expert) so you can find the depth you actually needed. |
| [`wiztree-cleaner`](wiztree-cleaner/SKILL.md) | Reads a WizTree CSV disk export and proposes what's safe to delete. Windows-specific. |

## How these are written

If you plan to fork or write your own, [`brew/SKILL.md`](brew/SKILL.md) is the whole philosophy, and it's short:

- Write agent-first. The reader parses; it is not persuaded. No motivational preamble, no restating the task back.
- Fewest tokens that hold the behaviour. Every line is context cost on every invocation. Detail belongs in `references/`, linked so it loads only when needed.
- The `description` is the trigger. It has to name both what the skill does *and* when to use it, or the agent won't fire it at the right moment.
- `disable-model-invocation: true` when a skill should only ever run because a human typed it.

Layout of a skill:

```
<skill-name>/
  SKILL.md            # required: frontmatter + instructions
  references/         # optional, loaded on demand
  templates/          # optional, files the skill writes into your project
```

## Notes

- The fablely skills are grouped under `fablely-skill/` (Claude Code) and `fablely-skill-codex/` (Codex); the standalone skills sit at the repo root.
- The Codex port is actively kept in sync with the Claude Code originals; known intentional divergences are listed in [`fablely-skill-codex/README.md`](fablely-skill-codex/README.md).
- `.claude-plugin/marketplace.json` declares the two fablely families so `npx skills` can find them. The CLI walks the repo root only one level deep, so skills nested at `fablely-skill/<name>/` are invisible without it. Paths in that file **must** start with `./`, or the CLI silently skips the whole manifest.

## License

[MIT](LICENSE). Take it, fork it, cut the parts you disagree with.
