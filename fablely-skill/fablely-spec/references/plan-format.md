# Plan format

The Plan section of a `.fable/work/NNN-slug.md` file. Write it assuming the executor has zero context for this codebase — a skilled, Sonnet-class developer who knows almost nothing about this toolset or domain, but can write correct code from a precise contract. Give them the contract: which files, what interfaces, what test cases, what commands, what output proves each step. Don't give them the code — that's the executor's job, not the plan's.

## Size gate — read before choosing a shape

A Plan section rivaling the size of the diff it describes has crossed into writing the software twice. This is a format error, not a style note.

**Light form.** A change contained to one or two files with one obvious shape gets a flat checkbox list — no Task headers, no Files/Interfaces blocks, no per-step run/expect pairs. One line per action, ending on the command that proves the whole thing. The structure below is for units that genuinely have separable tasks a reviewer could accept or reject independently. Reaching for it by default is how a one-line change acquires a hundred-line plan.

A diagnosed bug arrives with a red loop and a minimised repro — a done criterion already executed and observable behavior already stripped to what is load-bearing. Restating those as Design and Spec prose downgrades evidence into a document. Fixes get the light form unless the fix itself is structural.

## Scope check

If the unit covers multiple independent subsystems, it should have been split into separate work units during grilling. Each unit's plan must produce working, verifiable software on its own. If you're planning two subsystems in one file, stop and split the unit first.

## File structure first

Before writing tasks, map which files will be created or modified and what each is responsible for — this locks in decomposition:

- One clear responsibility per file. Prefer smaller, focused files; edits to focused files are more reliable.
- Files that change together live together. Split by responsibility, not by technical layer.
- In existing codebases, follow established patterns. Don't unilaterally restructure — but if a file you're modifying has grown unwieldy, a split in the plan is reasonable.

## Task right-sizing

A task is the smallest unit that carries its own test cycle and is worth a fresh reviewer's gate. Fold setup, configuration, scaffolding, and docs into the task whose deliverable needs them; split only where a reviewer could reject one task while approving its neighbor. Each task ends with an independently verifiable deliverable.

Each *step* inside a task is one action, 2–5 minutes:

- "Write the failing test" — step
- "Run it, confirm it fails" — step
- "Implement to satisfy the contract" — step
- "Run it, confirm it passes" — step

## Contracts, not transcripts — full-form depth

For a full-form unit, every task carries:

- **Exact file paths** — Create / Modify / Test, with line ranges on Modify where they're known.
- **An Interfaces block** — exact function/method signatures, parameter and return types, what's consumed from earlier tasks and produced for later ones.
- **Concrete test cases** stated as input → expected observable behavior, not as literal test source.
- **Exact run commands with expected output** — the command an executor runs and what proves pass or fail.

What a default-depth plan does **not** contain: full implementation bodies, full test-code blocks. State the contract; let the executor — Sonnet-class by the delegation contract — write the code that satisfies it. A plan that hands over working code has already done the executor's job worse than the executor would have, at triple the token cost, and it now has to be kept in sync with whatever the executor actually writes.

## Escalate to literal code only when guessing is expensive

Write inline literal code — a real test body, a real implementation snippet — only where a competent executor could plausibly guess wrong *and* the mistake would be expensive to catch late:

- Tricky algorithms (non-obvious math, a specific traversal order, an easy-to-flip comparison).
- Security-sensitive checks (auth comparisons, input sanitization, permission gates).
- Subtle concurrency (lock ordering, race-prone sequencing, exactly-once semantics).
- Exact wire formats (byte layouts, header ordering, a schema the other side hard-codes).

Name the trigger when you use it — a one-clause note on why this step gets code and its neighbors don't. Everywhere else, the contract in the task structure below is the whole spec for that step.

## Task structure

Full form only — see the size gate above.

````markdown
### Task N: <component name>

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

**Interfaces:**
- Consumes: what this task uses from earlier tasks — exact signatures
- Produces: what later tasks rely on — exact function names, parameter and
  return types. An executor may see only their own task; this block is how
  they learn the names neighboring tasks use.

- [ ] **Step 1: Write a failing test** — `test_rejects_expired_token`:
  input a token with `exp` 1s in the past, expect `verify()` to raise
  `TokenExpired`.

- [ ] **Step 2: Run test to verify it fails**

  Run: `pytest tests/path/test.py::test_rejects_expired_token -v`
  Expected: FAIL with "TokenExpired not defined"

- [ ] **Step 3: Implement `verify(token: str) -> Claims` to satisfy the
  contract** — raises `TokenExpired` when `exp` has passed, `TokenInvalid`
  on bad signature, else returns `Claims`.

- [ ] **Step 4: Run test to verify it passes**

  Run: `pytest tests/path/test.py::test_rejects_expired_token -v`
  Expected: PASS
````

A step that hits the escalation trigger above gets a code block in place of its prose description; every other step stays prose-plus-contract as shown.

Commits are not per-task: fablely checkpoints once per completed work unit, tests green, on a work branch. The plan's final task ends with the unit's Completion checklist, not a string of intermediate commits.

## No placeholders

Every step must state the actual contract the executor needs — this is about precision, not about pasting code. These are plan failures — never write them:

- "TBD", "TODO", "implement later", "fill in details"
- "Add appropriate error handling" / "add validation" / "handle edge cases" — name the exact error cases and the expected behavior for each, in prose or a table; a vague gesture at "handling" is not a contract
- "Write tests for the above" without stating the concrete case (input → expected behavior)
- References to types, functions, or methods not defined in any task's Interfaces block

Repeating an **interface** across tasks is fine and often necessary — an executor working Task 7 may not have Task 3 open. Repeating a **body** ("Similar to Task N, same implementation") is the thing being killed here: if Task N's code was never written into the plan, there's nothing to repeat: point at the interface and the contract, not at another task's code.

## Global constraints

If the spec carries project-wide requirements — version floors, dependency limits, naming rules, platform requirements — list them once at the top of the Plan, one line each, exact values copied verbatim. Every task's requirements implicitly include that list.

The `STANDARDS.md` clauses named in Clears-the-bar belong in that list, quoted in full rather than by ID. The list travels into implementation briefs; a bare `SEC-3` means nothing to an executor who cannot open the file. Where a clause binds one specific task, restate it in that task's requirements too — a constraint listed only at the top is a constraint the executor read once, ten tasks ago.

## Self-review

After writing the complete plan, check it against the Spec section with fresh eyes. This is a checklist you run yourself, before showing the file to the user:

1. **Spec coverage.** Skim each spec line. Can you point to a task that implements it? Add tasks for any gap.
2. **Placeholder and depth scan.** Search the plan for every pattern in "No placeholders" above. Separately, check depth: does any step carry a full implementation or test body without hitting an escalation trigger? Cut it back to a contract. Does any escalated step *lack* a stated trigger? Add one or de-escalate. Is the plan in full form when the size gate called for light? Collapse it.
3. **Type consistency.** Do names and signatures used in later tasks match what earlier tasks defined in their Interfaces blocks? `clearLayers()` in Task 3 but `clearFullLayers()` in Task 7 is a bug in the plan.
4. **Bar coverage.** For each clause in Clears-the-bar, point at the task whose steps actually produce the thing the reviewer will check. A clause claimed in the design but implemented by no step is how a unit reaches review already failing.

Fix issues inline and move on — no re-review loop.
