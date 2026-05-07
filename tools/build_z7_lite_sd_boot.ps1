[CmdletBinding()]
param(
  [string]$Vivado = "C:\Xilinx\Vivado\2018.3\bin\vivado.bat",
  [string]$Xsct = "C:\Xilinx\SDK\2018.3\bin\xsct.bat",
  [string]$Bootgen = "C:\Xilinx\SDK\2018.3\bin\bootgen.bat",
  [string]$BuildDir,
  [string]$BitstreamPath,
  [switch]$SkipBitstream
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-FullPath {
  param([Parameter(Mandatory = $true)][string]$Path)
  return [System.IO.Path]::GetFullPath($Path)
}

function Assert-FileExists {
  param(
    [Parameter(Mandatory = $true)][string]$Path,
    [Parameter(Mandatory = $true)][string]$Description
  )

  if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
    throw "$Description not found: $Path"
  }
}

function Invoke-Checked {
  param(
    [Parameter(Mandatory = $true)][string]$FilePath,
    [Parameter(Mandatory = $true)][string[]]$Arguments,
    [Parameter(Mandatory = $true)][string]$Step
  )

  Write-Host "==> $Step"
  & $FilePath @Arguments
  if ($LASTEXITCODE -ne 0) {
    throw "$Step failed with exit code $LASTEXITCODE"
  }
}

function Remove-GeneratedDirectory {
  param([Parameter(Mandatory = $true)][string]$Path)

  $FullPath = Get-FullPath $Path
  $FullBuildDir = Get-FullPath $BuildDir
  $BuildPrefix = $FullBuildDir.TrimEnd("\") + "\"

  if (-not $FullPath.StartsWith($BuildPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Refusing to delete path outside build directory: $FullPath"
  }

  if (Test-Path -LiteralPath $FullPath) {
    Remove-Item -LiteralPath $FullPath -Recurse -Force
  }
}

function Remove-GeneratedTempDirectory {
  param([Parameter(Mandatory = $true)][string]$Path)

  $FullPath = Get-FullPath $Path
  $TempRoot = Get-FullPath "C:\tmp"
  $TempPrefix = $TempRoot.TrimEnd("\") + "\"

  if (-not $FullPath.StartsWith($TempPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Refusing to delete path outside C:\tmp: $FullPath"
  }

  if (Test-Path -LiteralPath $FullPath) {
    Remove-Item -LiteralPath $FullPath -Recurse -Force
  }
}

function Convert-ToBifPath {
  param([Parameter(Mandatory = $true)][string]$Path)
  return (Get-FullPath $Path).Replace("\", "/")
}

function Convert-ToXilinxPath {
  param([Parameter(Mandatory = $true)][string]$Path)
  return (Get-FullPath $Path).Replace("\", "/")
}

function Convert-ToRepoRelativeXilinxPath {
  param([Parameter(Mandatory = $true)][string]$Path)

  $FullPath = Get-FullPath $Path
  $FullRepoRoot = (Get-FullPath $RepoRoot).TrimEnd("\") + "\"
  if (-not $FullPath.StartsWith($FullRepoRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Path is not under repo root: $FullPath"
  }

  return $FullPath.Substring($FullRepoRoot.Length).Replace("\", "/")
}

$RepoRoot = Get-FullPath (Join-Path $PSScriptRoot "..")
if ([string]::IsNullOrWhiteSpace($BuildDir)) {
  $BuildDir = Join-Path $RepoRoot "build\z7_lite_sd_boot"
}
$BuildDir = Get-FullPath $BuildDir

Assert-FileExists $Vivado "Vivado 2018.3"
Assert-FileExists $Xsct "XSCT 2018.3"
Assert-FileExists $Bootgen "Bootgen 2018.3"

$BuildBitstreamTcl = Join-Path $RepoRoot "tcl\build_z7_lite_sd_bitstream.tcl"
$ExportHdfTcl = Join-Path $RepoRoot "tcl\export_z7_lite_ps_hdf.tcl"
$BuildFsblTcl = Join-Path $RepoRoot "tcl\build_z7_lite_fsbl.tcl"

Assert-FileExists $BuildBitstreamTcl "Z7-Lite bitstream build script"
Assert-FileExists $ExportHdfTcl "Z7-Lite PS handoff script"
Assert-FileExists $BuildFsblTcl "Z7-Lite FSBL build script"

New-Item -ItemType Directory -Force -Path $BuildDir | Out-Null

$BuildDirForTcl = Convert-ToXilinxPath $BuildDir
$BuildBitstreamTclForTcl = Convert-ToXilinxPath $BuildBitstreamTcl
$ExportHdfTclForTcl = Convert-ToXilinxPath $ExportHdfTcl
$BuildFsblTclForTcl = Convert-ToXilinxPath $BuildFsblTcl

if ($SkipBitstream) {
  if ([string]::IsNullOrWhiteSpace($BitstreamPath)) {
    throw "Use -BitstreamPath when -SkipBitstream is set."
  }
  $Bitstream = Get-FullPath $BitstreamPath
} else {
  Invoke-Checked `
    -FilePath $Vivado `
    -Arguments @("-mode", "batch", "-nolog", "-nojournal", "-source", $BuildBitstreamTclForTcl, "-tclargs", $BuildDirForTcl) `
    -Step "Build Z7-Lite PWM bitstream"

  $Bitstream = Join-Path $BuildDir "z7-lite-sd-boot.bit"
}
Assert-FileExists $Bitstream "PWM bitstream"

Invoke-Checked `
  -FilePath $Vivado `
  -Arguments @("-mode", "batch", "-nolog", "-nojournal", "-source", $ExportHdfTclForTcl, "-tclargs", $BuildDirForTcl) `
  -Step "Export Z7-Lite PS hardware handoff"

$Hdf = Join-Path $BuildDir "z7_lite_ps.hdf"
Assert-FileExists $Hdf "Z7-Lite PS hardware handoff"

$SdkHome = Join-Path $BuildDir "sdk_home"
New-Item -ItemType Directory -Force -Path $SdkHome | Out-Null
$SdkHome = Get-FullPath $SdkHome
$HomeDrive = [System.IO.Path]::GetPathRoot($SdkHome).TrimEnd("\")
$HomePath = $SdkHome.Substring($HomeDrive.Length)

$env:HOME = $SdkHome
$env:USERPROFILE = $SdkHome
$env:HOMEDRIVE = $HomeDrive
$env:HOMEPATH = $HomePath

Remove-GeneratedDirectory (Join-Path $BuildDir "sdk_ws")
Remove-GeneratedDirectory (Join-Path $BuildDir "hsi_fsbl")

$Fsbl = Join-Path $BuildDir "z7_lite_fsbl.elf"
$BuildFsblTclForXsct = Convert-ToRepoRelativeXilinxPath $BuildFsblTcl
$HdfForXsct = Convert-ToRepoRelativeXilinxPath $Hdf
$BuildDirForXsct = Convert-ToRepoRelativeXilinxPath $BuildDir

Push-Location $RepoRoot
try {
  Invoke-Checked `
    -FilePath $Xsct `
    -Arguments @($BuildFsblTclForXsct, $HdfForXsct, $BuildDirForXsct) `
    -Step "Build Zynq FSBL"
} finally {
  Pop-Location
}

Assert-FileExists $Fsbl "Zynq FSBL"

$Bif = Join-Path $BuildDir "z7_lite_sd_boot.bif"
$BootBin = Join-Path $BuildDir "BOOT.bin"

$BifText = @"
the_ROM_image:
{
  [bootloader] $(Convert-ToBifPath $Fsbl)
  $(Convert-ToBifPath $Bitstream)
}
"@
Set-Content -LiteralPath $Bif -Value $BifText -Encoding ASCII

Invoke-Checked `
  -FilePath $Bootgen `
  -Arguments @("-arch", "zynq", "-image", $Bif, "-o", $BootBin, "-w", "on") `
  -Step "Generate SD-card BOOT.bin"

Assert-FileExists $BootBin "SD boot image"

Write-Host ""
Write-Host "BOOT.bin generated: $BootBin"
Write-Host "Copy BOOT.bin to the FAT32 microSD root and set Z7-Lite J1 to SD boot."
