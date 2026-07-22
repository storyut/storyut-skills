# Hooks

## Why hooks exist

A skill cannot load itself. Claude Code only reads `SKILL.md` when something
tells it to — a user invoking `/fablely`, or the model deciding on its own to
look — and neither is guaranteed at the start of a fresh session, which is
exactly when `.fable/PROGRESS.md` matters most. The SessionStart hook closes
that gap: it runs unconditionally on every session start and hands the model
a directive to invoke the skill and read `PROGRESS.md` before it does
anything else. That's the auto-resume guarantee.

CLAUDE.md and skills are contextual guidance. Hooks are configuration the
harness executes at fixed lifecycle points — which also means they can be disabled or missing (no
`.claude/settings.json`, a stripped project template, an older Claude Code
version). When that happens, the project's own `CLAUDE.md` is the fallback
contract: it should tell the model directly to check `.fable/` at the start
of work. The hook is the deterministic path; `CLAUDE.md` is the concise
behavioral fallback when hooks are unavailable.

The Stop hook is a backstop, not a jail. It doesn't review the quality of
`PROGRESS.md` and doesn't require every file to be accounted for — it fires
once per stop cycle, to catch the common failure mode (real work happened,
memory was never touched) and give the model one chance to fix it before the
session ends.

No hook enforces `.fable/STANDARDS.md`. That is deliberate: the standards bar is
enforced by the review's standards axis blocking work-unit completion, which
works identically with hooks, without hooks, and in harnesses that have none.
A hook could only check that a checkbox is ticked, not that the work behind it
was done — and a bar reduced to a tickable box is exactly the late gate the
whole design avoids.

## What each script does

**`session-start.ps1`** — If `.fable/PROGRESS.md` doesn't exist, the project
isn't using fablely; it prints nothing and exits. Otherwise it resolves the
root from `CLAUDE_PROJECT_DIR`, stamps `.fable/.session-start` with the current
time and an optional git-status baseline, and prints one short directive to
invoke fablely and verify PROGRESS. SessionStart also runs after resume, clear,
and compaction, so the pointer returns when Claude Code rebuilds context.

**`pre-edit-intent.ps1`** — PreToolUse gate on `Edit|Write`. Paths resolve from
`CLAUDE_PROJECT_DIR`. If the project
isn't using fablely, there's no session marker, or the edit targets
`.fable/` or `.claude/` (which must stay writable or the gate could never be
satisfied), it exits 0. Otherwise it checks whether `.fable/.intent` was
written after the current session started; if not, it writes the intent
instructions to stderr and exits 2, blocking the edit until the model stamps
its intent. This is the think-first rule enforced as configuration: the
size declaration and Intent must exist before the first mutation, not as a
matter of discipline but as a precondition of the tool call. The gate is
per-session, not per-task — once stamped, later edits in the same session
pass; overwriting the stamp per task is the model's contract, not the
hook's.

**`stop-check.ps1`** — Resolves the project root from `CLAUDE_PROJECT_DIR` and
reads stdin (a JSON payload from Claude Code); if
`stop_hook_active` is truthy it exits immediately, because that flag means
this stop cycle already triggered a block once and re-blocking would loop
forever (the loop guard). If there's no `PROGRESS.md`, no `.session-start`
marker, it exits clean. It then looks for evidence of work after the last
PROGRESS update. Primary path: `git status --porcelain -uall` for the set of
modified/untracked files (git respects `.gitignore`, so build artifacts are
excluded correctly), session-scoped by mtime — a dirty file older than the
session marker was inherited from earlier work, not written now; `.fable/`
and `.claude/` paths are skipped. A SessionStart status baseline catches
deletions and status-set changes. Fallback when git is absent or the directory
isn't a repo: a breadth-first mtime walk with a static skip list. Finding a
session-written file newer than PROGRESS means its memory is
stale relative to real work — the hook writes a reason to stderr and exits
2, which Claude Code reads as "block this stop." Finding nothing means the
tree is clean and it exits 0.

**Fail-open is a design decision, not an afterthought.** Both scripts wrap
their entire body in `try { ... } catch { exit 0 }`. A hook bug that blocks
stopping is a disaster — it can wedge a session with no way out. A hook bug
that misses one `PROGRESS.md` update is background noise; the next
session's SessionStart directive catches it anyway. Given that asymmetry,
every unhandled error, parse failure, and missing file resolves to "allow,"
never "block."

## Settings block

Merge this into the project's `.claude/settings.json` — never overwrite the
file. This Windows bundle uses Claude Code's exec form so the project-root
placeholder is passed without shell quoting:

```json
{
  "hooks": {
    "SessionStart": [
      { "hooks": [ { "type": "command", "command": "powershell.exe", "args": ["-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "${CLAUDE_PROJECT_DIR}/.fable/hooks/session-start.ps1"] } ] }
    ],
    "PreToolUse": [
      { "matcher": "Edit|Write", "hooks": [ { "type": "command", "command": "powershell.exe", "args": ["-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "${CLAUDE_PROJECT_DIR}/.fable/hooks/pre-edit-intent.ps1"] } ] }
    ],
    "Stop": [
      { "hooks": [ { "type": "command", "command": "powershell.exe", "args": ["-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "${CLAUDE_PROJECT_DIR}/.fable/hooks/stop-check.ps1"] } ] }
    ]
  }
}
```

## Install steps

1. Copy `session-start.ps1`, `pre-edit-intent.ps1`, and `stop-check.ps1`
   from the skill's `templates/hooks/` into the project's `.fable/hooks/`.
2. Merge the settings block above into `.claude/settings.json`. Delegate to
   the update-config skill when it's available; otherwise read the existing
   file, merge in the `hooks` keys without dropping anything already there,
   write it back, and confirm the result still parses as JSON.
3. Add `.fable/.session-start` and `.fable/.intent` to `.gitignore` —
   they're per-session markers, not project state.

## Manual test procedure

Run from the project root, with `.fable/PROGRESS.md` and the hook scripts
already in place. Run the stop-check block twice where possible: once inside
a git repo (primary path) and once in a directory without git (fallback
path).

### pre-edit-intent.ps1

```powershell
$past = (Get-Date).AddMinutes(-10)

# 1. No intent stamp this session -> expect exit 2 + instructions on stderr
Set-Content ".fable/.session-start" (Get-Date).ToString("o") -NoNewline
if (Test-Path ".fable/.intent") { Remove-Item ".fable/.intent" }
'{"tool_name":"Edit","tool_input":{"file_path":"src/app.py"}}' | powershell -NoProfile -ExecutionPolicy Bypass -File ".fable/hooks/pre-edit-intent.ps1"
"exit: $LASTEXITCODE"   # expect 2

# 2. Fresh intent stamp -> expect exit 0
Start-Sleep -Milliseconds 200
Set-Content ".fable/.intent" "trivial: test"
'{"tool_name":"Edit","tool_input":{"file_path":"src/app.py"}}' | powershell -NoProfile -ExecutionPolicy Bypass -File ".fable/hooks/pre-edit-intent.ps1"
"exit: $LASTEXITCODE"   # expect 0

# 3. Stale stamp from a previous session -> expect exit 2
(Get-Item ".fable/.intent").LastWriteTime = $past
Set-Content ".fable/.session-start" (Get-Date).ToString("o") -NoNewline
'{"tool_name":"Edit","tool_input":{"file_path":"src/app.py"}}' | powershell -NoProfile -ExecutionPolicy Bypass -File ".fable/hooks/pre-edit-intent.ps1"
"exit: $LASTEXITCODE"   # expect 2

# 4. Edit targets .fable/ itself -> expect exit 0 (gate must not lock itself)
'{"tool_name":"Write","tool_input":{"file_path":".fable/.intent"}}' | powershell -NoProfile -ExecutionPolicy Bypass -File ".fable/hooks/pre-edit-intent.ps1"
"exit: $LASTEXITCODE"   # expect 0

# 5. Malformed stdin -> expect exit 0 (fail open)
"not json" | powershell -NoProfile -ExecutionPolicy Bypass -File ".fable/hooks/pre-edit-intent.ps1"
"exit: $LASTEXITCODE"   # expect 0
```

### stop-check.ps1

```powershell
# 1. Wrote files, updated PROGRESS -> expect exit 0
$past = (Get-Date).AddMinutes(-10)
Set-Content ".fable/.session-start" $past.ToString("o") -NoNewline
(Get-Item ".fable/PROGRESS.md").LastWriteTime = $past.AddMinutes(-5)
Set-Content "scratch.txt" "hello"
Start-Sleep -Milliseconds 200
Set-Content ".fable/PROGRESS.md" "# updated"
'{}' | powershell -NoProfile -ExecutionPolicy Bypass -File ".fable/hooks/stop-check.ps1"
"exit: $LASTEXITCODE"   # expect 0

# 2. Wrote files, did NOT update PROGRESS -> expect exit 2 + reason on stderr
Set-Content ".fable/.session-start" $past.ToString("o") -NoNewline
(Get-Item ".fable/PROGRESS.md").LastWriteTime = $past.AddMinutes(-5)
Start-Sleep -Milliseconds 200
Set-Content "scratch2.txt" "world"
'{}' | powershell -NoProfile -ExecutionPolicy Bypass -File ".fable/hooks/stop-check.ps1"
"exit: $LASTEXITCODE"   # expect 2, reason printed to stderr

# 3. Wrote nothing -> expect exit 0
Set-Content ".fable/.session-start" $past.ToString("o") -NoNewline
(Get-Item ".fable/PROGRESS.md").LastWriteTime = $past.AddMinutes(-5)
Get-ChildItem -File | ForEach-Object { $_.LastWriteTime = $past.AddMinutes(-5) }
'{}' | powershell -NoProfile -ExecutionPolicy Bypass -File ".fable/hooks/stop-check.ps1"
"exit: $LASTEXITCODE"   # expect 0

# 4. Malformed stdin -> expect exit 0
"not json" | powershell -NoProfile -ExecutionPolicy Bypass -File ".fable/hooks/stop-check.ps1"
"exit: $LASTEXITCODE"   # expect 0
```

`$LASTEXITCODE` reflects the exit code of the last native command (the
`powershell -File ...` invocation), so check it immediately after each call.

## Known limits

- **Existing-file ordering is mtime-based.** Git supplies the candidate set and
  the SessionStart status snapshot, but ordering an existing write against the
  session and PROGRESS still uses `LastWriteTime`. Clock skew and mtime-preserving
  copies can fool it. Every SessionStart refreshes the marker.
- **Deletion ordering is approximate.** The SessionStart git baseline catches a
  deletion when PROGRESS was never updated. Git exposes no deletion mtime, so a
  deletion after an earlier same-session PROGRESS update can still escape.
- **Fallback path has blind spots.** Without git, the static skip list
  applies and writes confined to an excluded directory (e.g. `dist/`) won't
  trigger; conversely, generated files git would ignore can cause false
  positives — another reason fablely projects want a repo.
- **The intent gate is per-session and content-blind.** It checks that
  `.fable/.intent` was written after session start — not that its content
  is honest, matches the task, or was refreshed for a second task in the
  same session. It buys the pause, not the quality of the thought; the
  skill text owns the rest.
- **The intent gate only sees Edit/Write.** File mutations routed through
  shell commands or other tools bypass it. That's accepted: hooking every Bash call would
  block legitimate git/test commands.
- **At most one block per stop cycle.** The `stop_hook_active` guard means
  a blocked stop is never blocked twice in a row — the model always gets an
  unobstructed chance to fix the problem and actually stop.
