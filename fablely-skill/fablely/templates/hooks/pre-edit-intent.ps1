# PreToolUse gate on Edit/Write: no mutation of project files until this
# session has declared an intent in .fable/.intent. Forces the size call and
# the four-line think-first contract to actually happen before hands touch
# the tree, instead of relying on the model remembering to.
#
# Fail-open contract: any internal error exits 0. A broken gate that blocks
# all edits is a disaster; a missed intent stamp is background noise.
try {
    $stdin = [Console]::In.ReadToEnd()
    if (-not $stdin) { exit 0 }

    try {
        $payload = $stdin | ConvertFrom-Json
    } catch {
        exit 0
    }

    $projectRoot = if ($env:CLAUDE_PROJECT_DIR) {
        [IO.Path]::GetFullPath($env:CLAUDE_PROJECT_DIR)
    } else {
        (Get-Location).Path
    }
    $progressPath = Join-Path $projectRoot ".fable/PROGRESS.md"
    $markerPath = Join-Path $projectRoot ".fable/.session-start"
    $intentPath = Join-Path $projectRoot ".fable/.intent"

    if (-not (Test-Path -LiteralPath $progressPath)) { exit 0 }  # not a fablely project
    if (-not (Test-Path -LiteralPath $markerPath)) { exit 0 }    # no baseline; can't judge

    # The intent stamp and all project memory must stay writable, or the
    # model could never satisfy the gate. Same for .claude (settings).
    $target = $null
    if ($payload.tool_input -and $payload.tool_input.file_path) {
        $target = [string]$payload.tool_input.file_path
    }
    if ($target) {
        $norm = $target -replace '\\', '/'
        if ($norm -match '(^|/)\.fable(/|$)' -or $norm -match '(^|/)\.claude(/|$)') {
            exit 0
        }
    }

    $markerText = (Get-Content -LiteralPath $markerPath -Raw)
    $markerLine = ($markerText -split "`r?`n")[0]
    $sessionStart = [DateTime]::Parse(
        $markerLine,
        [System.Globalization.CultureInfo]::InvariantCulture,
        [System.Globalization.DateTimeStyles]::RoundtripKind
    )

    if (Test-Path -LiteralPath $intentPath) {
        $intentTime = (Get-Item -LiteralPath $intentPath).LastWriteTime
        if ($intentTime -gt $sessionStart) {
            # Intent declared this session; gate open.
            exit 0
        }
    }

    [Console]::Error.WriteLine("fablely: declare this task before editing. Write .fable/.intent under the project root: 'trivial: <change>', a four-line Small intent, or 'unit: NNN <slug>'; then retry the edit.")
    exit 2
} catch {
    exit 0
}
