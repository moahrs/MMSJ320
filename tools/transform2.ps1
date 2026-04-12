Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

$basicC = "d:\Projetos\MMSJ320\progs\basic.c"
$basicH = "d:\Projetos\MMSJ320\progs\basic.h"

$funcs = @(
    "inputLineBasic","processLine","tokenizeLine","saveLine","listProg",
    "delLine","editLine","runProg","showErrorMessage","executeToken",
    "nextToken","findToken","findNumberLine","isalphas","isdigitus",
    "isdelim","iswhite","basXBasLoad","findVariable","createVariable",
    "updateVariable","createVariableArray","find_var","putback","ustrcmp",
    "getExp","level2","level3","level30","level31","level32","level4","level5",
    "level6","primitive","arithInt","arithReal","logicalNumericFloat",
    "logicalNumericFloatLong","logicalNumericInt","logicalString","unaryInt",
    "unaryReal","forFind","forPush","forPop","gosubPush","gosubPop","powNum",
    "floatStringToFpp","fppTofloatString","fppSum","fppSub","fppMul","fppDiv",
    "fppPwr","fppInt","fppReal","fppSin","fppCos","fppTan","fppSinH","fppCosH",
    "fppTanH","fppSqrt","fppLn","fppExp","fppAbs","fppNeg","fppComp","procParam",
    "basPrint","basChr","basVal","basStr","basLen","basFre","basTrig","basAsc",
    "basLeftRightMid","basPeekPoke","basDim","basIf","basLet","basInputGet",
    "basFor","basNext","basOnVar","basOnErr","basGoto","basGosub","basReturn",
    "basInt","basAbs","basRnd","basLocate","basHtab","basEnd","basStop","basSpc",
    "basTab","basScreen","basText","basGr1","basHgr","basGr","basInverse",
    "basNormal","basColor","basPlot","basHVlin","basScrn","basHcolor","basHplot",
    "basRead","basRestore","clearScrW"
)

$funcSet = [System.Collections.Generic.HashSet[string]]::new()
foreach ($f in $funcs) { $null = $funcSet.Add($f) }

Write-Host "STEP 1 - Renaming definitions in basic.c"
$lines = [System.IO.File]::ReadAllLines($basicC)
$renamedCount = 0

for ($i = 0; $i -lt $lines.Length; $i++) {
    $line = $lines[$i]
    if ($line.Length -eq 0) { continue }
    $c0 = [string]$line[0]
    if ($c0 -eq " " -or $c0 -eq "`t" -or $c0 -eq "/" -or $c0 -eq "*" -or $c0 -eq "#") { continue }
    
    foreach ($fname in $funcs) {
        $pat = "^[^(]*\b" + [regex]::Escape($fname) + "\s*\("
        if ($line -match $pat) {
            $line = [regex]::Replace($line, "\b" + [regex]::Escape($fname) + "\b", ($fname + "Def"), 1)
            $lines[$i] = $line
            $renamedCount++
            Write-Host ("  L" + ($i+1) + ": " + $fname + " -> " + $fname + "Def")
            break
        }
    }
}
Write-Host ("  Renamed: " + $renamedCount)

Write-Host "STEP 2 - Insert initFuncPtrs call in main()"
$insertCallIdx = -1
for ($i = 55; $i -lt 200; $i++) {
    if ($lines[$i] -match "^\s+basText\s*\(\s*\)\s*;") {
        $insertCallIdx = $i
        break
    }
}
if ($insertCallIdx -ge 0) {
    $lst = [System.Collections.Generic.List[string]]::new($lines)
    $lst.Insert($insertCallIdx, "    initFuncPtrs();")
    $lines = $lst.ToArray()
    Write-Host ("  Inserted at line " + ($insertCallIdx+1))
} else {
    Write-Host "  WARNING - basText call not found!"
}

Write-Host "STEP 3 - Insert initFuncPtrs definition"
$insertDefIdx = -1
for ($i = 4100; $i -lt 4350; $i++) {
    if ($i -ge $lines.Length) { break }
    if ($lines[$i] -match "FUNCOES BASIC") { $insertDefIdx = $i; break }
}
if ($insertDefIdx -lt 0) {
    for ($i = 4100; $i -lt 4350; $i++) {
        if ($i -ge $lines.Length) { break }
        if ($lines[$i] -match "^int\s+basPrintDef") { $insertDefIdx = $i; break }
    }
}

if ($insertDefIdx -ge 0) {
    $sb = [System.Text.StringBuilder]::new()
    $null = $sb.AppendLine("void initFuncPtrs(void)")
    $null = $sb.AppendLine("{")
    foreach ($fname in $funcs) {
        $null = $sb.AppendLine(("    " + $fname + " = " + $fname + "Def;").PadRight(50))
    }
    $null = $sb.AppendLine("    mystrcpy   = strcpy;")
    $null = $sb.AppendLine("    mystrcat   = strcat;")
    $null = $sb.AppendLine("    mystrcmp   = strcmp;")
    $null = $sb.AppendLine("    mystrlen   = strlen;")
    $null = $sb.AppendLine("    mystrchr   = strchr;")
    $null = $sb.AppendLine("    mytoupper  = toupper;")
    $null = $sb.AppendLine("    myitoa     = itoa;")
    $null = $sb.AppendLine("}")
    $null = $sb.AppendLine("")
    
    $initLines = $sb.ToString().Split("`n") | Where-Object { $_ -ne $null }
    
    $lst = [System.Collections.Generic.List[string]]::new($lines)
    $lst.InsertRange($insertDefIdx, [string[]]$initLines)
    $lines = $lst.ToArray()
    Write-Host ("  Inserted initFuncPtrs at line " + ($insertDefIdx+1))
} else {
    Write-Host "  WARNING - insertion point not found!"
}

[System.IO.File]::WriteAllLines($basicC, $lines, [System.Text.Encoding]::UTF8)
Write-Host "  basic.c saved"

Write-Host "STEP 4 - Updating basic.h"
$hlines = [System.IO.File]::ReadAllLines($basicH)
$hResult = [System.Collections.Generic.List[string]]::new()

$altPattern = "\b(" + ($funcs | ForEach-Object { [regex]::Escape($_) } | Join-String -Separator "|") + ")\b"

for ($i = 0; $i -lt $hlines.Length; $i++) {
    $line = $hlines[$i]
    $m = [regex]::Match($line, $altPattern)
    if ($m.Success -and $line -match "\(" -and $line -match ";") {
        $fname = $m.Groups[1].Value
        # add Def suffix to definition prototype
        $defLine = [regex]::Replace($line, "\b" + [regex]::Escape($fname) + "\b", ($fname + "Def"), 1)
        $hResult.Add($defLine)
        # add pointer variable (replace fname with (*fname) in original line)
        $ptrLine = [regex]::Replace($line, "\b" + [regex]::Escape($fname) + "\b", ("(*" + $fname + ")"), 1)
        $hResult.Add($ptrLine)
        Write-Host ("  " + $fname)
    } else {
        $hResult.Add($line)
    }
}

$hResult.Add("")
$hResult.Add("void initFuncPtrs(void);")
$hResult.Add("char * (*mystrcpy)(char *, char *);")
$hResult.Add("char * (*mystrcat)(char *, char *);")
$hResult.Add("int   (*mystrcmp)(char *, char *);")
$hResult.Add("int   (*mystrlen)(char *);")
$hResult.Add("char * (*mystrchr)(char *, int);")
$hResult.Add("int   (*mytoupper)(int);")
$hResult.Add("char * (*myitoa)(int, char *, int);")

[System.IO.File]::WriteAllLines($basicH, $hResult, [System.Text.Encoding]::UTF8)
Write-Host "  basic.h saved"
Write-Host "DONE"
