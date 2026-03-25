param(
    [Parameter(Mandatory = $true)]
    [string]$RootPath
)

$ErrorActionPreference = 'Stop'

if (!(Test-Path -LiteralPath $RootPath)) {
    throw "Root path not found: $RootPath"
}

function Convert-CodePart {
    param([string]$Code)

    $c = $Code

    if ($c -match '(?i)^\s*section\s+([^\s]+)') {
        $indent = ([regex]::Match($c, '^\s*')).Value
        $sec = $Matches[1].ToLower()
        switch ($sec) {
            'code'  { $c = "$indent.text" }
            'const' { $c = "$indent.section .rodata" }
            'data'  { $c = "$indent.data" }
            'bss'   { $c = "$indent.bss" }
            'heap'  { $c = $indent + '.section .heap,"aw",@nobits' }
            default { $c = "$indent.section $sec" }
        }
    }

    $c = [regex]::Replace($c, '(?i)^(\s*)org\b', '$1.org')
    $c = [regex]::Replace($c, '(?i)^(\s*)xdef\b\s*(.+)$', '$1.global $2')
    $c = [regex]::Replace($c, '(?i)^(\s*)xref\b\s*(.+)$', '$1.extern $2')

    $c = [regex]::Replace($c, '(?i)\bdc\.b\b', '.byte')
    $c = [regex]::Replace($c, '(?i)\bdc\.w\b', '.word')
    $c = [regex]::Replace($c, '(?i)\bdc\.l\b', '.long')

    if ($c -match '(?i)^(\s*)ds\.b\s+(.+)$') {
        $c = "$($Matches[1]).space ($($Matches[2]))"
    } elseif ($c -match '(?i)^(\s*)ds\.w\s+(.+)$') {
        $c = "$($Matches[1]).space (($($Matches[2]))*2)"
    } elseif ($c -match '(?i)^(\s*)ds\.l\s+(.+)$') {
        $c = "$($Matches[1]).space (($($Matches[2]))*4)"
    }

    if ($c -match '(?i)^\s*([A-Za-z_.$][A-Za-z0-9_.$]*)\s+equ\s+\*\s*$') {
        $c = ".set $($Matches[1]), ."
    } elseif ($c -match '(?i)^\s*([A-Za-z_.$][A-Za-z0-9_.$]*)\s+equ\s+(.+?)\s*$') {
        $c = ".set $($Matches[1]), $($Matches[2])"
    }

    if ($c -match '(?i)^\s*align\s*$') {
        $indent = ([regex]::Match($c, '^\s*')).Value
        $c = "$indent.balign 2"
    } elseif ($c -match '(?i)^\s*align\s+(.+)$') {
        $indent = ([regex]::Match($c, '^\s*')).Value
        $c = "$indent.balign $($Matches[1])"
    }

    return $c
}

$files = Get-ChildItem -Path $RootPath -Recurse -File -Filter *.a68
$report = New-Object System.Collections.Generic.List[string]
$report.Add('# Conversao .a68 para .asm (GNU as m68k)')
$report.Add('')
$report.Add("Arquivos convertidos: $($files.Count)")
$report.Add('')
$report.Add('## Regras aplicadas')
$report.Add('- org -> .org')
$report.Add('- section code/const/data/bss/heap -> secoes GAS')
$report.Add('- xdef/xref -> .global/.extern')
$report.Add('- dc.b/dc.w/dc.l -> .byte/.word/.long')
$report.Add('- ds.b/ds.w/ds.l -> .space')
$report.Add('- equ -> .set')
$report.Add('- align -> .balign 2')
$report.Add('- ; e * (comentarios) -> |')
$report.Add('- $HEX -> 0xHEX')
$report.Add('')
$report.Add('## Arquivos')

foreach ($f in $files) {
    $changed = 0
    $outLines = New-Object System.Collections.Generic.List[string]
    $inLines = Get-Content -LiteralPath $f.FullName

    foreach ($line in $inLines) {
        $orig = [string]$line
        $work = [string]$line

        if ($work -match '^\s*\*') {
            $work = [regex]::Replace($work, '^\s*\*', '|')
        }

        $work = $work -replace ';', '|'
        $work = [regex]::Replace($work, '(?<![A-Za-z0-9_])\$(?=[0-9A-Fa-f]+)', '0x')

        $parts = $work -split '\|', 2
        $code = $parts[0]
        $comment = $null
        if ($parts.Length -gt 1) {
            $comment = $parts[1]
        }

        $code = Convert-CodePart -Code $code

        $newLine = $code.TrimEnd()
        if ($null -ne $comment) {
            if ($newLine.Length -gt 0) {
                $newLine = $newLine + ' |' + $comment
            } else {
                $newLine = '|' + $comment
            }
        }

        if ($newLine -ne $orig) {
            $changed++
        }

        $outLines.Add($newLine)
    }

    $outPath = [System.IO.Path]::ChangeExtension($f.FullName, '.asm')
    Set-Content -LiteralPath $outPath -Value $outLines -Encoding ASCII

    $rel = $outPath.Substring($RootPath.Length).TrimStart('\\')
    $report.Add("- $rel (linhas alteradas: $changed)")
}

$reportPath = Join-Path $RootPath 'CONVERSAO_A68_PARA_GAS.md'
Set-Content -LiteralPath $reportPath -Value $report -Encoding ASCII

Write-Output "Converted files: $($files.Count)"
Write-Output "Report: $reportPath"
