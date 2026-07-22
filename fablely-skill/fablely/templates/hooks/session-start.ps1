# Fail-open contract: any internal error here must still exit 0. A broken
# SessionStart hook must never block Claude Code from starting a session.
try {
    $projectRoot = if ($env:CLAUDE_PROJECT_DIR) {
        [IO.Path]::GetFullPath($env:CLAUDE_PROJECT_DIR)
    } else {
        (Get-Location).Path
    }
    $progressPath = Join-Path $projectRoot ".fable/PROGRESS.md"
    $markerPath = Join-Path $projectRoot ".fable/.session-start"

    if (-not (Test-Path -LiteralPath $progressPath)) {
        exit 0
    }

    $now = Get-Date -Format o
    $markerLines = @($now)
    try {
        $baselineStatus = @(git -C $projectRoot status --porcelain=v1 -uall 2>$null)
        if ($LASTEXITCODE -eq 0) {
            $markerLines += "git-baseline:true"
            $markerLines += $baselineStatus
        }
    } catch {
        # A git baseline is optional; timestamp enforcement still works.
    }
    Set-Content -LiteralPath $markerPath -Value $markerLines -Encoding UTF8

    Write-Output "This project uses fablely. Invoke the fablely skill, read .fable/PROGRESS.md, and verify its branch, SHA, and expected local changes before state-dependent work. Read-only questions need no intent."

    # Size advisory: SessionStart stdout is injected into context, so this is
    # the one hook that can nudge without blocking anything.
    try {
        $progressLineCount = (Get-Content -LiteralPath $progressPath).Count
        if ($progressLineCount -gt 60) {
            Write-Output "Advisory: .fable/PROGRESS.md is $progressLineCount lines, past its ~40-line schema cap. When you next rewrite it, prune: done units collapse to one line plus a pointer to their work file's Outcome section."
        }
    } catch {
        # Fail open; the pointer above already did the important work.
    }

    exit 0
} catch {
    exit 0
}
