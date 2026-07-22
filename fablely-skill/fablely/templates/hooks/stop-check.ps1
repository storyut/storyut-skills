# Fail-open contract: everything below runs inside one top-level try/catch
# that exits 0 on any error. A broken hook that blocks stops is a disaster;
# a broken hook that misses one PROGRESS.md update is Tuesday.
try {
    $stdin = [Console]::In.ReadToEnd()

    if ($stdin) {
        try {
            $payload = $stdin | ConvertFrom-Json
        } catch {
            # Malformed input -> fail open.
            exit 0
        }

        if ($payload -and $payload.stop_hook_active) {
            # Loop guard: we already blocked once this stop cycle.
            exit 0
        }
    }

    $projectRoot = if ($env:CLAUDE_PROJECT_DIR) {
        [IO.Path]::GetFullPath($env:CLAUDE_PROJECT_DIR)
    } else {
        (Get-Location).Path
    }
    $progressPath = Join-Path $projectRoot ".fable/PROGRESS.md"
    $markerPath = Join-Path $projectRoot ".fable/.session-start"

    if (-not (Test-Path -LiteralPath $progressPath)) {
        # Not a fablely project.
        exit 0
    }

    # Size advisory: PROGRESS.md's schema caps it at ~40 lines. Stop-hook
    # stdout on exit 0 never reaches the model, so this can only ride along
    # on the exit-2 block message below; the SessionStart hook carries the
    # non-blocking version. Own try/catch: a nudge must never break the hook.
    $sizeAdvisory = ""
    try {
        $progressLineCount = (Get-Content -LiteralPath $progressPath).Count
        if ($progressLineCount -gt 60) {
            $sizeAdvisory = " While updating it, prune: it is $progressLineCount lines, past its ~40-line schema cap $([char]0x2014) done units collapse to one line plus a pointer to their work file's Outcome section."
        }
    } catch {
        $sizeAdvisory = ""
    }

    if (-not (Test-Path -LiteralPath $markerPath)) {
        # No baseline; can't judge.
        exit 0
    }

    $markerLines = @(Get-Content -LiteralPath $markerPath)
    $markerLine = $markerLines[0]
    $sessionStart = [DateTime]::Parse(
        $markerLine,
        [System.Globalization.CultureInfo]::InvariantCulture,
        [System.Globalization.DateTimeStyles]::RoundtripKind
    )

    $progressWriteTime = (Get-Item -LiteralPath $progressPath).LastWriteTime

    $found = $false

    # Primary path: ask git which files are modified or untracked, then
    # session-scope that list by mtime. Git respects .gitignore, so build
    # artifacts and dependency dirs are excluded correctly instead of by a
    # hand-rolled skip list. A dirty file whose mtime predates this session
    # was inherited from earlier work, not written now.
    $gitFiles = $null
    $gitOk = $false
    try {
        $gitFiles = @(git -C $projectRoot status --porcelain=v1 -uall 2>$null)
        if ($LASTEXITCODE -eq 0) { $gitOk = $true }
    } catch {
        $gitOk = $false
    }

    if ($gitOk) {
        # Compare with the SessionStart status snapshot. This catches
        # deletions and status-set changes that have no useful mtime.
        if ($markerLines.Count -gt 1 -and $markerLines[1] -eq "git-baseline:true") {
            $baselineFiles = @()
            if ($markerLines.Count -gt 2) { $baselineFiles = @($markerLines[2..($markerLines.Count - 1)]) }
            if (($baselineFiles -join "`n") -cne (@($gitFiles) -join "`n") -and
                $progressWriteTime -le $sessionStart) {
                $found = $true
            }
        }

        foreach ($line in @($gitFiles)) {
            if ($found) { break }
            if (-not $line -or $line.Length -lt 4) { continue }
            $path = $line.Substring(3).Trim('"')
            # Renames render as "old -> new"; the new path is what exists.
            $arrow = $path.IndexOf(' -> ')
            if ($arrow -ge 0) { $path = $path.Substring($arrow + 4).Trim('"') }
            if ($path -like ".fable/*" -or $path -like ".claude/*") { continue }
            $fullPath = Join-Path $projectRoot $path
            if (-not (Test-Path -LiteralPath $fullPath)) { continue }
            $item = Get-Item -LiteralPath $fullPath -Force -ErrorAction SilentlyContinue
            if ($item -and $item.LastWriteTime -gt $sessionStart -and $item.LastWriteTime -gt $progressWriteTime) {
                $found = $true
                break
            }
        }
    } else {
        # Fallback: no git available or not a repo -> breadth-first mtime walk
        # with a static skip list.
        $skipDirs = @(
            ".git", ".fable", ".claude", "node_modules", ".venv", "venv",
            "__pycache__", "dist", "build", "target", "bin", "obj",
            ".next", ".idea", ".vs"
        )

        $queue = New-Object System.Collections.Generic.Queue[string]
        $queue.Enqueue($projectRoot)

        while ($queue.Count -gt 0 -and -not $found) {
            $dir = $queue.Dequeue()
            $items = Get-ChildItem -LiteralPath $dir -Force -ErrorAction SilentlyContinue

            foreach ($item in $items) {
                if ($item.PSIsContainer) {
                    if ($skipDirs -notcontains $item.Name) {
                        $queue.Enqueue($item.FullName)
                    }
                } else {
                    if ($item.LastWriteTime -gt $sessionStart -and $item.LastWriteTime -gt $progressWriteTime) {
                        $found = $true
                        break
                    }
                }
            }
        }
    }

    if ($found) {
        [Console]::Error.WriteLine("Project files changed after the last .fable/PROGRESS.md update. Rewrite PROGRESS with current truth, evidence, in-flight work, one next action, expected local changes, and checkpoint or non-git status; then stop.$sizeAdvisory")
        exit 2
    }

    exit 0
} catch {
    exit 0
}
