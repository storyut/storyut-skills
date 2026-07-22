# storyut-skills

Agent skills for Claude Code — and a maintained port of the big ones to OpenAI Codex.

These are small, hackable text files, not a framework. Each skill is one `SKILL.md`: YAML frontmatter that tells the agent *when* to fire, and instructions that tell it *what process to follow*. You are meant to read them, disagree with them, and edit them.

The design goal throughout is **predictability of process**, not identical output. A good skill makes the agent take the same steps every run — the answer can differ, the method shouldn't.

## Install

There is no installer and no build. Copy the directories you want into your skills folder:

```bash
git clone https://github.com/storyut/storyut-skills.git

# Claude Code — user-wide
cp -r storyut-skills/tldr ~/.claude/skills/
cp -r storyut-skills/brew ~/.claude/skills/

# ...or per-project
cp -r storyut-skills/fablely-skill/fablely .claude/skills/
```

Note the fablely skills live one level down, in `fablely-skill/` — copy the individual skill directories out of it, not the folder itself.

For Codex, copy from `fablely-skill-codex/` into `~/.codex/skills/` instead — see [`fablely-skill-codex/README.md`](fablely-skill-codex/README.md).

Invoke a skill by typing its name as a slash command (`/tldr`, `/brew`), or just describe the task and let the agent pick it up from the `description` field.

## What's here

### The fablely family — project continuity

The reason this repo exists. Long-running work dies from amnesia: the session gets interrupted, the context gets compacted, and the next session confidently rebuilds something that already exists or reports "done" on something it never ran.

fablely fixes that by keeping truthful state on disk in a `.fable/` directory, under one rule: **no claim is stronger than the evidence actually observed.** "The test suite passes" means you watched it pass, not that the code looks right.

| Skill | What it does |
|---|---|
| [`fablely`](fablely-skill/fablely/SKILL.md) | The orchestrator. Triages incoming requests by size, runs the work-unit lifecycle, enforces intent-before-edit and PROGRESS-before-stop. Bootstraps `.fable/` into a project, or adopts an existing one. |
| [`fablely-spec`](fablely-skill/fablely-spec/SKILL.md) | Turns a fuzzy request into one settled file — design, spec, and plan together. It grills you; it does not execute. |
| [`fablely-arch`](fablely-skill/fablely-arch/SKILL.md) | Scans for *deepening opportunities*: refactors that put more behaviour behind smaller interfaces. Proposes ranked candidates, hands the chosen one to `fablely-spec`. |
| [`fablely-ask`](fablely-skill/fablely-ask/SKILL.md) | The Consult lane. Answers questions about the project and touches nothing — no intent stamp, no PROGRESS write, no edits. |
| [`fablely-debug`](fablely-skill/fablely-debug/SKILL.md) | A diagnosis loop for hard bugs and perf regressions: build a tight feedback loop first, then spend it on bisection and hypotheses. Works standalone; plugs into fablely when `.fable/` exists. |

Projects get a `.fable/STANDARDS.md` — the quality bar as numbered clauses (`SEC-1`, `ERR-2`) that are referenced while the work is being *designed*, not applied as a gate afterward. An open finding blocks the unit until it's fixed or waived by an auditable `DECISIONS.md` entry.

Claude Code and Codex versions share a frozen `.fable/` format, so a project bootstrapped by one harness resumes cleanly under the other.

### Writing and thinking

| Skill | What it does |
|---|---|
| [`brew`](brew/SKILL.md) | **The meta-skill.** Write a new skill, or brew an existing one down to the fewest tokens that still hold its behaviour. This is the house style the rest of the repo is written in. |
| [`brainstorm`](brainstorm/SKILL.md) | A 50/50 brainstorm — the agent generates roughly half the ideas, in alternating turns, with no judgment until convergence. `--deep` adds a parallel silent-divergence phase; `--auto` hands the whole generation half over. |
| [`fable-prompter`](fable-prompter/SKILL.md) | Turns a vague idea ("build me something for the data") into a production prompt for Claude Fable 5. Fog is expected input, not a complaint. |
| [`be-a-human-zh`](be-a-human-zh/SKILL.md) | 写、改、重写中文，消灭 AI 味。Hard banned-phrase rules, not vibes. |

### Everyday

| Skill | What it does |
|---|---|
| [`ask`](ask/SKILL.md) | Answer a question, read-only, from the codebase / web / official docs. Explicitly ignores whatever workflow the project wants to impose. |
| [`tldr`](tldr/SKILL.md) | Exactly 5 sentences, one bolded takeaway, one verdict line. Not 4, not 6. |
| [`wakaranai`](wakaranai/SKILL.md) | Explains the same thing three times — beginner, practitioner, expert — so you can find the depth you actually needed. |
| [`wiztree-cleaner`](wiztree-cleaner/SKILL.md) | Reads a WizTree CSV disk export and proposes what's safe to delete. Windows-specific. |

## How these are written

If you plan to fork or write your own, [`brew/SKILL.md`](brew/SKILL.md) is the whole philosophy, and it's short:

- **Write agent-first.** The reader parses; it is not persuaded. No motivational preamble, no restating the task back.
- **Fewest tokens that hold the behaviour.** Every line is context cost on every invocation. Detail belongs in `references/`, linked so it loads only when needed.
- **The `description` is the trigger.** It has to name both what the skill does *and* when to use it, or the agent won't fire it at the right moment.
- **`disable-model-invocation: true`** when a skill should only ever run because a human typed it.

Layout of a skill:

```
<skill-name>/
  SKILL.md            # required — frontmatter + instructions
  references/         # optional — loaded on demand
  templates/          # optional — files the skill writes into your project
```

## Notes

- The fablely skills are grouped under `fablely-skill/` (Claude Code) and `fablely-skill-codex/` (Codex); the standalone skills sit at the repo root.
- Everything is MIT-ish in spirit: take it, fork it, cut the parts you disagree with.
- The Codex port is actively kept in sync with the Claude Code originals; known intentional divergences are listed in [`fablely-skill-codex/README.md`](fablely-skill-codex/README.md).
