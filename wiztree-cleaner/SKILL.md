---
name: wiztree-cleaner
description: Read a WizTree CSV disk-space export and suggest files and folders safe to delete. Use when the user says "free up disk space", "clean my drive", "what can I delete", "analyze disk usage", or provides a WizTree CSV/export output.
---

## If no CSV provided

Ask for the export path, or generate one. Enumerate the machine's fixed drives first — assume neither that a second drive exists nor that `C:` is the one worth scanning:

```bash
powershell.exe -NoProfile -Command 'Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | Select-Object DeviceID,@{n="UsedGB";e={[math]::Round(($_.Size-$_.FreeSpace)/1GB,1)}},@{n="FreeGB";e={[math]::Round($_.FreeSpace/1GB,1)}},@{n="PctFull";e={[math]::Round(100*($_.Size-$_.FreeSpace)/$_.Size)}}'
```

One drive: scan it. Several: scan the fullest unless the user named one — and say which you picked. Scan one drive at a time; a machine with several needs several exports.

Locate the binary across those same drives (it is frequently installed outside `Program Files`):

```bash
powershell.exe -NoProfile -Command '$d=(Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3").DeviceID; Get-ChildItem -Path $d -Filter WizTree64.exe -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName'
```

No hit means WizTree is not installed — offer `winget install AntibodySoftware.WizTree`, don't guess a path. Keep the outer quotes **single** in these two commands: Bash would expand `$_` and `$d` inside double quotes and silently hand PowerShell an empty variable.

Then scan, substituting the binary, the chosen drive, and an output path outside the skill directory:

```bash
powershell.exe -NoProfile -Command "Start-Process -FilePath '<wiztree64.exe>' -ArgumentList '<X:\>','/export=<out.csv>','/exportfiles=1','/exportfolders=1','/exportalldates=1','/exportsplitfilename=1' -Verb RunAs -Wait"
```

### ⚠️ Pitfall: WizTree hangs unless launched with `-Verb RunAs`

WizTree sets `actRunAsAdmin_Checked=TRUE` in `WizTree3.ini`, so it waits on a UAC dialog and blocks forever with no output. `-Verb RunAs` raises that dialog — warn the user they must click it, or the wait looks like a hang. `-Wait` blocks until the export finishes (~15–60s). Confirmed not to help: the 32-bit `WizTree.exe` (it relaunches WizTree64), setting `actRunAsAdmin_Checked=FALSE`, `cmd.exe /c`, and MSYS bash (mangles backslash args).

## Parse the CSV

Full-drive scans run 100–700 MB, 400K–2M rows. **Never read the file as text** — parse it in Python with the stdlib `csv` module (pandas is often missing from the agent venv).

Line 0 is a donation message, not the header — skip it, or every column shifts by one and all sizes come out zero.

```python
import csv

with open(csv_path, 'r', encoding='utf-8-sig', errors='replace') as f:
    next(f)  # ← WizTree donation line
    for row in csv.DictReader(f):
        path = row['File Name'].strip().strip('"')
        try:
            size = int(float(row.get('Size', 0) or 0))
        except (ValueError, TypeError):
            continue
```

**Folder vs file:** folders are paths ending in `\`; everything else is a file. Do *not* use the `FILENAME` column — with `/exportsplitfilename=1` folders get one too. Folder rows carry the recursive total of their contents.

Skip the root row (the bare `X:\` for whichever drive was scanned) — its Size is the whole drive. Keep its `DRIVECAPACITY`, `FREESPACE`, `USEDSPACE` for the report header, and reconcile against them: the top-level children should sum to `USEDSPACE` within ~1% on a data drive, but run **5–6% over** on a Windows system drive — WizTree counts hardlinked files at full size in every location, and `WinSxS\` is hardlinked throughout `\Windows\`. Only a gap beyond that, or a negative one, means rows were dropped in parsing.

Columns: `File Name` (full path), `Size` (bytes), `Modified`, `Allocated`, `Attributes`, `Files`, `Folders`. With `/exportalldates=1 /exportsplitfilename=1`, also `LASTACCESSDATE, CREATEDDATE, ROOT, FOLDERNAME, FILENAME, FILEEXT, DRIVECAPACITY, FREESPACE, USEDSPACE, RESERVEDSPACE`.

## Analyze

Categorize **every** row against the tables below first — no size filter yet. Filtering before categorizing is what makes reclaimable space vanish from the report.

Then, in order: dedup → roll up per category → list.

### 1. Dedup: keep the shallowest, drop descendants

Every folder is exported alongside its parent, so `C:\Windows\` and `C:\Windows\WinSxS\` both appear and totals inflate. Within one category, keep the **topmost** folder and discard everything beneath it — that node already contains its children's bytes, and it is the path the cleanup command actually takes (`npm cache clean` targets `npm-cache\`, not `npm-cache\_cacache\content-v2\sha512\`).

```python
deduped = []
for item in sorted(items, key=lambda x: len(x['path'])):
    inside_kept = any(
        item['path'].startswith(k['path']) and k['path'] != item['path']
        and k['category'] == item['category']
        for k in deduped
    )
    if not inside_kept:
        deduped.append(item)
```

Compare against already-kept items, not the full list — otherwise a deeper match evicts the ancestor and you report an unactionable leaf.

### 2. Roll up per category before thresholding

Scattered small folders are the blind spot: 40 dormant projects with a 60 MB `node_modules` each is 2.4 GB that no single row reveals. Sum `Size` by category over the deduped set, then:

- List individually: folders ≥100 MB, files ≥200 MB.
- Below that, emit **one aggregate row per category** — `Python bytecode — 312 dirs across D:\Projects — 1.4 GB` — with the common parent as the path.

Both feed the reclaimable total, so nothing under threshold silently disappears.

### 3. Catch what the table missed

The pattern tables are a whitelist, and on a personal data drive they typically match under 10% of used space — the bulk sits in download and media folders no pattern will ever name. **This step, not the tables, is where most reclaimable space is found.**

Any folder ≥1 GB or file ≥500 MB matching no pattern gets listed as `⚠️ Review manually`. Report these *alongside* the categorized total, never instead of it — the pattern total is a floor, and the unmatched list is usually where the real space is.

**Do not dedup this list shallowest-first like the categorized one.** Container roots — `C:\Users\`, `C:\Windows\`, `C:\ProgramData\`, `\AppData\Local\`, `\AppData\Roaming\` — would win and report "`C:\Users\` 53 GB", which is true and useless. Instead descend while a folder is a mere container, and report the **deepest** unmatched folder still ≥ the threshold: keep any that has no unmatched descendant above the threshold. That yields `…\VisualStudio\Packages\` and `…\Roblox\rbx-storage\` rather than `C:\Users\`.

On a data drive the two rules agree (`D:\Downloads\` is both); on a system drive only the deepest-first rule gives anything actionable.

### Use the dates — but distrust `LASTACCESSDATE`

Prefer `Modified`. NTFS last-access updates are disabled by default on Windows, and antivirus, indexing and the WizTree scan itself bulk-rewrite whatever remains — in practice ~85% of rows carry the current month and the column tells you nothing. Sanity-check it before relying on it: if most rows share one month, ignore it entirely and sort by `Modified`. Large and unmodified for >1 year is the usable staleness signal.

### ⚠️ WinSxS overstates, not understates

WizTree counts hardlinks at full size, and most of `WinSxS\` is hardlinked into `System32\`. Its headline number is largely double-counted with the rest of `\Windows\`; actual DISM reclaim is typically 10–20% of it. Never add `WinSxS\` at face value to the reclaimable total — quote it separately as "up to".

## Categorize

### Safe to delete (✅)

| Pattern in path | Category | Note |
|---|---|---|
| `\Temp\`, `\tmp\`, `*.tmp` | Temp files | Safe |
| `\AppData\Local\Google\Chrome\...\Cache` | Browser cache | Regenerable |
| `\AppData\Local\Mozilla\Firefox\...\cache2` | Browser cache | Regenerable |
| `\AppData\Local\Microsoft\Edge\...\Cache` | Browser cache | Regenerable |
| `\Windows\SoftwareDistribution\Download\` | Windows Update cache | Stop `wuauserv` first |
| `\$Recycle.Bin\` | Recycle Bin | Ask before emptying |
| `*.log`, `*.evtx` | Logs | Safe if `Modified` >30 days |
| `*.dmp`, `\Windows\Minidump\`, `\AppData\Local\CrashDumps\` | Crash dumps | Safe |
| `thumbcache_*.db`, `iconcache*.db` | Thumbnail cache | Regenerable |
| `\npm-cache\` | npm cache | `npm cache clean --force` |
| `\pip\cache\`, `\AppData\Local\pip\Cache\` | pip cache | `pip cache purge` |
| `\AppData\Local\uv\cache\` | uv cache | `uv cache clean` |
| `\node_modules\` **under a source checkout only** | Dev dependencies | Safe if project inactive — `npm prune` or delete. **Exclude** `\Program Files*\`, `\WindowsApps\`, `\AppData\Roaming\npm\`, `\AppData\Local\Programs\`, and any app install dir: that `node_modules` *is* the application, and deleting it uninstalls working software. Same trap for `\resources\` and runtime dirs inside installed apps |
| `\__pycache__\`, `*.pyc` | Python bytecode | Regenerable |
| `\bin\Debug\`, `\bin\Release\`, `\obj\` | Build output | Regenerable from source |
| `\.gradle\`, `\.m2\` | Gradle/Maven cache | Safe to clear |
| `\.cache\` (user home) | General cache dir | Regenerable |
| `\Downloads\*.exe`, `*.msi`, `*.iso` | Old installers | User discretion — check date |
| `\Windows\Prefetch\` | Prefetch | Safe — Windows rebuilds |
| `\$WinREAgent\` | WinRE temp | Safe after Windows Update |
| `\Windows\Temp\*.etl`, `\Windows\SystemTemp\*.etl` | ETL traces | Safe |
| `*.old`, `*.old.*`, versioned duplicate binaries | Stale binaries | Keep newest, delete rest |
| `\Windows.old\` | Previous Windows install | Disk Cleanup → "Previous Windows installations" — gone after 10 days anyway |
| `\Windows\SoftwareDistribution\DeliveryOptimization\` | Delivery Optimization | Safe — peer update cache |
| `\ProgramData\Microsoft\Windows\WER\` | Error Reporting | Safe |
| `memory.dmp` | Full crash dump | Safe — often several GB |
| `\Windows\ServiceProfiles\...\Windows.edb` | Search index | Rebuild via Indexing Options, don't delete live |
| `\huggingface\hub\`, `\.cache\huggingface\` | HF model cache | `huggingface-cli delete-cache` |
| `\conda\pkgs\`, `\anaconda3\pkgs\` | conda packages | `conda clean --all` |
| `\.cargo\registry\` | Rust registry | `cargo cache -a` or delete |
| `\go\pkg\mod\` | Go module cache | `go clean -modcache` |
| `\.nuget\packages\` | NuGet cache | `dotnet nuget locals all --clear` |
| `\Code\User\workspaceStorage\`, `\Code\Cache*\` | VS Code cache | Safe — per-workspace state |
| `\JetBrains\...\caches\`, `\index\` | JetBrains caches | Safe — reindexes |
| `\Adobe\Common\Media Cache*\` | Adobe media cache | Regenerable |
| `\Teams\...\Cache\`, `\discord\Cache\`, `\Slack\Cache\` | Chat app caches | Regenerable |
| `\Spotify\Storage\` | Spotify cache | Regenerable |
| `\OneDrive\...\.849C9593*`, `\Dropbox\.dropbox.cache\` | Sync caches | Safe |

### Caution — don't delete directly (⚠️)

| Path | Correct action |
|---|---|
| `\Windows\WinSxS\` | `DISM /Online /Cleanup-Image /StartComponentCleanup` |
| `hiberfil.sys` | `powercfg /h off` |
| `pagefile.sys` | System-managed — leave alone |
| `\System Volume Information\` | System Restore — never delete |
| `\Windows\Installer\` | Needed for repairs/uninstalls — PatchCleaner if orphaned |
| `\Program Files*\` | Uninstall via Control Panel |
| `\Windows\System32\` | Never touch |
| `*.vhdx`, `*.vhd` | VM/WSL disk — review, may be in use |
| `ext4.vhdx`, `docker_data.vhdx` | WSL/Docker disk — grows, never shrinks. Compact with `wsl --shutdown` then `Optimize-VHD`, or `docker system prune`. Deleting destroys the distro |
| `\Steam\steamapps\`, `\Epic Games\` | Uninstall via the launcher, not the filesystem |
| `\Apple\MobileSync\Backup\` | iPhone backups — delete via iTunes/Devices |
| `*.gguf`, `*.safetensors`, `*.bin` | ML models — review if still needed |
| `\.git\objects\` | Repo history — `git gc --aggressive`, never delete |

## Output

```
## Disk Cleanup — <drive> — reclaimable: XX GB safe, YY GB with review

| # | Category | Path | Size | Safe? | Action |
|---|---|---|---|---|---|
| 1 | Temp files | C:\Windows\Temp\ | 3.2 GB | ✅ | Delete contents |
| 2 | Browser cache | ...\Chrome\...\Cache\ | 1.8 GB | ✅ | Delete contents |
| 3 | Python bytecode | 312 dirs under D:\Projects\ | 1.4 GB | ✅ | Aggregate — delete `__pycache__` recursively |
| 4 | Unmatched | D:\Downloads\ (modified 2023-04) | 18.6 GB | ⚠️ | Review manually — usually the biggest win |
| 5 | WinSxS | C:\Windows\WinSxS\ | 12 GB | ⚠️ | DISM — expect ~1–2 GB, rest is hardlinked |
```

End with the total split ✅ Safe / ⚠️ Caution, plus copy-paste commands. State WinSxS separately from the total, never inside it.

## If asked to execute the deletions

### ⚠️ Pitfall: user Temp contains your own working directory

`%LOCALAPPDATA%\Temp` is both a top cleanup target and where the agent scratchpad, scan CSV and cleanup script live. Wiping its contents deletes your own log mid-run — the script keeps executing from memory while every later write fails, so it exits non-zero having done most of the work with **no record of what it did**. Write logs outside `%LOCALAPPDATA%\Temp` and `C:\Windows\Temp`, and exclude the scratchpad path when clearing them.

Other execution rules:

- Log freed bytes per item as you go, not at the end — a crash mid-run otherwise leaves the user unable to tell what was deleted.
- Restart any service you stopped (`wuauserv`, `bits`) in the same run, and verify with `Get-Service`; leaving Windows Update stopped is a silent regression.
- `npm cache clean --force` does not touch `_npx\`, often the larger half. Delete that directory separately.
- `Get-ChildItem -Include` matches nothing without `-Recurse` or a trailing `\*` on the path — it fails silently and reports zero orphans.
- Re-measure each target after deleting rather than trusting the command's exit code.

**Completion criterion:** every categorized byte appears exactly once — as an individual row or in a category aggregate; every unmatched folder ≥1 GB listed as review-manually; totals separate ✅ Safe, ⚠️ Caution, and WinSxS.
