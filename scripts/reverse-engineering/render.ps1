param([string]$deck, [string]$outDir, [string]$slides = "")
$ErrorActionPreference = "Stop"
if (Test-Path $outDir) { Remove-Item "$outDir\*.png" -ErrorAction SilentlyContinue } else { New-Item -ItemType Directory $outDir | Out-Null }
$ppt = New-Object -ComObject PowerPoint.Application
try {
  $p = $ppt.Presentations.Open($deck, $true, $false, $false)
  $list = if ($slides) { $slides.Split(",") | ForEach-Object { [int]$_ } } else { 1..$p.Slides.Count }
  foreach ($i in $list) { $p.Slides.Item($i).Export((Join-Path $outDir ("s{0:D3}.png" -f $i)), "PNG", 1600, 900) }
  "slides: " + $p.Slides.Count
  $p.Close()
} finally { if ($ppt.Presentations.Count -eq 0) { $ppt.Quit() } }
