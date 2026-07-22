# Standards

<!-- The project's quality bar. Read before designing, cited while speccing,
     injected into implementation briefs, enforced at review.

     Every clause has a stable ID. Cite IDs — in a work unit's "Clears the bar"
     block, in an Intent's "Done when", and in review findings. A clause with no
     ID cannot be cited, and a bar nobody can cite is decoration.

     Trim this file to the project. A clause that doesn't apply here should be
     deleted or moved to Not applicable with a reason, not left to be ignored —
     a rubric that is routinely ignored teaches that the whole file is optional.
     Add project-specific clauses freely; keep each one falsifiable. -->

## Security

- **SEC-1 — Untrusted input is validated at the boundary.** Parse and constrain
  input where it enters, not at each use site. Reject rather than coerce.
- **SEC-2 — No secret reaches a log, an error message, an ordinary trace, or the
  repository.** Credentials come from configuration or a secret store.
- **SEC-3 — Queries and commands are parameterized.** No string-built SQL,
  shell, or path from any value that was not literal in the source.
- **SEC-4 — Authorization is checked on the server, per request, on the object
  being acted upon.** A client-side check is a convenience, never the control.
- **SEC-5 — Errors fail closed.** An exception on the authorization or
  validation path denies; it does not fall through to the allowed branch.

## Correctness and errors

- **ERR-1 — Errors are handled or propagated deliberately.** No empty catch, no
  swallowed rejection, no ignored error return. If a case is genuinely
  unreachable, say so in a comment and fail loudly if it is reached.
- **ERR-2 — Every branch the spec names has a test, including the failure
  branches.** Happy-path-only coverage is the exact shape that lies.
- **ERR-3 — Partial failure leaves no half-written state.** Multi-step mutations
  are ordered so an interruption is recoverable, or made atomic.
- **ERR-4 — Boundary conditions are decided, not discovered.** Empty, one,
  many, absent, malformed, and concurrent are each answered somewhere.

## Design and idioms

- **IDM-1 — Follow the language's and the repo's existing idiom** over the one
  imported from another ecosystem. Match the surrounding code.
- **IDM-2 — Modules are deep:** a small interface hiding real work. A new
  abstraction that mostly forwards is not earning its keep.
- **IDM-3 — Names state what the thing is or does,** at the caller's level of
  abstraction, without needing the implementation to decode.
- **IDM-4 — No speculative generality.** Build what the spec asks for. Options,
  hooks, and layers for imagined future needs are deleted.
- **IDM-5 — Public interfaces are the narrowest thing that satisfies the spec.**
  Widening later is cheap; narrowing after adoption is not.

## Operability

- **OPS-1 — Failures are diagnosable from what the system records.** An operator
  reading the log can tell what failed, for which input, and where.
- **OPS-2 — No unbounded work on an untrusted input path** — no unbounded loop,
  allocation, recursion, or fan-out driven by a caller-controlled size.
- **OPS-3 — Documented behavior matches actual behavior.** A change that alters
  observable behavior updates the doc that describes it in the same unit.

## Not applicable

<!-- Clause ID — why it does not apply to this project.
     e.g. "SEC-3 — no database and no shell execution in this project." -->

## Project-specific

<!-- Clauses this project adds. Same format: ID, bolded rule, falsifiable.
     Use a project prefix, e.g. PRJ-1. Promote a recurring LESSONS.md entry
     here once it has bitten twice — that is the point of the file. -->
