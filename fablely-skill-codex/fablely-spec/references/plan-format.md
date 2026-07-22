# Plan format

The Plan section of a `.fable/work/NNN-slug.md` file. Write it assuming the executor has zero context for this codebase and questionable taste: a skilled developer who knows almost nothing about this toolset, this domain, or good test design. Everything they need to build it *correctly* must be on the page — which files, what contract each piece honors, what commands prove it. Plans are contracts, not transcripts: the executor writes the code, the plan specifies what it must satisfy.

## Size gate — read before choosing a shape

A Plan section rivaling the size of the diff it describes has crossed into writing the software twice. This is a format error, not a style note. If a task's code is longer than the interface and test-case lines around it, cut back to a contract.

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
- "Write the minimal code to pass" — step
- "Run it, confirm it passes" — step

## How much code

Default — a full-form unit — give the executor a contract, not a transcript:

- **Files:** exact Create/Modify/Test paths.
- **Interfaces:** exact signatures — types, parameter names, return types.
- **Test cases:** concrete, stated as input → expected observable behavior — not test code.
- **Run commands:** exact command, exact expected output (or expected failure reason).

No full implementation bodies. No full test-code blocks. The executor is GPT-5.6/Sonnet-class — it can write a function from a signature and a test case; it does not need the software written twice.

**Escalate to inline literal code** only where a competent executor could plausibly guess wrong and the mistake is expensive: a tricky algorithm, a security-sensitive check, a subtle concurrency case, an exact wire/serialization format. Name the trigger when you use it — a code block belongs in a plan because guessing there is dangerous, not by default.

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

- [ ] **Step 1: Write a failing test** — `test_specific_behavior`: input `<value>` → expected `<observable result>`.
- [ ] **Step 2: Run** `pytest tests/path/test.py::test_specific_behavior -v`, expected: FAIL with "function not defined".
- [ ] **Step 3: Implement `function(input)` to satisfy the contract above** (see Interfaces for the exact signature; return `<expected>` for `<input>`).
- [ ] **Step 4: Run** `pytest tests/path/test.py::test_specific_behavior -v`, expected: PASS.
````

Where the escalation trigger applies (tricky algorithm, security check, concurrency edge, wire format), put the literal code inline in that step instead of a one-line description — the one case a plan should read like a transcript.

Commits are not per-task: fablely checkpoints once per completed work unit, tests green, on a work branch. The plan's final task ends with the unit's Completion checklist, not a string of intermediate commits.

## No placeholders

Every step must contain the actual contract the executor needs — not full code, but not vague either. These are plan failures — never write them:

- "TBD", "TODO", "implement later", "fill in details"
- "Add appropriate error handling" / "add validation" / "handle edge cases" — name the exact error cases and the expected behavior for each
- "Write tests for the above" without the concrete test case (input → expected behavior)
- "Similar to Task N" — repeat the interface; tasks may be read out of order. Repeating a full body is exactly what risk-scaling exists to avoid
- Steps that describe *what* to do without the contract that proves it (paths, signatures, commands, expected output)
- References to types, functions, or methods not defined in any task's Interfaces block

## Global constraints

If the spec carries project-wide requirements — version floors, dependency limits, naming rules, platform requirements — list them once at the top of the Plan, one line each, exact values copied verbatim. Every task's requirements implicitly include that list.

The `STANDARDS.md` clauses named in Clears-the-bar belong in that list, quoted in full rather than by ID. The list travels into implementation briefs; a bare `SEC-3` means nothing to an executor who cannot open the file. Where a clause binds one specific task, restate it in that task's requirements too — a constraint listed only at the top is a constraint the executor read once, ten tasks ago.

## Self-review

After writing the complete plan, check it against the Spec section with fresh eyes. This is a checklist you run yourself, before showing the file to the user:

1. **Spec coverage.** Skim each spec line. Can you point to a task that implements it? Add tasks for any gap.
2. **Placeholder and over-specification scan.** Search the plan for every pattern in "No placeholders" above, and for any code block that exceeds the escalation trigger in "How much code" — cut it back to a contract. Is the plan in full form when the size gate called for light? Collapse it.
3. **Type consistency.** Do names and signatures used in later tasks match what earlier tasks defined? `clearLayers()` in Task 3 but `clearFullLayers()` in Task 7 is a bug in the plan.
4. **Bar coverage.** For each clause in Clears-the-bar, point at the task whose steps actually produce the thing the reviewer will check. A clause claimed in the design but implemented by no step is how a unit reaches review already failing.

Fix issues inline and move on — no re-review loop.
