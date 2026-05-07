[CmdletBinding()]
param(
  [ValidateSet(
    "tb_main",
    "tb_pwm_1ch",
    "tb_pwm_mch",
    "tb_async_fifo",
    "tb_counters",
    "tb_scalers",
    "tb_range_divider_pkg"
  )]
  [string]$Testbench = "tb_main",

  [string]$Runtime,
  [string]$VivadoBin = "C:\Xilinx\Vivado\2018.3\bin"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-FullPath {
  param([Parameter(Mandatory = $true)][string]$Path)
  return [System.IO.Path]::GetFullPath($Path)
}

function Convert-ToXsimPath {
  param([Parameter(Mandatory = $true)][string]$Path)
  return (Get-FullPath $Path).Replace("\", "/")
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
    [Parameter(Mandatory = $true)][string]$Step,
    [Parameter(Mandatory = $true)][string]$WorkingDirectory
  )

  Write-Host "==> $Step"
  Push-Location $WorkingDirectory
  try {
    & $FilePath @Arguments
    if ($LASTEXITCODE -ne 0) {
      throw "$Step failed with exit code $LASTEXITCODE"
    }
  } finally {
    Pop-Location
  }
}

$RepoRoot = Get-FullPath (Join-Path $PSScriptRoot "..")
$VivadoBin = Get-FullPath $VivadoBin

$Xvhdl = Join-Path $VivadoBin "xvhdl.bat"
$Xelab = Join-Path $VivadoBin "xelab.bat"
$Xsim = Join-Path $VivadoBin "xsim.bat"

Assert-FileExists $Xvhdl "xvhdl"
Assert-FileExists $Xelab "xelab"
Assert-FileExists $Xsim "xsim"

$DefaultRuntimes = @{
  tb_main              = "20 us"
  tb_pwm_1ch           = "110 us"
  tb_pwm_mch           = "260 us"
  tb_async_fifo        = "20 us"
  tb_counters          = "2 us"
  tb_scalers           = "35 us"
  tb_range_divider_pkg = "1 us"
}

if ([string]::IsNullOrWhiteSpace($Runtime)) {
  $Runtime = $DefaultRuntimes[$Testbench]
}

$DesignFiles = @(
  "src\pwm_core\rtl\fp23\fp23_pkg.vhd",
  "src\pwm_core\rtl\utils\range_divider_pkg.vhd",
  "src\pwm_core\rtl\utils\dead_time_generator.vhd",
  "src\pwm_core\rtl\counters\up_counter_unsigned.vhd",
  "src\pwm_core\rtl\counters\up_counter_signed.vhd",
  "src\pwm_core\rtl\counters\updown_counter_unsigned.vhd",
  "src\pwm_core\rtl\counters\updown_counter_signed.vhd",
  "src\pwm_core\rtl\signal_chain\scaler_fp23.vhd",
  "src\pwm_core\rtl\signal_chain\scaler_unsigned.vhd",
  "src\pwm_core\rtl\signal_chain\scaler_signed.vhd",
  "src\pwm_core\rtl\pwm\pwm_1ch_drive_pkg.vhd",
  "src\pwm_core\rtl\pwm\pwm_1ch.vhd",
  "src\pwm_core\rtl\pwm\pwm_mch.vhd",
  "src\utils\edge_delay.vhd",
  "src\buffers\async_fifo.vhd",
  "src\signal_chain\data_decimator.vhd",
  "src\signal_chain\sine_gen_simple.vhd",
  "src\pwm\pwm_mch_buf.vhd",
  "src\main.vhd",
  "tb\$Testbench.vhd"
)

foreach ($RelativePath in $DesignFiles) {
  Assert-FileExists (Join-Path $RepoRoot $RelativePath) "VHDL source"
}

$BuildDir = Join-Path $RepoRoot "build\sim\$Testbench"
New-Item -ItemType Directory -Force -Path $BuildDir | Out-Null
$BuildDir = Get-FullPath $BuildDir

$ProjectFile = Join-Path $BuildDir "$Testbench.prj"
$RunFile = Join-Path $BuildDir "run_$Testbench.tcl"
$Snapshot = "${Testbench}_sim"

$ProjectLines = foreach ($RelativePath in $DesignFiles) {
  $SourcePath = Convert-ToXsimPath (Join-Path $RepoRoot $RelativePath)
  "vhdl work `"$SourcePath`""
}
Set-Content -LiteralPath $ProjectFile -Value $ProjectLines -Encoding ASCII

if ($Runtime -eq "all" -or $Runtime -eq "runall") {
  $RunLines = @("run all", "quit")
} else {
  $RunLines = @("run $Runtime", "quit")
}
Set-Content -LiteralPath $RunFile -Value $RunLines -Encoding ASCII

$ProjectFileForXsim = Convert-ToXsimPath $ProjectFile
$RunFileForXsim = Convert-ToXsimPath $RunFile

Invoke-Checked `
  -FilePath $Xvhdl `
  -Arguments @("--2008", "--relax", "--prj", $ProjectFileForXsim) `
  -Step "Compile VHDL for $Testbench" `
  -WorkingDirectory $BuildDir

Invoke-Checked `
  -FilePath $Xelab `
  -Arguments @("--debug", "typical", "--relax", "-L", "unisim", $Testbench, "-s", $Snapshot) `
  -Step "Elaborate $Testbench" `
  -WorkingDirectory $BuildDir

Invoke-Checked `
  -FilePath $Xsim `
  -Arguments @($Snapshot, "--tclbatch", $RunFileForXsim) `
  -Step "Run $Testbench for $Runtime" `
  -WorkingDirectory $BuildDir

$XsimLog = Join-Path $BuildDir "xsim.log"
if (Test-Path -LiteralPath $XsimLog -PathType Leaf) {
  $Failure = Select-String -LiteralPath $XsimLog -Pattern "Failure:", "Fatal:" -SimpleMatch | Select-Object -First 1
  if ($null -ne $Failure) {
    throw "Simulation reported a failure: $($Failure.Line.Trim())"
  }
}
