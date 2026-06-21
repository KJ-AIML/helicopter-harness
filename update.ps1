param(
  [string]$Parent = "",
  [switch]$ResetState
)

$ErrorActionPreference = "Stop"

function Find-SourceHarness {
  $scriptRoot = Split-Path -Parent $MyInvocation.ScriptName
  $candidate = Join-Path $scriptRoot ".helicopter-harness"
  if (Test-Path (Join-Path $candidate "HARNESS.md")) {
    return $candidate
  }

  $cwdCandidate = Join-Path (Get-Location).Path ".helicopter-harness"
  if (Test-Path (Join-Path $cwdCandidate "HARNESS.md")) {
    return $cwdCandidate
  }

  return $null
}

$Source = Find-SourceHarness
if (-not $Source) {
  Write-Host "No local repository checkout with .helicopter-harness was found."
  Write-Host "Update by cloning or entering the repo checkout, running git pull, then:"
  Write-Host "  .\update.ps1 -Parent <parent-workspace>"
  exit 1
}

if ([string]::IsNullOrWhiteSpace($Parent)) {
  $cwd = (Get-Location).Path
  if ((Split-Path -Leaf $cwd) -eq ".helicopter-harness") {
    $Target = $cwd
  } elseif (Test-Path (Join-Path $cwd "HARNESS.md")) {
    $Target = $cwd
  } else {
    $Target = "$cwd.helicopter-harness"
  }
} else {
  $ParentFull = [System.IO.Path]::GetFullPath($Parent)
  $Target = "$ParentFull.helicopter-harness"
}

if (-not (Test-Path $Target)) {
  throw "Target harness does not exist: $Target. Run install.ps1 first."
}

Get-ChildItem -LiteralPath $Source -Force | Where-Object { $_.Name -ne "state" -or $ResetState } | ForEach-Object {
  Copy-Item -LiteralPath $_.FullName -Destination $Target -Recurse -Force
}

Write-Host "Updated Helicopter-Harness at $Target"
if (-not $ResetState) {
  Write-Host "Preserved state/. Use -ResetState to replace state from the repo checkout."
}
Write-Host "AGENTS.md and CLAUDE.md were not modified."
