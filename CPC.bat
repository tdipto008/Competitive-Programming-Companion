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

REM ===== Parse Arguments =====
set "filename="
set "prob="
set "checkerSrc="

:parse_args
if "%~1"=="" goto done_parsing

set "arg=%~1"

if /i "!arg:~0,8!"=="-checker" (
    set "checkerSrc=%~2"
    shift
    shift
    goto parse_args
)

if "!filename!"=="" (
    set "filename=%~1"
    shift
    goto parse_args
)

if "!prob!"=="" (
    set "prob=%~1"
    shift
    goto parse_args
)

shift
goto parse_args
:done_parsing

REM ===== Validate =====
if "!filename!"=="" (
    echo %YELLOW%[⛭ ] Usage: CPC [-checker checker.cpp] filename.cpp [problem_folder]%RESET%
    pause
    exit /b
)

REM ===== Setup =====
if "!prob!"=="" (
    for %%f in ("!filename!") do set "prob=%%~nf"
)

set "testdir=problems\!prob!"
set "exe=!testdir!\!prob!.exe"
set "tmpfile=!testdir!\temp_output.txt"
set "checkerExe=!testdir!\checker.exe"
set "lineresult=!testdir!\lineresult.txt"
set "useChecker=0"

REM ===== Check folder =====
if not exist "!testdir!" (
    echo %RED%[⚠] Folder not found: !testdir!%RESET%
    pause
    exit /b
)

REM ===== Compile Solution =====
echo %CYAN%[⛭ ] Compiling !filename!...%RESET%
g++ "!filename!" -o "!exe!"

if !ERRORLEVEL! neq 0 (
    echo %RED%[⚠] Compilation failed!%RESET%
    pause
    exit /b
)

echo %GREEN%[√] Compilation successful%RESET%
echo %CYAN%[⛭ ] Using test folder: !testdir!%RESET%

REM ===== Compile Checker (if provided) =====
if not "!checkerSrc!"=="" (
    set "checkerFullPath=C:\CPC_Files\checker\!checkerSrc!"

    if not exist "!checkerFullPath!" (
        echo %RED%[⚠] Checker not found: C:\CPC_Files\checker\!checkerSrc!%RESET%
        echo %YELLOW%    Available checkers:%RESET%
        for %%c in ("C:\CPC_Files\checker\*.cpp") do echo       - %%~nxc
        pause
        exit /b
    )

    echo %CYAN%[⛭ ] Compiling checker: !checkerSrc!%RESET%
    g++ "!checkerFullPath!" -I"C:\CPC_Files" -o "!checkerExe!"

    if !ERRORLEVEL! neq 0 (
        echo %RED%[⚠] Checker compilation failed!%RESET%
        pause
        exit /b
    )

    echo %GREEN%[√] Checker compiled successfully%RESET%
    set "useChecker=1"
)

REM ===== Counters =====
set /a count=0
set /a passed=0

echo %BOLD%%CYAN%=============================================%RESET%

REM ===== Loop through tests =====
for %%f in ("!testdir!\input*.txt") do (

    set /a count+=1
    set "inputFile=%%~f"
    set "outputFile=%%~f"
    set "outputFile=!outputFile:input=output!"

    echo %BOLD%[▶] Running %%~nxf%RESET%

    "!exe!" < "!inputFile!" > "!tmpfile!" 2>&1

    if not exist "!outputFile!" (
        echo   %YELLOW%[⚠] Missing expected output: !outputFile!%RESET%
    ) else (

        if "!useChecker!"=="1" (

            "!checkerExe!" "!inputFile!" "!tmpfile!" "!outputFile!" > nul 2>&1
            set "checkerCode=!ERRORLEVEL!"

            if "!checkerCode!"=="0" (
                echo %GREEN%[√] ACCEPTED%RESET%
                set /a passed+=1
            ) else if "!checkerCode!"=="1" (
                echo %RED%[X] WRONG ANSWER%RESET%
                powershell -ExecutionPolicy Bypass -File "C:\CPC_Files\show_diff.ps1" "!tmpfile!" "!outputFile!"
            ) else if "!checkerCode!"=="2" (
                echo %YELLOW%[~] PRESENTATION ERROR%RESET%
                powershell -ExecutionPolicy Bypass -File "C:\CPC_Files\show_diff.ps1" "!tmpfile!" "!outputFile!"
            ) else (
                echo %YELLOW%[⚠] Checker exited with unexpected code: !checkerCode!%RESET%
            )

        ) else (

            REM ===== Count mismatched lines via PowerShell =====
            powershell -ExecutionPolicy Bypass -Command "$a = Get-Content '!tmpfile!'; $e = Get-Content '!outputFile!'; $fail = 0; $total = [Math]::Max($a.Count, $e.Count); for ($i = 0; $i -lt $total; $i++) { if ($a[$i] -ne $e[$i]) { $fail++ } }; Write-Host $fail" > "!lineresult!" 2>&1

            set /p failCount=<"!lineresult!"
            del "!lineresult!"

            if "!failCount!"=="0" (
                echo %GREEN%[√] ACCEPTED%RESET%
                set /a passed+=1
            ) else (
                echo %RED%[X] Failed !failCount! testcase(s)%RESET%
                powershell -ExecutionPolicy Bypass -File "C:\CPC_Files\show_diff.ps1" "!tmpfile!" "!outputFile!"
            )
        )
    )
)

REM ===== No tests found =====
if !count! equ 0 (
    echo %YELLOW%[X] No test files found in !testdir!%RESET%
)

REM ===== Summary =====
echo %BOLD%%CYAN%=============================================%RESET%
if !passed! == !count! (
    echo %GREEN%[√] Passed !passed! out of !count! tests%RESET%
) else (
    echo %RED%[X] Passed !passed! out of !count! tests%RESET%
)
echo %BOLD%%CYAN%=============================================%RESET%

if exist "!tmpfile!" del "!tmpfile!"

pause