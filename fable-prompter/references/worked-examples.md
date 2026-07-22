# Worked Examples — Fog to Finished Prompt

These show the whole move: a genuinely vague brief, the inference that closes the gaps, and the delivered output. Study the *inference*, not just the output.

---

## Example A — "I want something to help me keep track of my clients"

That's the entire brief. Here's the reasoning that turns it into a prompt.

**Filling the slots by inference:**

- *Outcome*: They said "keep track," not "automate" or "analyze." That's a CRUD surface — a place to put clients and see them. The smallest thing that delivers the feeling of "tracked" is a list view plus a detail view plus a way to add. Assume that.
- *Why*: Unstated, and it's the highest-leverage slot, so it earns one of the questions — but not yet. First guess: a solo operator or small team currently doing this in a spreadsheet or their head, and dropping things. That implies the real value is *not forgetting to follow up*, which implies a status field and a "last contacted" date. That inference is worth surfacing as an assumption because it shapes the data model.
- *Scope*: No auth, no billing, no email integration, no multi-user. Tight boundary; expand later.
- *Done*: They can add a client, see all of them, mark a status, and it survives a page reload.
- *Failure mode*: The model builds a sprawling CRM with fifteen entities. Guard against that in `<out_of_scope>`.

**Two questions that earn their place:** what the follow-up rhythm actually is (it determines whether this needs reminders or just a date field), and whether this is for them alone or a team (it determines whether auth exists at all). Both would substantially change the prompt. Everything else gets assumed.

**Delivered:**

````
```xml
<role>
You are a senior full-stack engineer who builds small, sharp internal tools —
the kind one person uses every day and never thinks about.
</role>

<context>
Greenfield. Single user. No existing codebase or stack commitment.
The user currently tracks clients informally and things fall through the cracks.
</context>

<objective>
A working client tracker the user can run locally: add a client, see all clients
in one list, open one to see detail, set a status, and record when they were last
contacted. Data persists across restarts.
</objective>

<why>
The point is not to store client records — it is to stop the user forgetting to
follow up. Every design decision should serve that: the list view should make it
obvious at a glance who has gone cold. Optimize for a five-second glance, not for
data completeness.
</why>

<constraints>
- One process, one command to start, one file of persisted data. No cloud, no
  containers, no external services.
- Pick a boring, mainstream stack and stay in it.
- The whole thing should be readable by a competent developer in one sitting.
</constraints>

<out_of_scope>
No authentication. No multi-user. No email or calendar integration. No billing,
invoicing, or reporting. No pipeline or deal stages. Do not build a CRM — build a
list that nags.
</out_of_scope>

<delegation>
You are the orchestrator. Your value is in the data model, the interaction
design, and the review — not in typing the code.

- Decide the stack, the schema, and the screen layouts yourself.
- Dispatch implementation to subagents: Sonnet for the components and the
  persistence layer, Haiku for scaffolding, config, and boilerplate.
- Give each subagent a self-contained brief — goal, constraints, files it may
  touch, and the check that proves it worked. Subagents start cold.
- Dispatch independent work in parallel.
- Review what returns against the brief. Send it back with specifics if it misses.
- You may read files. You do not write them.
</delegation>

<done_when>
Starting the app from a clean checkout, you can add a client, see it in the list,
open it, change its status, and restart the process with the client still there.
Verify this yourself by running it — not by reading the code and assuming.
</done_when>
```

**Run at:** `high`. The build is routine, but you are orchestrating and the data-model
call is the whole ballgame — that decision deserves the headroom.

**Assumptions I made — correct any that are wrong:**
1. Single user, local-only. No auth anywhere.
2. The real job is follow-up nagging, so I gave it a status and a last-contacted
   date and told it to optimize the list view for spotting cold clients.
3. Persistence is a local file, not a database server.
4. Web app. If you'd rather have a CLI or a desktop app, say so — it changes the
   whole shape.

**Two questions that would change this prompt:**
1. What's the follow-up rhythm? If clients need chasing on a schedule, this needs
   reminders and I'd design around a due-date queue rather than a list.
2. Is this only ever you? If a second person touches it, auth stops being
   out-of-scope and the persistence choice changes.
````

Notice what didn't happen: no questionnaire, no "could you tell me more about your requirements." The user reacts to something real.

---

## Example B — "the onboarding is bad, fix it"

**The trap:** "bad" is a symptom, not a diagnosis, and there is an existing system. Drafting a fix prompt here would be drafting a fix for a problem you haven't identified — the prompt would be confidently wrong.

**The move:** this isn't a task brief, it's a **research brief** with an implementation phase gated behind it. Don't ask the user "what's bad about it?" — that's making them do the work. Write a prompt that makes *Fable* find out, and hand the user the diagnosis before anything gets built.

```xml
<role>
You are a product engineer who diagnoses before prescribing.
</role>

<question>
Where specifically does the current onboarding flow lose people, and why?
</question>

<why>
The user's report is that onboarding "is bad" — a symptom, not a diagnosis.
Building a fix against the wrong cause wastes the work. The output of this pass
is a ranked diagnosis the user can react to, not a redesign.
</why>

<approach>
Walk the existing flow end to end as a new user would. Instrument what you can:
count the steps, find the dead ends, find the places that ask for something the
user has no reason to give yet. Read whatever analytics or error logs exist.
Dispatch independent lines of investigation to subagents in parallel and
synthesize what returns.
</approach>

<out_of_scope>
Do not change any code in this pass. Do not propose a redesign. Diagnose.
</out_of_scope>

<output_format>
A ranked list of concrete failure points. For each: where it is, what evidence
says it's a problem, and how confident you are. Separate what you verified from
what you inferred. End with the one you'd fix first and why.
</output_format>
```

**The lesson:** when the fog is over an *existing* system, the first prompt is usually a diagnosis prompt, not a build prompt. Drafting straight to a fix is how you get a confident answer to the wrong question.
