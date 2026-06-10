<#
.SYNOPSIS
  Re-grids the non-visual component icons in a text DFM (form or data module).

.DESCRIPTION
  The RAD Studio high-DPI designer can rescale non-visual component positions
  (DesignInfo) on every open, scattering them outside the form/data module
  bounds. This script rewrites the Left/Top of every non-visual component
  (a direct child of the root that has no Width/Height of its own) into a
  tidy grid, preserving their order in the DFM. Visual controls are untouched.

  Run it on a saved, closed DFM; review with git diff; reopen in the IDE.

.EXAMPLE
  .\Normalize-DfmNonVisual.ps1 ..\Samples\VclDemo\DemoMain2.dfm

.EXAMPLE
  Get-ChildItem C:\MyApp -Recurse -Filter *.dfm |
    ForEach-Object { .\Normalize-DfmNonVisual.ps1 $_.FullName -Columns 8 }
#>
param(
  [Parameter(Mandatory)] [string]$Path,
  [int]$StartX = 64,    # first column, in DFM units (use ~2x your 96-DPI taste for PPI-192 forms)
  [int]$StartY = 64,    # first row
  [int]$PitchX = 128,   # horizontal spacing
  [int]$PitchY = 112,   # vertical spacing
  [int]$Columns = 6     # icons per row
)

$ErrorActionPreference = 'Stop'
$full = (Resolve-Path $Path).Path
$text = [IO.File]::ReadAllText($full)
$newline = "`r`n"
if ($text -notmatch "`r`n") { $newline = "`n" }
$lines = $text -split "`r?`n"

# Pass 1: find direct children of the root object and classify them.
# Depth tracking: object/inherited/inline and collection 'item' open a block;
# 'end' / 'end>' close one.
$components = @()   # each: @{ Header = line index; Name; IsVisual; LeftLine; TopLine; EndLine }
$depth = 0
$current = $null
for ($i = 0; $i -lt $lines.Count; $i++) {
  $line = $lines[$i]
  if ($line -match '^\s*(object|inherited|inline)\s+(\w+)\s*:') {
    if ($depth -eq 1) {
      $current = @{ Header = $i; Name = $Matches[2]; IsVisual = $false; LeftLine = -1; TopLine = -1; EndLine = -1; Depth = $depth }
      $components += $current
    }
    $depth++
  }
  elseif ($line -match '^\s*item\s*$') {
    $depth++
  }
  elseif ($line -match '^\s*end>?\s*$') {
    $depth--
    if ($depth -eq 1 -and $null -ne $current -and $current.EndLine -lt 0) {
      $current.EndLine = $i
      $current = $null
    }
  }
  elseif ($depth -eq 2 -and $null -ne $current -and $current.EndLine -lt 0) {
    # Immediate property lines of a depth-1 component.
    if ($line -match '^\s*Left\s*=\s*-?\d+\s*$' -and $current.LeftLine -lt 0) { $current.LeftLine = $i }
    elseif ($line -match '^\s*Top\s*=\s*-?\d+\s*$' -and $current.TopLine -lt 0) { $current.TopLine = $i }
    elseif ($line -match '^\s*(Width|Height)\s*=') { $current.IsVisual = $true }
  }
}

$nonVisual = @($components | Where-Object { -not $_.IsVisual })
if ($nonVisual.Count -eq 0) {
  Write-Host "No non-visual components found in $Path"
  return
}

# Pass 2: assign grid positions in DFM order.
$inserts = @{}   # lineIndex -> array of lines to insert after header
$n = 0
foreach ($comp in $nonVisual) {
  $x = $StartX + ($n % $Columns) * $PitchX
  $y = $StartY + [Math]::Floor($n / $Columns) * $PitchY
  $n++

  # Match the indentation of the component's body.
  $indent = '    '
  if ($lines[$comp.Header] -match '^(\s*)') { $indent = $Matches[1] + '  ' }

  if ($comp.LeftLine -ge 0) { $lines[$comp.LeftLine] = "$indent" + "Left = $x" }
  if ($comp.TopLine -ge 0)  { $lines[$comp.TopLine]  = "$indent" + "Top = $y" }

  $missing = @()
  if ($comp.LeftLine -lt 0) { $missing += "$indent" + "Left = $x" }
  if ($comp.TopLine -lt 0)  { $missing += "$indent" + "Top = $y" }
  if ($missing.Count -gt 0 -and $comp.EndLine -ge 0) { $inserts[[int]$comp.EndLine] = $missing }
}

# Insert missing Left/Top just before each component's closing 'end'.
if ($inserts.Count -gt 0) {
  $out = New-Object System.Collections.Generic.List[string]
  for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($inserts.ContainsKey($i)) { $inserts[$i] | ForEach-Object { $out.Add($_) } }
    $out.Add($lines[$i])
  }
  $lines = $out.ToArray()
}

[IO.File]::WriteAllText($full, ($lines -join $newline), [Text.Encoding]::Default)
Write-Host ("Re-gridded {0} non-visual component(s) in {1}" -f $nonVisual.Count, $Path)
$nonVisual | ForEach-Object { Write-Host ("  " + $_.Name) }
