@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

:: ── Colors via ANSI ──────────────────────────────────────────────────────────
for /f %%a in ('echo prompt $E^| cmd') do set "ESC=%%a"
set "GREEN=%ESC%[92m"
set "RED=%ESC%[91m"
set "YELLOW=%ESC%[93m"
set "CYAN=%ESC%[96m"
set "WHITE=%ESC%[97m"
set "BOLD=%ESC%[1m"
set "DIM=%ESC%[2m"
set "RESET=%ESC%[0m"

:: ════════════════════════════════════════════════════════════════════════════
:: WELCOME SCREEN
:: ════════════════════════════════════════════════════════════════════════════
cls
echo.
echo %BOLD%%RED%  ╔══════════════════════════════════════════════╗%RESET%
echo %BOLD%%RED%  ║          CPC Uninstaller                     ║%RESET%
echo %BOLD%%RED%  ║          by Devjyoti Tikader Dipto           ║%RESET%
echo %BOLD%%RED%  ╠══════════════════════════════════════════════╣%RESET%
echo %BOLD%%RED%  ║  CF Handle : dipto_008                       ║%RESET%
echo %BOLD%%RED%  ║  GitHub    : tdipto008                       ║%RESET%
echo %BOLD%%RED%  ║  Email     : tdipto008@gmail.com             ║%RESET%
echo %BOLD%%RED%  ╚══════════════════════════════════════════════╝%RESET%
echo.
echo %YELLOW%  What this uninstaller will do:%RESET%
echo.
echo %WHITE%    Step 1 %DIM%— Delete C:\CPC_Files from your machine%RESET%
echo %DIM%            Scans and counts all files inside first%RESET%
echo %DIM%            Then permanently deletes the entire folder%RESET%
echo %DIM%            and everything inside it (CPC.bat, Parse.exe,%RESET%
echo %DIM%            checkers, templates, headers, scripts, etc.)%RESET%
echo.
echo %WHITE%    Step 2 %DIM%— Remove C:\CPC_Files from SYSTEM PATH%RESET%
echo %DIM%            Reads the system-wide PATH from the registry%RESET%
echo %DIM%            (HKLM\...\Environment) and strips C:\CPC_Files%RESET%
echo %DIM%            Requires Admin rights — skips gracefully if not Admin%RESET%
echo.
echo %WHITE%    Step 3 %DIM%— Remove C:\CPC_Files from USER PATH%RESET%
echo %DIM%            Reads your personal PATH from registry (HKCU\Environment)%RESET%
echo %DIM%            and strips C:\CPC_Files from it%RESET%
echo %DIM%            After this, 'CPC' command will stop working everywhere%RESET%
echo.
echo %RED%  WARNING: This cannot be undone!%RESET%
echo %DIM%  Close VS Code and any terminals that may be using CPC before continuing.%RESET%
echo.
set /p "confirm=  Type YES to confirm, anything else to cancel: "
if /i not "!confirm!"=="YES" (
    echo.
    echo %YELLOW%  [!] Cancelled — nothing was changed.%RESET%
    echo.
    timeout /t 2 /nobreak > nul
    exit /b
)

:: ════════════════════════════════════════════════════════════════════════════
:: LOADING SCREEN
:: ════════════════════════════════════════════════════════════════════════════
cls
echo.
echo %BOLD%%RED%  ╔══════════════════════════════════════════════╗%RESET%
echo %BOLD%%RED%  ║          Initializing Uninstaller...         ║%RESET%
echo %BOLD%%RED%  ╚══════════════════════════════════════════════╝%RESET%
echo.
echo %WHITE%  Preparing environment%RESET%
timeout /t 1 /nobreak > nul
echo %DIM%  [1/3] Locating C:\CPC_Files...........%RESET%
timeout /t 1 /nobreak > nul
echo %DIM%  [2/3] Reading PATH registry entries...%RESET%
timeout /t 1 /nobreak > nul
echo %DIM%  [3/3] Ready to uninstall..............%RESET%
timeout /t 1 /nobreak > nul
echo.
echo %GREEN%  [√] All checks done. Starting removal.%RESET%
echo.
timeout /t 2 /nobreak > nul

:: ════════════════════════════════════════════════════════════════════════════
:: STEP 1 — DELETE FOLDER
:: ════════════════════════════════════════════════════════════════════════════
cls
echo.
echo %BOLD%%RED%  ╔══════════════════════════════════════════════╗%RESET%
echo %BOLD%%RED%  ║   STEP 1 of 3 — Deleting C:\CPC_Files       ║%RESET%
echo %BOLD%%RED%  ╚══════════════════════════════════════════════╝%RESET%
echo.

if exist "C:\CPC_Files" (
    echo %WHITE%  [~] Found C:\CPC_Files on this machine.%RESET%
    echo %WHITE%  [~] Scanning contents...%RESET%
    timeout /t 1 /nobreak > nul

    for /f %%i in ('dir /s /b "C:\CPC_Files" 2^>nul ^| find /c /v ""') do set "filecount=%%i"
    echo %DIM%      (!filecount! items will be permanently removed)%RESET%
    echo.
    echo %WHITE%  [~] Deleting entire folder...%RESET%
    timeout /t 2 /nobreak > nul

    rmdir /s /q "C:\CPC_Files"

    if %errorlevel% == 0 (
        echo %GREEN%  [√] C:\CPC_Files deleted successfully.%RESET%
    ) else (
        echo %RED%  [X] Could not fully delete C:\CPC_Files.%RESET%
        echo %YELLOW%      Some files may still be open. Close VS Code and retry.%RESET%
    )
) else (
    echo %YELLOW%  [!] C:\CPC_Files was not found — already removed or never installed.%RESET%
)

echo.
timeout /t 2 /nobreak > nul

:: ════════════════════════════════════════════════════════════════════════════
:: STEP 2 — SYSTEM PATH
:: ════════════════════════════════════════════════════════════════════════════
cls
echo.
echo %BOLD%%RED%  ╔══════════════════════════════════════════════╗%RESET%
echo %BOLD%%RED%  ║   STEP 2 of 3 — Cleaning System PATH        ║%RESET%
echo %BOLD%%RED%  ╚══════════════════════════════════════════════╝%RESET%
echo.
echo %WHITE%  [~] Reading SYSTEM PATH from registry...%RESET%
echo %DIM%      (HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment)%RESET%
timeout /t 1 /nobreak > nul

for /f "tokens=2*" %%A in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path 2^>nul') do set "SYSPATH=%%B"

if defined SYSPATH (
    set "NEWPATH=!SYSPATH:;C:\CPC_Files=!"
    set "NEWPATH=!NEWPATH:C:\CPC_Files;=!"
    set "NEWPATH=!NEWPATH:C:\CPC_Files=!"

    if "!NEWPATH!"=="!SYSPATH!" (
        echo %YELLOW%  [!] C:\CPC_Files was not in system PATH — nothing to remove.%RESET%
    ) else (
        echo %WHITE%  [~] Removing C:\CPC_Files from system PATH...%RESET%
        timeout /t 1 /nobreak > nul
        setx /M PATH "!NEWPATH!" >nul 2>&1
        if %errorlevel% == 0 (
            echo %GREEN%  [√] Removed from system PATH successfully.%RESET%
        ) else (
            echo %YELLOW%  [!] Could not update system PATH — Admin rights required.%RESET%
            echo %DIM%      Re-run this file as Administrator for full system PATH cleanup.%RESET%
        )
    )
) else (
    echo %YELLOW%  [!] Could not read system PATH from registry.%RESET%
)

echo.
timeout /t 2 /nobreak > nul

:: ════════════════════════════════════════════════════════════════════════════
:: STEP 3 — USER PATH
:: ════════════════════════════════════════════════════════════════════════════
cls
echo.
echo %BOLD%%RED%  ╔══════════════════════════════════════════════╗%RESET%
echo %BOLD%%RED%  ║   STEP 3 of 3 — Cleaning User PATH          ║%RESET%
echo %BOLD%%RED%  ╚══════════════════════════════════════════════╝%RESET%
echo.
echo %WHITE%  [~] Reading USER PATH from registry...%RESET%
echo %DIM%      (HKCU\Environment)%RESET%
timeout /t 1 /nobreak > nul

for /f "tokens=2*" %%A in ('reg query "HKCU\Environment" /v Path 2^>nul') do set "USERPATH=%%B"

if defined USERPATH (
    set "NEWUSERPATH=!USERPATH:;C:\CPC_Files=!"
    set "NEWUSERPATH=!NEWUSERPATH:C:\CPC_Files;=!"
    set "NEWUSERPATH=!NEWUSERPATH:C:\CPC_Files=!"

    if "!NEWUSERPATH!"=="!USERPATH!" (
        echo %YELLOW%  [!] C:\CPC_Files was not in user PATH — nothing to remove.%RESET%
    ) else (
        echo %WHITE%  [~] Removing C:\CPC_Files from user PATH...%RESET%
        timeout /t 1 /nobreak > nul
        setx PATH "!NEWUSERPATH!" >nul 2>&1
        if %errorlevel% == 0 (
            echo %GREEN%  [√] Removed from user PATH successfully.%RESET%
        ) else (
            echo %RED%  [X] Could not update user PATH.%RESET%
        )
    )
) else (
    echo %YELLOW%  [!] No user PATH entry found — skipping.%RESET%
)

echo.
timeout /t 2 /nobreak > nul

:: ════════════════════════════════════════════════════════════════════════════
:: DONE SCREEN
:: ════════════════════════════════════════════════════════════════════════════
cls
echo.
echo %BOLD%%GREEN%  ╔══════════════════════════════════════════════╗%RESET%
echo %BOLD%%GREEN%  ║            Uninstall Complete!               ║%RESET%
echo %BOLD%%GREEN%  ╚══════════════════════════════════════════════╝%RESET%
echo.
echo %BOLD%%RED%  ╔══════════════════════════════════════════════╗%RESET%
echo %BOLD%%RED%  ║  What was removed                            ║%RESET%
echo %BOLD%%RED%  ╠══════════════════════════════════════════════╣%RESET%
echo %BOLD%%WHITE%  ║  C:\CPC_Files     →  Deleted                 ║%RESET%
echo %BOLD%%WHITE%  ║  System PATH      →  Cleaned                 ║%RESET%
echo %BOLD%%WHITE%  ║  User PATH        →  Cleaned                 ║%RESET%
echo %BOLD%%WHITE%  ║  CPC command      →  No longer available      ║%RESET%
echo %BOLD%%RED%  ╠══════════════════════════════════════════════╣%RESET%
echo %BOLD%%YELLOW%  ║  Restart your terminal or VS Code for PATH   ║%RESET%
echo %BOLD%%YELLOW%  ║  changes to fully take effect.               ║%RESET%
echo %BOLD%%RED%  ╚══════════════════════════════════════════════╝%RESET%
echo.
pause