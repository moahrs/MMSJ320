# =============================================================================
# transform_basic.ps1
# Applies the files.c function-pointer pattern to basic.c / basic.h
#
# Pattern (same as files.c):
#   - Function DEFINITIONS renamed to funcNameDef in basic.c
#   - In basic.h: prototypes updated to funcNameDef, plus pointer var added:
#       int (*funcName)(params);
#   - initFuncPtrs() inserted at midpoint of basic.c (between procParam and
#     basPrint, around line 4153) so PC-relative LEA reaches all functions
#   - main() gets initFuncPtrs() as first call
# =============================================================================

$basicC = "d:\Projetos\MMSJ320\progs\basic.c"
$basicH = "d:\Projetos\MMSJ320\progs\basic.h"

# ---- list of all internal function names defined in basic.c ----------------
# (excludes main, assembly stubs, and anything not defined in basic.c)
$funcs = @(
    "inputLineBasic",
    "processLine",
    "tokenizeLine",
    "saveLine",
    "listProg",
    "delLine",
    "editLine",
    "runProg",
    "showErrorMessage",
    "executeToken",
    "nextToken",
    "findToken",
    "findNumberLine",
    "isalphas",
    "isdigitus",
    "isdelim",
    "iswhite",
    "basXBasLoad",
    "findVariable",
    "createVariable",
    "updateVariable",
    "createVariableArray",
    "find_var",
    "putback",
    "ustrcmp",
    "getExp",
    "level2",
    "level3",
    "level30",
    "level31",
    "level32",
    "level4",
    "level5",
    "level6",
    "primitive",
    "arithInt",
    "arithReal",
    "logicalNumericFloat",
    "logicalNumericFloatLong",
    "logicalNumericInt",
    "logicalString",
    "unaryInt",
    "unaryReal",
    "forFind",
    "forPush",
    "forPop",
    "gosubPush",
    "gosubPop",
    "powNum",
    "floatStringToFpp",
    "fppTofloatString",
    "fppSum",
    "fppSub",
    "fppMul",
    "fppDiv",
    "fppPwr",
    "fppInt",
    "fppReal",
    "fppSin",
    "fppCos",
    "fppTan",
    "fppSinH",
    "fppCosH",
    "fppTanH",
    "fppSqrt",
    "fppLn",
    "fppExp",
    "fppAbs",
    "fppNeg",
    "fppComp",
    "procParam",
    "basPrint",
    "basChr",
    "basVal",
    "basStr",
    "basLen",
    "basFre",
    "basTrig",
    "basAsc",
    "basLeftRightMid",
    "basPeekPoke",
    "basDim",
    "basIf",
    "basLet",
    "basInputGet",
    "basFor",
    "basNext",
    "basOnVar",
    "basOnErr",
    "basGoto",
    "basGosub",
    "basReturn",
    "basInt",
    "basAbs",
    "basRnd",
    "basLocate",
    "basHtab",
    "basEnd",
    "basStop",
    "basSpc",
    "basTab",
    "basScreen",
    "basText",
    "basGr1",
    "basHgr",
    "basGr",
    "basInverse",
    "basNormal",
    "basColor",
    "basPlot",
    "basHVlin",
    "basScrn",
    "basHcolor",
    "basHplot",
    "basRead",
    "basRestore",
    "clearScrW"
)

# Build a HashSet for fast lookup
$funcSet = [System.Collections.Generic.HashSet[string]]::new()
foreach ($f in $funcs) { $null = $funcSet.Add($f) }

# =============================================================================
# STEP 1: Rename function DEFINITIONS in basic.c (funcName -> funcNameDef)
# A definition line starts at column 0 with a return-type keyword, then the
# function name, then '('.  We do NOT touch call sites (they are indented).
# =============================================================================
Write-Host "=== STEP 1: Renaming function definitions in basic.c ===" -ForegroundColor Cyan

$lines = [System.IO.File]::ReadAllLines($basicC)
$renamed = @{}   # track which functions were actually renamed

# Regex: line starts with optional "unsigned/long/char/for_stack/void/int" etc.
# then whitespace(s) then the function name then optional whitespace then '('
# The line must NOT start with whitespace (definitions are at column 0)
$defPattern = '^(?:(?:unsigned|signed|long|short|void|int|char|for_stack|static)\s+)+[*\s]*(\w+)\s*\('

for ($i = 0; $i -lt $lines.Length; $i++) {
    $line = $lines[$i]
    # Quick skip: definition lines never start with whitespace/tab
    if ($line.Length -eq 0) { continue }
    $c0 = $line[0]
    if ($c0 -eq ' ' -or $c0 -eq "`t" -or $c0 -eq '/' -or $c0 -eq '*' -or $c0 -eq '#') { continue }

    $m = [regex]::Match($line, $defPattern)
    if ($m.Success) {
        $fname = $m.Groups[1].Value
        if ($funcSet.Contains($fname)) {
            # Replace the function name with funcNameDef on this line
            # Use word-boundary replacement to avoid partial matches
            $newLine = [regex]::Replace($line, "\b$([regex]::Escape($fname))\b", "${fname}Def", 1)
            $lines[$i] = $newLine
            $renamed[$fname] = $i + 1
            Write-Host "  Line $($i+1): $fname -> ${fname}Def"
        }
    }
}

Write-Host "  Total renamed: $($renamed.Count) / $($funcs.Count)" -ForegroundColor Green

# =============================================================================
# STEP 2: Insert initFuncPtrs() call in main() — right BEFORE the first
# internal function call (basText).  Find the line with "    basText();" and
# insert initFuncPtrs(); before it.
# =============================================================================
Write-Host "`n=== STEP 2: Inserting initFuncPtrs() call in main() ===" -ForegroundColor Cyan

$insertIdx = -1
# Find the line "    basText();" inside main – it's near line 78
for ($i = 55; $i -lt 200; $i++) {
    if ($lines[$i] -match '^\s+basText\s*\(\s*\)\s*;') {
        $insertIdx = $i
        break
    }
}

if ($insertIdx -ge 0) {
    $initCall = "    initFuncPtrs();"
    $linesList = [System.Collections.Generic.List[string]]::new($lines)
    $linesList.Insert($insertIdx, $initCall)
    $lines = $linesList.ToArray()
    Write-Host "  Inserted 'initFuncPtrs();' at line $($insertIdx+1) (before basText call)" -ForegroundColor Green
} else {
    Write-Host "  WARNING: Could not find basText() call in main() – initFuncPtrs() NOT inserted!" -ForegroundColor Yellow
}

# =============================================================================
# STEP 3: Insert initFuncPtrs() DEFINITION into basic.c at the midpoint
# (right before the "// FUNCOES BASIC" comment that precedes basPrint).
# We insert AFTER the closing brace of procParam and the comment block.
# =============================================================================
Write-Host "`n=== STEP 3: Inserting initFuncPtrs() definition in basic.c ===" -ForegroundColor Cyan

# Find the line: "//-----------------------------------------------------------------------------"
# that directly precedes "// Joga pra tela Texto." (basPrint comment)
$insertDefIdx = -1
for ($i = 4100; $i -lt 4300; $i++) {
    if ($i -ge $lines.Length) { break }
    if ($lines[$i] -match '^\s*//\s*FUNCOES BASIC') {
        $insertDefIdx = $i
        break
    }
}

if ($insertDefIdx -lt 0) {
    # fallback: try to find the basPrint definition line
    for ($i = 4100; $i -lt 4300; $i++) {
        if ($i -ge $lines.Length) { break }
        if ($lines[$i] -match '^int\s+basPrintDef\s*\(') {
            $insertDefIdx = $i
            break
        }
    }
}

if ($insertDefIdx -ge 0) {
    # Build the initFuncPtrs() function body
    $initBody = @(
        "//-----------------------------------------------------------------------------",
        "// initFuncPtrs - Initializes all function pointers (position-independent code)",
        "// MUST be placed at the MIDPOINT of the binary so that PC-relative LEA",
        "// can reach all function definitions (within +/-32KB from this location).",
        "//-----------------------------------------------------------------------------",
        "void initFuncPtrs(void)",
        "{",
        "    // --- Internal interpreter functions ---",
        "    inputLineBasic      = inputLineBasicDef;",
        "    processLine         = processLineDef;",
        "    tokenizeLine        = tokenizeLineDef;",
        "    saveLine            = saveLineDef;",
        "    listProg            = listProgDef;",
        "    delLine             = delLineDef;",
        "    editLine            = editLineDef;",
        "    runProg             = runProgDef;",
        "    showErrorMessage    = showErrorMessageDef;",
        "    executeToken        = executeTokenDef;",
        "    nextToken           = nextTokenDef;",
        "    findToken           = findTokenDef;",
        "    findNumberLine      = findNumberLineDef;",
        "    isalphas            = isalphasDef;",
        "    isdigitus           = isdigitusDef;",
        "    isdelim             = isdelimDef;",
        "    iswhite             = iswhiteDef;",
        "    basXBasLoad         = basXBasLoadDef;",
        "    findVariable        = findVariableDef;",
        "    createVariable      = createVariableDef;",
        "    updateVariable      = updateVariableDef;",
        "    createVariableArray = createVariableArrayDef;",
        "    find_var            = find_varDef;",
        "    putback             = putbackDef;",
        "    ustrcmp             = ustrcmpDef;",
        "    getExp              = getExpDef;",
        "    level2              = level2Def;",
        "    level3              = level3Def;",
        "    level30             = level30Def;",
        "    level31             = level31Def;",
        "    level32             = level32Def;",
        "    level4              = level4Def;",
        "    level5              = level5Def;",
        "    level6              = level6Def;",
        "    primitive           = primitiveDef;",
        "    arithInt            = arithIntDef;",
        "    arithReal           = arithRealDef;",
        "    logicalNumericFloat     = logicalNumericFloatDef;",
        "    logicalNumericFloatLong = logicalNumericFloatLongDef;",
        "    logicalNumericInt   = logicalNumericIntDef;",
        "    logicalString       = logicalStringDef;",
        "    unaryInt            = unaryIntDef;",
        "    unaryReal           = unaryRealDef;",
        "    forFind             = forFindDef;",
        "    forPush             = forPushDef;",
        "    forPop              = forPopDef;",
        "    gosubPush           = gosubPushDef;",
        "    gosubPop            = gosubPopDef;",
        "    powNum              = powNumDef;",
        "    floatStringToFpp    = floatStringToFppDef;",
        "    fppTofloatString    = fppTofloatStringDef;",
        "    fppSum              = fppSumDef;",
        "    fppSub              = fppSubDef;",
        "    fppMul              = fppMulDef;",
        "    fppDiv              = fppDivDef;",
        "    fppPwr              = fppPwrDef;",
        "    fppInt              = fppIntDef;",
        "    fppReal             = fppRealDef;",
        "    fppSin              = fppSinDef;",
        "    fppCos              = fppCosDef;",
        "    fppTan              = fppTanDef;",
        "    fppSinH             = fppSinHDef;",
        "    fppCosH             = fppCosHDef;",
        "    fppTanH             = fppTanHDef;",
        "    fppSqrt             = fppSqrtDef;",
        "    fppLn               = fppLnDef;",
        "    fppExp              = fppExpDef;",
        "    fppAbs              = fppAbsDef;",
        "    fppNeg              = fppNegDef;",
        "    fppComp             = fppCompDef;",
        "    procParam           = procParamDef;",
        "    // --- BASIC command functions ---",
        "    basPrint            = basPrintDef;",
        "    basChr              = basChrDef;",
        "    basVal              = basValDef;",
        "    basStr              = basStrDef;",
        "    basLen              = basLenDef;",
        "    basFre              = basFreDef;",
        "    basTrig             = basTrigDef;",
        "    basAsc              = basAscDef;",
        "    basLeftRightMid     = basLeftRightMidDef;",
        "    basPeekPoke         = basPeekPokeDef;",
        "    basDim              = basDimDef;",
        "    basIf               = basIfDef;",
        "    basLet              = basLetDef;",
        "    basInputGet         = basInputGetDef;",
        "    basFor              = basForDef;",
        "    basNext             = basNextDef;",
        "    basOnVar            = basOnVarDef;",
        "    basOnErr            = basOnErrDef;",
        "    basGoto             = basGotoDef;",
        "    basGosub            = basGosubDef;",
        "    basReturn           = basReturnDef;",
        "    basInt              = basIntDef;",
        "    basAbs              = basAbsDef;",
        "    basRnd              = basRndDef;",
        "    basLocate           = basLocateDef;",
        "    basHtab             = basHtabDef;",
        "    basEnd              = basEndDef;",
        "    basStop             = basStopDef;",
        "    basSpc              = basSpcDef;",
        "    basTab              = basTabDef;",
        "    basScreen           = basScreenDef;",
        "    basText             = basTextDef;",
        "    basGr1              = basGr1Def;",
        "    basHgr              = basHgrDef;",
        "    basGr               = basGrDef;",
        "    basInverse          = basInverseDef;",
        "    basNormal           = basNormalDef;",
        "    basColor            = basColorDef;",
        "    basPlot             = basPlotDef;",
        "    basHVlin            = basHVlinDef;",
        "    basScrn             = basScrnDef;",
        "    basHcolor           = basHcolorDef;",
        "    basHplot            = basHplotDef;",
        "    basRead             = basReadDef;",
        "    basRestore          = basRestoreDef;",
        "    clearScrW           = clearScrWDef;",
        "    // --- Stdlib wrappers ---",
        "    mystrcpy            = strcpy;",
        "    mystrcat            = strcat;",
        "    mystrcmp            = strcmp;",
        "    mystrlen            = strlen;",
        "    mystrchr            = strchr;",
        "    mytoupper           = toupper;",
        "    myitoa              = itoa;",
        "}",
        ""
    )

    $linesList = [System.Collections.Generic.List[string]]::new($lines)
    $linesList.InsertRange($insertDefIdx, $initBody)
    $lines = $linesList.ToArray()
    Write-Host "  Inserted initFuncPtrs() definition ($($initBody.Count) lines) at line $($insertDefIdx+1)" -ForegroundColor Green
} else {
    Write-Host "  WARNING: Could not find insertion point for initFuncPtrs() in basic.c!" -ForegroundColor Yellow
}

# Write basic.c
[System.IO.File]::WriteAllLines($basicC, $lines, [System.Text.UTF8Encoding]::new($false))
Write-Host "`n  basic.c written." -ForegroundColor Green

# =============================================================================
# STEP 4: Update basic.h
#   For each prototype line matching a function in $funcs:
#     - Change funcName( -> funcNameDef(
#     - Insert a pointer declaration after it: type (*funcName)(params);
#   Also add stdlib wrapper pointer declarations at the end.
# =============================================================================
Write-Host "`n=== STEP 4: Updating basic.h ===" -ForegroundColor Cyan

$hlines = [System.IO.File]::ReadAllLines($basicH)
$hResult = [System.Collections.Generic.List[string]]::new()

# Regex to match a C prototype line that is purely a declaration:
# starts at col 0, has a return type, function name in $funcs, then '(' ... ');'
$protoPattern = '^(.*?)\b(' + ($funcs | ForEach-Object { [regex]::Escape($_) } | Join-String -Separator '|') + ')\b(\s*\(.*)'

for ($i = 0; $i -lt $hlines.Length; $i++) {
    $line = $hlines[$i]
    $m = [regex]::Match($line, $protoPattern)

    if ($m.Success) {
        $prefix  = $m.Groups[1].Value   # return type prefix e.g. "int "
        $fname   = $m.Groups[2].Value   # function name e.g. "basText"
        $suffix  = $m.Groups[3].Value   # params + semicolon e.g. "(void);"

        # --- prototype line: rename funcName -> funcNameDef ---
        $defLine = "$prefix${fname}Def$suffix"
        $hResult.Add($defLine)

        # --- pointer declaration line ---
        # Transform "int basText(void);" -> "int (*basText)(void);"
        # Handle pointer return types like "unsigned char* find_var(char *s);"
        # The prefix may end with "* " or "* " — the (*name) goes after the base type
        # Simple heuristic: insert (*fname) in place of fname in the original line
        $ptrLine = [regex]::Replace($line, "\b$([regex]::Escape($fname))\b", "(*$fname)", 1)
        $hResult.Add($ptrLine)

        Write-Host "  Updated: $fname"
    }
    else {
        $hResult.Add($line)
    }
}

# --- Add prototype for initFuncPtrs and stdlib wrappers at the end ---
$hResult.Add("")
$hResult.Add("// -------------------------------------------------------------------------------")
$hResult.Add("// initFuncPtrs - Forward declaration")
$hResult.Add("// -------------------------------------------------------------------------------")
$hResult.Add("void initFuncPtrs(void);")
$hResult.Add("")
$hResult.Add("// -------------------------------------------------------------------------------")
$hResult.Add("// Stdlib wrappers (function pointer variables)")
$hResult.Add("// -------------------------------------------------------------------------------")
$hResult.Add("char * (*mystrcpy)(char *, char *);")
$hResult.Add("char * (*mystrcat)(char *, char *);")
$hResult.Add("int   (*mystrcmp)(char *, char *);")
$hResult.Add("int   (*mystrlen)(char *);")
$hResult.Add("char * (*mystrchr)(char *, int);")
$hResult.Add("int   (*mytoupper)(int);")
$hResult.Add("char * (*myitoa)(int, char *, int);")

[System.IO.File]::WriteAllLines($basicH, $hResult, [System.Text.UTF8Encoding]::new($false))
Write-Host "`n  basic.h written." -ForegroundColor Green

Write-Host "`n=== DONE ===" -ForegroundColor Cyan
Write-Host "Next steps:"
Write-Host "  1. Search basic.c for any remaining calls to stdlib functions (strcpy, itoa, etc.)"
Write-Host "     and replace them with the my* wrapper equivalents."
Write-Host "  2. Compile and check for errors."
