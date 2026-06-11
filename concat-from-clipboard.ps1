# ######################################## 
#
# This script must be run in a Powershell windows
# powershell.exe -NoProfile -ExecutionPolicy Bypass -File ./concat-from-clipboard.ps1
#
# with args:
# powershell.exe -NoProfile -ExecutionPolicy Bypass -File ./concat-from-clipboard.ps1 -OutFile files-content.txt

# With patch script example always included
# powershell.exe -NoProfile -ExecutionPolicy Bypass -File ./concat-from-clipboard.ps1 -IncludePatchExample
#
# How to use: 
# - select multiple files in VSCode
# - Right-click - Copy Relative Path
# - Run the script: powershell.exe -NoProfile -ExecutionPolicy Bypass -File ./concat-from-clipboard.ps1
# - Selected files content is contatenated in ./files-content.txt
#
# v 0.0.4 | 2025-11-03 | Add optional -IncludePatchExample
# v 0.0.3 | 2025-09-16 | Update instructions
# v 0.0.2 | 2025-09-16 | Writes header with instructions
# v 0.0.1 
# 2025-09-13
#
# ########################################

param(
  [string]$OutFile = "files-content.txt",
  [int]$MaxBytes = 1048576, # 1 MB
  [switch]$IncludePatchExample
)

# Get relative paths from clipboard (one per line)
$paths = (Get-Clipboard) -split "(`r`n|`n|`r)" | Where-Object { $_.Trim() -ne "" }

if (-not $paths -or $paths.Count -eq 0) {
  Write-Host "Clipboard is empty or has no paths."
  exit 1
}

# Build output
$sb = New-Object System.Text.StringBuilder
$root = Get-Location

$header = @"
** Files: 

"@

[void]$sb.AppendLine($header)

foreach ($rel in $paths) {
  $relTrim = $rel.Trim()
  $full = Join-Path $root $relTrim
  if (-not (Test-Path -LiteralPath $full)) { continue }

  $fi = Get-Item -LiteralPath $full
  if (-not $fi.PSIsContainer -and $fi.Length -le $MaxBytes) {
    try {
      $content = Get-Content -LiteralPath $full -Raw -ErrorAction Stop
      [void]$sb.AppendLine("## $relTrim")
      [void]$sb.AppendLine($content)
      [void]$sb.AppendLine("")
    } catch {
      Write-Host "Skip (read error): $relTrim"
    }
  }
}

# include patch-script-that-works.sh if requested
if ($IncludePatchExample) {
  $patchFile = Join-Path $root "patch-script-that-works.sh"
  if (Test-Path -LiteralPath $patchFile) {
    try {
      $patchContent = Get-Content -LiteralPath $patchFile -Raw -ErrorAction Stop
      [void]$sb.AppendLine("## patch-script-that-works.sh")
      [void]$sb.AppendLine($patchContent)
      [void]$sb.AppendLine("")
      Write-Host "Included patch-script-that-works.sh"
    } catch {
      Write-Host "Skip (read error): patch-script-that-works.sh"
    }
  }
}

[IO.File]::WriteAllText((Join-Path $root $OutFile), $sb.ToString(), [Text.Encoding]::UTF8)
Write-Host "Wrote -> $OutFile"
