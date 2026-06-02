[CmdletBinding()]
param(
  [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
  [string]$Python = "python"
)

$ErrorActionPreference = "Stop"

$script = Join-Path $PSScriptRoot "repair_project_compile_order.py"
& $Python $script --repo-root $RepoRoot

if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}
