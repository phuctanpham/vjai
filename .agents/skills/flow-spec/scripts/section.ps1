param(
    [Alias("l")]
    [switch]$List,
    [Parameter(Position = 0)]
    [string]$Anchor
)

$ErrorActionPreference = "Stop"
$root = Resolve-Path (Join-Path $PSScriptRoot "../../../..")
$specPath = Join-Path $root "docs\tasks\mobile\Garblo Flow Spec.html"

if (-not (Test-Path $specPath)) {
    Write-Error "Spec file not found at $specPath"
    exit 1
}

# Also handle raw args if someone passes --list or -List without switch binding
if ($List -or $Anchor -match '^-*list$' -or $Anchor -eq "-l") {
    $content = [System.IO.File]::ReadAllLines($specPath, [System.Text.Encoding]::UTF8)
    for ($i = 0; $i -lt $content.Length; $i++) {
        if ($content[$i] -match '<section[^>]*id="([^"]+)"') {
            $id = $Matches[1]
            $label = ""
            for ($j = $i; $j -lt [Math]::Min($content.Length, $i + 4); $j++) {
                if ($content[$j] -match 'eyebrow[^>]*>(.*?)<') {
                    $label = $Matches[1] -replace '&amp;', '&' -replace '<[^>]+>', ''
                    break
                }
            }
            if (-not $label) {
                for ($j = $i; $j -lt [Math]::Min($content.Length, $i + 6); $j++) {
                    if ($content[$j] -match '<h[1-6][^>]*>(.*?)</h[1-6]>') {
                        $label = $Matches[1] -replace '&amp;', '&' -replace '<[^>]+>', ''
                        break
                    }
                }
            }
            Write-Output "$id|$label"
        }
    }
    exit 0
}

if (-not $Anchor) {
    Write-Error "Usage: section.ps1 <anchor> | -List"
    exit 1
}

$raw = [System.IO.File]::ReadAllText($specPath, [System.Text.Encoding]::UTF8)

# Check top-level section first
$pattern = '(?s)<section[^>]*id="' + [regex]::Escape($Anchor) + '"[^>]*>(.*?)</section>'
$m = [regex]::Match($raw, $pattern)
if ($m.Success) {
    $text = $m.Groups[1].Value
} else {
    # Check inner anchor
    $innerPattern = 'id="' + [regex]::Escape($Anchor) + '"'
    $matchIndex = $raw.IndexOf($Anchor)
    if ($matchIndex -lt 0) {
        Write-Error "No anchor '$Anchor'. Run with -List."
        exit 1
    }
    Write-Warning "'$Anchor' is an inner anchor; printing extract around it."
    $start = [Math]::Max(0, $matchIndex - 100)
    $len = [Math]::Min($raw.Length - $start, 4000)
    $text = $raw.Substring($start, $len)
}

# Clean HTML tags and entities
$text = [regex]::Replace($text, '<(br|/p|/li|/tr|/h[1-6]|/div)[^>]*>', "`n", [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
$text = [regex]::Replace($text, '<[^>]+>', ' ')
$text = $text -replace '&amp;', '&' -replace '&rsaquo;', '›' -replace '&lt;', '<' -replace '&gt;', '>' -replace '&nbsp;', ' ' -replace '&quot;', '"'
$lines = $text -split "`r?`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" }
$lines -join "`n"
