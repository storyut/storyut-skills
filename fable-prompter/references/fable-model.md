# Fable 5 — Model Behavior & Anti-Patterns

Read this when you need to justify a prompt decision, or when migrating a prompt written for an older Claude model.

## What Makes Fable 5 Different

Claude Fable 5 is Mythos-class — built for complex, long-running, autonomous, multi-step work. Four properties drive every prompting decision:

**Always-on adaptive thinking.** Thinking cannot be disabled and scales itself to the problem. Asking for chain-of-thought is redundant at best; at worst, phrasing that asks the model to expose its reasoning process can trigger a `reasoning_extraction` refusal.

**High instruction fidelity.** Fable follows instructions reliably without being bullied. The scaffolding older prompts needed — "CRITICAL", "YOU MUST ALWAYS", triple-repeated rules — now actively hurts. Over-emphasis causes over-triggering: the model applies the rule in situations where it shouldn't, and becomes rigid where you wanted judgment.

**Concise and proactive by default.** It prioritizes results over narration and will plan autonomously. Prompts that micromanage fight the model's grain.

**Effort as the primary dial.** Effort — not prompt length, not emphasis — is how you buy intelligence. `low`/`medium` for routine work, `high` as the default, `x-high` for genuinely hard reasoning.

## Anti-Patterns

### Don't shout
```
✗  "CRITICAL: You MUST ALWAYS follow these rules WITHOUT EXCEPTION."
✓  "Follow these rules:"
```

### Don't ask for chain-of-thought
```
✗  "Think step by step before answering."
✓  (Just ask the question.)
```

### Don't over-specify steps
```
✗  "Step 1: Open the file. Step 2: Find line 42. Step 3: Replace 'foo' with 'bar'."
✓  "Replace all instances of 'foo' with 'bar' in the configuration module."
```
Prescribe steps only when *ordering* is load-bearing for correctness — database migrations, deployment sequences, anything where doing B before A produces a wrong result.

### Don't write character backstories
```
✗  "You are an ancient AI wizard named Merlin who speaks in riddles..."
✓  "You are a senior security engineer."
```
Roles should be high-level but domain-specific. That triggers the model's internalized reasoning patterns for the domain without adding noise.

### Don't omit the Why
```
✗  "Convert this to TypeScript."
✓  "Convert this to TypeScript. We're migrating the frontend to strict TS to
    catch type errors at compile time and improve IDE autocompletion for the team."
```
This is the single highest-leverage line in most prompts. Fable is dramatically better at choosing the right approach when it knows the purpose and the audience.

## Self-Verification

Fable will report completion honestly if you give it the standard:

```xml
<verification>
Before reporting completion:
- Audit each claim against a tool result from this session.
- Only report work you can point to evidence for.
- If something is not verified, say so explicitly.
- Do not report success you cannot prove.
</verification>
```

## Migration Checklist (from Opus 4.8 / Sonnet 5 / earlier)

- [ ] Remove "think step-by-step" — thinking is always-on.
- [ ] Tone down emphasis — replace CRITICAL/MUST/ALWAYS with plain language.
- [ ] Remove redundant guardrails — trim scaffolding that existed to force compliance.
- [ ] Convert step-by-step scripts to goals.
- [ ] Add the Why — purpose, audience, consequence of getting it wrong.
- [ ] Add a `<verification>` block.
- [ ] Add a `<delegation>` block — Fable orchestrates, Sonnet/Haiku implement.
- [ ] Set an appropriate effort level; don't default to `x-high`.
- [ ] Keep the XML structure. Don't abandon it.
- [ ] Simplify roles to functional identities.
- [ ] Add explicit completion criteria.
