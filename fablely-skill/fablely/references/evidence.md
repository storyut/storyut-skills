# Evidence hierarchy

The rule: a claim may only be reported at the strength of the evidence backing it. Not stronger — not "should work" dressed up as "works." If the evidence is weak, the claim has to say so.

## Evidence levels

Strongest first.

### 1. Observed behavior

You drove the real flow and saw the result yourself.

> Verified: submitted the signup form against the dev server; the confirmation email arrived and the row exists in `users`.

### 2. A test watched fail, then pass

You wrote or modified a test, watched it fail against the old code, then watched it pass against the fix. The observed failure is what proves the test can detect the bug at all — without it, a passing test is unfalsified.

> Covered by a test I watched fail before the fix and pass after.

### 3. Targeted passing checks

Relevant tests and assertions passed, but you did not establish causality or observe the complete behavior. This supports a narrow claim about those checks.

> The focused rounding tests passed; I did not exercise checkout end-to-end.

### 4. Static inspection

You inspected code or validated configuration without running the behavior.

> Static validation passed and the configured timeout is 15 seconds; runtime behavior was not exercised.

### 5. Unverified

A hypothesis or recollection. Inspect before relying on it and label it plainly if reported.

## Consequences

- **Green is bounded evidence.** A passing test proves its assertions passed in that run. It does not prove causality or unasserted behavior.
- **Read inherited tests before relying on them.** Prefer a focused red/green regression when practical, but never damage user code merely to manufacture red.
- **"Tests pass" is a claim about tests, not a claim that the feature works.** The two sentences are not interchangeable, and the second must never be reported on the strength of the first alone.
- **Prefer behavioral completion when feasible.** If environment, authority, or cost prevents it, report the strongest check actually run and the remaining gap.
- **When a test lies** — passes while the code is broken, or covers only the happy path so a broken branch slips through — append it to `LESSONS.md` at that moment, with the test name and how it lied.

Worked example of a lying-test `LESSONS.md` entry:

```markdown
## 2026-07-14 — `test_refund_applies_balance` lies on partial refunds

**What happened:** The test only asserted the full-refund path. A partial-refund
bug shipped (balance went negative) with this test green the whole time, because
it never called the function with a partial amount.

**The lesson:** A test named after the feature, not the specific case, hides
which cases are actually covered. Check the assertions, not the test name,
before trusting a green suite.

**Applies when:** Reviewing any inherited test before relying on it as evidence,
especially ones with broad names like `test_refund_*` or `test_checkout_works`.
```

## Phrases that should stop you

If you're about to write any of these, stop — each one means "go get evidence one level stronger, or report the claim one level weaker":

- "should work"
- "I'm confident"
- "the tests confirm the feature works"
- "as implemented earlier" (uninspected recollection)
