@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

REM ===== ESC character setup =====
for /f %%a in ('echo prompt $E^| cmd') do set "ESC=%%a"

set "GREEN=%ESC%[92m"
set "RED=%ESC%[91m"
set "YELLOW=%ESC%[93m"
set "CYAN=%ESC%[96m"
set "BOLD=%ESC%[1m"
set "RESET=%ESC%[0m"

REM ===== Init flags =====
set "filename="
set "prob="
set "checkerSrc="
set "debugMode=0"
set "parseMode=0"

REM =====================================================================
REM  Argument parsing — use %~1 directly to avoid delayed-expansion
REM  issues with underscores, parens, exclamation marks in filenames.
REM =====================================================================
:parse_args
if "%~1"=="" goto done_parsing

REM ── -parse ──────────────────────────────────────────────────────────
if /i "%~1"=="-parse" (
    set "parseMode=1"
    shift
    goto parse_args
)

REM ── -d (debug) ──────────────────────────────────────────────────────
if /i "%~1"=="-d" (
    set "debugMode=1"
    shift
    goto parse_args
)

REM ── -checkerName.cpp  (starts with - and ends with .cpp) ────────────
set "_a=%~1"
set "_first=!_a:~0,1!"
set "_ext=!_a:~-4!"
if "!_first!"=="-" if /i "!_ext!"==".cpp" (
    set "checkerSrc=!_a:~1!"
    shift
    goto parse_args
)

REM ── positional args ─────────────────────────────────────────────────
if not defined filename (
    set "filename=%~1"
    shift
    goto parse_args
)
if not defined prob (
    set "prob=%~1"
    shift
    goto parse_args
)

shift
goto parse_args
:done_parsing

REM =====================================================================
REM  PARSE MODE
REM =====================================================================
if "!parseMode!"=="1" (
    echo %BOLD%%CYAN%=============================================%RESET%
    echo %CYAN%[^⛭ ] PARSE MODE%RESET%
    echo %BOLD%%CYAN%=============================================%RESET%
    echo.

    if not exist "C:\CPC_Files\Parse.exe" (
        echo %RED%[^⚠] Parse.exe not found at C:\CPC_Files\Parse.exe%RESET%
        pause
        exit /b
    )

    echo %CYAN%[^⛭ ] Starting Parse.exe ^— waiting for Competitive Companion...%RESET%
    echo %YELLOW%[i] Click the Competitive Companion extension on the problem page.%RESET%
    echo %YELLOW%[i] Parse.exe will stop automatically after receiving the problem.%RESET%
    echo.

    "C:\CPC_Files\Parse.exe"

    if !ERRORLEVEL! neq 0 (
        echo %RED%[^⚠] Parse.exe exited with an error.%RESET%
    ) else (
        echo.
        echo %GREEN%[^√] Problem parsed successfully!%RESET%
        echo %GREEN%[^√] Folder and test files created. Template copied.%RESET%
    )

    echo %BOLD%%CYAN%=============================================%RESET%
    pause
    exit /b
)

REM =====================================================================
REM  Validate — must have a filename for all other modes
REM =====================================================================
if not defined filename (
    echo %YELLOW%[^⛭ ] Usage:%RESET%
    echo %YELLOW%        CPC filename.cpp [problem_folder]%RESET%
    echo %YELLOW%        CPC -checkerName.cpp filename.cpp [problem_folder]%RESET%
    echo %YELLOW%        CPC -d filename.cpp [problem_folder]%RESET%
    echo %YELLOW%        CPC -parse%RESET%
    pause
    exit /b
)

REM =====================================================================
REM  Setup paths
REM =====================================================================
if not defined prob (
    for %%f in ("!filename!") do set "prob=%%~nf"
)

set "testdir=problems\!prob!"
set "exe=!testdir!\!prob!.exe"
set "tmpfile=!testdir!\temp_output.txt"
set "checkerExe=!testdir!\checker.exe"
set "lineresult=!testdir!\lineresult.txt"
set "useChecker=0"

if not exist "!testdir!" (
    echo %RED%[^⚠] Test folder not found: !testdir!%RESET%
    pause
    exit /b
)

REM =====================================================================
REM  DEBUG MODE
REM =====================================================================
if "!debugMode!"=="1" (
    echo %BOLD%%CYAN%=============================================%RESET%
    echo %CYAN%[^⛭ ] DEBUG MODE%RESET%
    echo %BOLD%%CYAN%=============================================%RESET%

    echo %CYAN%[^⛭ ] Compiling !filename! with debug flags...%RESET%
    g++ -g -O0 -fsanitize=address,undefined "!filename!" -o "!exe!"

    if !ERRORLEVEL! neq 0 (
        echo %RED%[^⚠] Compilation failed!%RESET%
        pause
        exit /b
    )

    echo %GREEN%[^√] Compiled ^(-g -O0 -fsanitize=address,undefined^)%RESET%
    echo.

    set "hasInput=0"
    for %%f in ("!testdir!\input*.txt") do set "hasInput=1"

    if "!hasInput!"=="1" (
        echo %CYAN%[^⛭ ] Running with input files ^(output shown on console^):%RESET%
        echo %BOLD%%CYAN%=============================================%RESET%
        for %%f in ("!testdir!\input*.txt") do (
            echo %BOLD%[^▶] %%~nxf%RESET%
            "!exe!" < "%%~f"
            echo.
            echo %CYAN%[exit code: !ERRORLEVEL!]%RESET%
            echo %BOLD%%CYAN%---------------------------------------------%RESET%
        )
    ) else (
        echo %YELLOW%[^⚠] No input files found. Running with manual input ^(Ctrl+Z to end^):%RESET%
        echo %BOLD%%CYAN%=============================================%RESET%
        "!exe!"
    )

    echo %BOLD%%CYAN%=============================================%RESET%
    echo %GREEN%[^√] Debug session complete%RESET%
    echo %BOLD%%CYAN%=============================================%RESET%
    pause
    exit /b
)

REM =====================================================================
REM  NORMAL / CHECKER MODE
REM =====================================================================

echo %CYAN%[^⛭ ] Compiling !filename!...%RESET%
g++ -O2 "!filename!" -o "!exe!"

if !ERRORLEVEL! neq 0 (
    echo %RED%[^⚠] Compilation failed!%RESET%
    pause
    exit /b
)

echo %GREEN%[^√] Compilation successful%RESET%
echo %CYAN%[^⛭ ] Test folder: !testdir!%RESET%

REM ── Compile checker if provided ──────────────────────────────────────
if defined checkerSrc (
    set "checkerFullPath=C:\CPC_Files\checker\!checkerSrc!"

    if not exist "!checkerFullPath!" (
        echo %RED%[^⚠] Checker not found: !checkerFullPath!%RESET%
        echo %YELLOW%    Available checkers:%RESET%
        for %%c in ("C:\CPC_Files\checker\*.cpp") do echo       - %%~nxc
        pause
        exit /b
    )

    echo %CYAN%[^⛭ ] Compiling checker: !checkerSrc!%RESET%
    g++ "!checkerFullPath!" -I"C:\CPC_Files" -o "!checkerExe!"

    if !ERRORLEVEL! neq 0 (
        echo %RED%[^⚠] Checker compilation failed!%RESET%
        pause
        exit /b
    )

    echo %GREEN%[^√] Checker compiled: !checkerExe!%RESET%
    set "useChecker=1"
)

REM ── Run tests ────────────────────────────────────────────────────────
set /a count=0
set /a passed=0

echo %BOLD%%CYAN%=============================================%RESET%

for %%f in ("!testdir!\input*.txt") do (
    set /a count+=1
    set "inputFile=%%~f"
    set "outputFile=%%~dpnf"
    set "outputFile=!outputFile:input=output!.txt"

    echo %BOLD%[^▶] Running %%~nxf%RESET%

    "!exe!" < "!inputFile!" > "!tmpfile!" 2>&1

    if not exist "!outputFile!" (
        echo   %YELLOW%[^⚠] Missing expected output: !outputFile!%RESET%
    ) else (
        if "!useChecker!"=="1" (
            "!checkerExe!" "!inputFile!" "!tmpfile!" "!outputFile!" > nul 2>&1
            set "checkerCode=!ERRORLEVEL!"

            if "!checkerCode!"=="0" (
                echo %GREEN%[^√] ACCEPTED%RESET%
                set /a passed+=1
            ) else if "!checkerCode!"=="1" (
                echo %RED%[X] WRONG ANSWER%RESET%
                powershell -ExecutionPolicy Bypass -File "C:\CPC_Files\show_diff.ps1" "!tmpfile!" "!outputFile!"
            ) else if "!checkerCode!"=="2" (
                echo %YELLOW%[~] PRESENTATION ERROR%RESET%
                powershell -ExecutionPolicy Bypass -File "C:\CPC_Files\show_diff.ps1" "!tmpfile!" "!outputFile!"
            ) else (
                echo %YELLOW%[^⚠] Checker returned unexpected code: !checkerCode!%RESET%
            )
        ) else (
            powershell -ExecutionPolicy Bypass -Command "$a=Get-Content '!tmpfile!';$e=Get-Content '!outputFile!';$fail=0;$total=[Math]::Max($a.Count,$e.Count);for($i=0;$i -lt $total;$i++){if($a[$i] -ne $e[$i]){$fail++}};Write-Host $fail" > "!lineresult!" 2>&1

            set /p failCount=<"!lineresult!"
            del "!lineresult!"

            if "!failCount!"=="0" (
                echo %GREEN%[^√] ACCEPTED%RESET%
                set /a passed+=1
            ) else (
                echo %RED%[X] Failed !failCount! line^(s^)%RESET%
                powershell -ExecutionPolicy Bypass -File "C:\CPC_Files\show_diff.ps1" "!tmpfile!" "!outputFile!"
            )
        )
    )
)

if !count! equ 0 (
    echo %YELLOW%[X] No test files found in !testdir!%RESET%
)

REM ── Summary ──────────────────────────────────────────────────────────
echo %BOLD%%CYAN%=============================================%RESET%
if !passed! == !count! (
    echo %GREEN%[^√] Passed !passed! / !count! tests%RESET%
) else (
    echo %RED%[X] Passed !passed! / !count! tests%RESET%
)
echo %BOLD%%CYAN%=============================================%RESET%

if exist "!tmpfile!" del "!tmpfile!"

pause