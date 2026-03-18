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

cls
echo.
echo %BOLD%%RED%  ╔══════════════════════════════════════════╗%RESET%
echo %BOLD%%RED%  ║         CPC Uninstaller                  ║%RESET%
echo %BOLD%%RED%  ╚══════════════════════════════════════════╝%RESET%
echo.
echo %YELLOW%  This will permanently:%RESET%
echo %WHITE%    [1] Delete C:\CPC_Files and ALL contents%RESET%
echo %WHITE%    [2] Remove C:\CPC_Files from system PATH%RESET%
echo %WHITE%    [3] Remove C:\CPC_Files from user PATH%RESET%
echo %WHITE%    [4] CPC command will stop working everywhere%RESET%
echo.
echo %RED%  This cannot be undone!%RESET%
echo.
set /p "confirm=  Type YES to confirm, anything else to cancel: "
if /i not "!confirm!"=="YES" (
    echo.
    echo %YELLOW%  [!] Cancelled — nothing was changed.%RESET%
    echo.
    timeout /t 2 /nobreak > nul
    exit /b
)

cls
echo.
echo %BOLD%%RED%  ╔══════════════════════════════════════════╗%RESET%
echo %BOLD%%RED%  ║         Uninstalling CPC...              ║%RESET%
echo %BOLD%%RED%  ╚══════════════════════════════════════════╝%RESET%
echo.
timeout /t 1 /nobreak > nul

:: ════════════════════════════════════════════════════════════════════════════
echo %BOLD%%CYAN%  ╔══════════════════════════════════════════╗%RESET%
echo %BOLD%%CYAN%  ║         STEP 1 — Deleting C:\CPC_Files  ║%RESET%
echo %BOLD%%CYAN%  ╚══════════════════════════════════════════╝%RESET%
echo.

if exist "C:\CPC_Files" (
    echo %WHITE%  [~] Found C:\CPC_Files%RESET%
    echo %WHITE%  [~] Scanning contents...%RESET%
    timeout /t 1 /nobreak > nul

    for /f %%i in ('dir /s /b "C:\CPC_Files" 2^>nul ^| find /c /v ""') do set "filecount=%%i"
    echo %DIM%      (!filecount! items will be removed)%RESET%
    echo.
    echo %WHITE%  [~] Deleting...%RESET%
    timeout /t 2 /nobreak > nul

    rmdir /s /q "C:\CPC_Files"

    if %errorlevel% == 0 (
        echo %GREEN%  [√] C:\CPC_Files deleted successfully%RESET%
    ) else (
        echo %RED%  [X] Could not fully delete C:\CPC_Files%RESET%
        echo %YELLOW%      Some files may be in use. Close VS Code and retry.%RESET%
    )
) else (
    echo %YELLOW%  [!] C:\CPC_Files not found — already removed or never installed%RESET%
)

echo.
timeout /t 1 /nobreak > nul

:: ════════════════════════════════════════════════════════════════════════════
echo %BOLD%%CYAN%  ╔══════════════════════════════════════════╗%RESET%
echo %BOLD%%CYAN%  ║         STEP 2 — Cleaning System PATH   ║%RESET%
echo %BOLD%%CYAN%  ╚══════════════════════════════════════════╝%RESET%
echo.
echo %WHITE%  [~] Reading current system PATH...%RESET%
timeout /t 1 /nobreak > nul

for /f "tokens=2*" %%A in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path 2^>nul') do set "SYSPATH=%%B"

if defined SYSPATH (
    set "NEWPATH=!SYSPATH:;C:\CPC_Files=!"
    set "NEWPATH=!NEWPATH:C:\CPC_Files;=!"
    set "NEWPATH=!NEWPATH:C:\CPC_Files=!"

    if "!NEWPATH!"=="!SYSPATH!" (
        echo %YELLOW%  [!] C:\CPC_Files was not in system PATH — skipping%RESET%
    ) else (
        echo %WHITE%  [~] Removing C:\CPC_Files from system PATH...%RESET%
        timeout /t 1 /nobreak > nul
        setx /M PATH "!NEWPATH!" >nul 2>&1
        if %errorlevel% == 0 (
            echo %GREEN%  [√] Removed from system PATH%RESET%
        ) else (
            echo %YELLOW%  [!] Could not update system PATH (not Admin)%RESET%
            echo %DIM%      Run this file as Administrator for full cleanup%RESET%
        )
    )
) else (
    echo %YELLOW%  [!] Could not read system PATH%RESET%
)

echo.
timeout /t 1 /nobreak > nul

:: ════════════════════════════════════════════════════════════════════════════
echo %BOLD%%CYAN%  ╔══════════════════════════════════════════╗%RESET%
echo %BOLD%%CYAN%  ║         STEP 3 — Cleaning User PATH     ║%RESET%
echo %BOLD%%CYAN%  ╚══════════════════════════════════════════╝%RESET%
echo.
echo %WHITE%  [~] Reading current user PATH...%RESET%
timeout /t 1 /nobreak > nul

for /f "tokens=2*" %%A in ('reg query "HKCU\Environment" /v Path 2^>nul') do set "USERPATH=%%B"

if defined USERPATH (
    set "NEWUSERPATH=!USERPATH:;C:\CPC_Files=!"
    set "NEWUSERPATH=!NEWUSERPATH:C:\CPC_Files;=!"
    set "NEWUSERPATH=!NEWUSERPATH:C:\CPC_Files=!"

    if "!NEWUSERPATH!"=="!USERPATH!" (
        echo %YELLOW%  [!] C:\CPC_Files was not in user PATH — skipping%RESET%
    ) else (
        echo %WHITE%  [~] Removing C:\CPC_Files from user PATH...%RESET%
        timeout /t 1 /nobreak > nul
        setx PATH "!NEWUSERPATH!" >nul 2>&1
        if %errorlevel% == 0 (
            echo %GREEN%  [√] Removed from user PATH%RESET%
        ) else (
            echo %RED%  [X] Could not update user PATH%RESET%
        )
    )
) else (
    echo %YELLOW%  [!] No user PATH entry found — skipping%RESET%
)

echo.
timeout /t 1 /nobreak > nul

:: ════════════════════════════════════════════════════════════════════════════
echo %BOLD%%RED%  ╔══════════════════════════════════════════╗%RESET%
echo %BOLD%%GREEN%  ║   ✓  Uninstall Complete!                 ║%RESET%
echo %BOLD%%RED%  ╠══════════════════════════════════════════╣%RESET%
echo %BOLD%%RED%  ║                                          ║%RESET%
echo %BOLD%%WHITE%  ║  C:\CPC_Files    →  Deleted              ║%RESET%
echo %BOLD%%WHITE%  ║  System PATH     →  Cleaned              ║%RESET%
echo %BOLD%%WHITE%  ║  User PATH       →  Cleaned              ║%RESET%
echo %BOLD%%RED%  ║                                          ║%RESET%
echo %BOLD%%YELLOW%  ║  Restart your terminal for PATH changes  ║%RESET%
echo %BOLD%%YELLOW%  ║  to fully take effect.                   ║%RESET%
echo %BOLD%%RED%  ║                                          ║%RESET%
echo %BOLD%%RED%  ╚══════════════════════════════════════════╝%RESET%
echo.
pause