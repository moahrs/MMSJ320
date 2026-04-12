Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

$src    = "d:\Projetos\MMSJ320\progs_monitor\basic.h"
$dst    = "d:\Projetos\MMSJ320\progs\basic.h"

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

Write-Host "Reading progs_monitor/basic.h as base..."
$lines = [System.Collections.Generic.List[string]]([System.IO.File]::ReadAllLines($src))

# ---- Apply progs-specific differences -----------------------------------

# 1. inputLineBasic: add vbufInput param
for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match "inputLineBasic\s*\(unsigned int") {
        $lines[$i] = $lines[$i] -replace "inputLineBasic\s*\(", "inputLineBasic(unsigned char *vbufInput, "
        Write-Host "  Fixed inputLineBasic signature"
        break
    }
}

# 2. processLine: change to (unsigned char *vbufInput)
for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match "^void processLine\s*\(") {
        $lines[$i] = "void processLine(unsigned char *vbufInput);"
        Write-Host "  Fixed processLine signature"
        break
    }
}

# 3. Replace basVtab with basLocate
for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match "basVtab") {
        $lines[$i] = "int basLocate(void);"
        Write-Host "  Replaced basVtab with basLocate"
        break
    }
}

# 4. Add basScreen before basText, and basGr1 before basHgr
# First find basText line
$basTextIdx = -1
for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match "^int basText\s*\(") { $basTextIdx = $i; break }
}
if ($basTextIdx -ge 0) {
    # Insert basGr1 after basText (basText is in monitor but basGr1 is not)
    # But first check if basScreen needs to go before basText
    # In progs: basOnVar, basScreen, basText, basGr1, basHgr, basGr
    # In monitor: basOnVar, basText, basGr, basHgr
    # Insert basScreen BEFORE basText
    $lines.Insert($basTextIdx, "int basScreen(void);")
    Write-Host "  Inserted basScreen before basText"
    
    # Re-find basText (index shifted by 1)
    $basTextIdx++
    
    # basGr1 should go after basText, before basHgr
    # Find basHgr line
    $basHgrIdx = -1
    for ($i = $basTextIdx; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match "^int basHgr\s*\(") { $basHgrIdx = $i; break }
    }
    if ($basHgrIdx -ge 0) {
        $lines.Insert($basHgrIdx, "int basGr1(void);")
        Write-Host "  Inserted basGr1 before basHgr"
    }
    
    # Also fix order: monitor has basGr before basHgr, progs has basHgr before basGr
    # Find basGr and basHgr to swap if needed
    # In progs order: basText, basGr1, basHgr, basGr
    # In monitor order: basText, basGr, basHgr
    # After our insert: basText, basGr1, basGr(!), basHgr
    # We need to swap basGr and basHgr
    $basGrIdx  = -1
    $basHgrIdx2 = -1
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match "^int basGr\s*\(\s*void\s*\);") { $basGrIdx = $i }
        if ($lines[$i] -match "^int basHgr\s*\(\s*void\s*\);") { $basHgrIdx2 = $i }
    }
    if ($basGrIdx -ge 0 -and $basHgrIdx2 -ge 0 -and $basGrIdx -lt $basHgrIdx2) {
        # swap
        $tmp = $lines[$basGrIdx]
        $lines[$basGrIdx] = $lines[$basHgrIdx2]
        $lines[$basHgrIdx2] = $tmp
        Write-Host "  Swapped basGr and basHgr order"
    }
}

# 5. Add basInverse after basNormal if not present (monitor has basNormal but not basInverse in some versions)
# Actually monitor DOES have basInverse and basNormal - let's check
$hasInverse = $false
for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match "basInverse") { $hasInverse = $true; break }
}
if (-not $hasInverse) {
    # Add after basNormal
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match "^int basNormal") {
            $lines.Insert($i + 1, "int basInverse(void);")
            Write-Host "  Inserted basInverse after basNormal"
            break
        }
    }
}

# 6. Add clearScrW at end of interpreter section (before the Funcoes dos Comandos section)
$procParamIdx = -1
for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match "^int procParam\s*\(") { $procParamIdx = $i; break }
}
if ($procParamIdx -ge 0) {
    # clearScrW should come right after procParam
    if ($lines[$procParamIdx + 1] -notmatch "clearScrW") {
        $lines.Insert($procParamIdx + 1, "void clearScrW(unsigned char color);")
        Write-Host "  Inserted clearScrW after procParam"
    }
}

# ---- Now apply the Def transformation ----------------------------------------
Write-Host "Applying Def transformation to prototypes..."

$result = [System.Collections.Generic.List[string]]::new()
$patternParts = $funcs | ForEach-Object { [regex]::Escape($_) }
$altPattern = "\b(" + ($patternParts -join "|") + ")\b"

foreach ($line in $lines) {
    $m = [regex]::Match($line, $altPattern)
    # Only process lines that look like prototype declarations (have both '(' and ';')
    if ($m.Success -and $line -match "\(" -and $line -match ";") {
        $fname = $m.Groups[1].Value
        # Only transform if it's in our funcSet
        if ($funcSet.Contains($fname)) {
            # Add Def suffix to prototype
            $defLine = [regex]::Replace($line, "\b" + [regex]::Escape($fname) + "\b", ($fname + "Def"), 1)
            $result.Add($defLine)
            # Add pointer variable declaration
            $ptrLine = [regex]::Replace($line, "\b" + [regex]::Escape($fname) + "\b", ("(*" + $fname + ")"), 1)
            $result.Add($ptrLine)
            Write-Host ("  " + $fname)
        } else {
            $result.Add($line)
        }
    } else {
        $result.Add($line)
    }
}

# ---- Add initFuncPtrs prototype and stdlib wrappers at end -------------------
$result.Add("")
$result.Add("void initFuncPtrs(void);")
$result.Add("char * (*mystrcpy)(char *, char *);")
$result.Add("char * (*mystrcat)(char *, char *);")
$result.Add("int   (*mystrcmp)(char *, char *);")
$result.Add("int   (*mystrlen)(char *);")
$result.Add("char * (*mystrchr)(char *, int);")
$result.Add("int   (*mytoupper)(int);")
$result.Add("char * (*myitoa)(int, char *, int);")

[System.IO.File]::WriteAllLines($dst, $result, [System.Text.Encoding]::UTF8)
Write-Host ""
Write-Host ("basic.h written: " + $result.Count + " lines")
Write-Host "DONE"
