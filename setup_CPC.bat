@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

:: ── Colors via ANSI ──────────────────────────────────────────────────────────
for /f %%a in ('echo prompt $E^| cmd') do set "ESC=%%a"
set "GREEN=%ESC%[92m"
set "RED=%ESC%[91m"
set "YELLOW=%ESC%[93m"
set "CYAN=%ESC%[96m"
set "MAGENTA=%ESC%[95m"
set "WHITE=%ESC%[97m"
set "BOLD=%ESC%[1m"
set "DIM=%ESC%[2m"
set "RESET=%ESC%[0m"

set "REPO_URL=https://github.com/tdipto008/Competitive-Programming-Companion"
set "BRANCH=main"
set "FOLDER=CPC_Files"
set "DEST=C:\CPC_Files"

:: ════════════════════════════════════════════════════════════════════════════
:: WELCOME SCREEN
:: ════════════════════════════════════════════════════════════════════════════
cls
echo.
echo %BOLD%%CYAN%  ╔══════════════════════════════════════════════╗%RESET%
echo %BOLD%%CYAN%  ║       CPC Setup ^& Installer                  ║%RESET%
echo %BOLD%%CYAN%  ║       by Devjyoti Tikader Dipto              ║%RESET%
echo %BOLD%%CYAN%  ╠══════════════════════════════════════════════╣%RESET%
echo %BOLD%%CYAN%  ║  CF Handle : dipto_008                       ║%RESET%
echo %BOLD%%CYAN%  ║  GitHub    : tdipto008                       ║%RESET%
echo %BOLD%%CYAN%  ║  Email     : tdipto008@gmail.com             ║%RESET%
echo %BOLD%%CYAN%  ╚══════════════════════════════════════════════╝%RESET%
echo.
echo %DIM%  Repository : %RESET%%WHITE%tdipto008/Competitive-Programming-Companion%RESET%
echo %DIM%  Destination: %RESET%%WHITE%C:\CPC_Files%RESET%
echo %DIM%  Branch     : %RESET%%WHITE%main%RESET%
echo.
echo %YELLOW%  What this installer will do:%RESET%
echo.
echo %WHITE%    Step 1 %DIM%— Check if Git is installed on your system%RESET%
echo %DIM%            If yes: uses git sparse-checkout to download only%RESET%
echo %DIM%                    the CPC_Files folder (faster, no full clone)%RESET%
echo %DIM%            If no : downloads the full repo as a .zip via%RESET%
echo %DIM%                    PowerShell and extracts CPC_Files from it%RESET%
echo.
echo %WHITE%    Step 2 %DIM%— Create C:\CPC_Files on your machine%RESET%
echo %DIM%            If C:\CPC_Files already exists, it will be deleted%RESET%
echo %DIM%            and replaced with the fresh download%RESET%
echo.
echo %WHITE%    Step 3 %DIM%— Download all files from GitHub into C:\CPC_Files%RESET%
echo %DIM%            Includes: CPC.bat, Parse.exe, checkers, templates,%RESET%
echo %DIM%            httplib.h, json.hpp, show_diff.ps1 and more%RESET%
echo.
echo %WHITE%    Step 4 %DIM%— Flatten folder structure and remove git metadata%RESET%
echo %DIM%            Files go directly into C:\CPC_Files\ (no subfolders)%RESET%
echo %DIM%            The hidden .git folder is deleted after download%RESET%
echo.
echo %WHITE%    Step 5 %DIM%— Add C:\CPC_Files to your system PATH%RESET%
echo %DIM%            Tries system-wide PATH first (needs Admin rights)%RESET%
echo %DIM%            Falls back to user PATH if Admin is not available%RESET%
echo %DIM%            After this, 'CPC' command works from any terminal%RESET%
echo.
echo %YELLOW%  Requirements:%RESET%
echo %DIM%    - Internet connection%RESET%
echo %DIM%    - Git (optional, but recommended) or PowerShell%RESET%
echo %DIM%    - Admin rights (optional, for system-wide PATH)%RESET%
echo.
echo %RED%  If C:\CPC_Files already exists it will be DELETED and reinstalled.%RESET%
echo.
set /p "confirm=  Proceed with installation? (yes/no): "
if /i not "!confirm!"=="yes" (
    echo.
    echo %YELLOW%  [!] Installation cancelled. Nothing was changed.%RESET%
    echo.
    timeout /t 2 /nobreak > nul
    exit /b
)

:: ════════════════════════════════════════════════════════════════════════════
:: LOADING SCREEN
:: ════════════════════════════════════════════════════════════════════════════
cls
echo.
echo %BOLD%%CYAN%  ╔══════════════════════════════════════════════╗%RESET%
echo %BOLD%%CYAN%  ║          Initializing Installer...           ║%RESET%
echo %BOLD%%CYAN%  ╚══════════════════════════════════════════════╝%RESET%
echo.
echo %WHITE%  Preparing environment%RESET%
timeout /t 1 /nobreak > nul
echo %DIM%  [1/5] Checking system tools......%RESET%
timeout /t 1 /nobreak > nul
echo %DIM%  [2/5] Verifying network access...%RESET%
timeout /t 1 /nobreak > nul
echo %DIM%  [3/5] Scanning PATH entries......%RESET%
timeout /t 1 /nobreak > nul
echo %DIM%  [4/5] Reading registry...........%RESET%
timeout /t 1 /nobreak > nul
echo %DIM%  [5/5] Ready to install...........%RESET%
timeout /t 1 /nobreak > nul
echo.
echo %GREEN%  [√] All checks passed. Starting installation.%RESET%
echo.
timeout /t 2 /nobreak > nul

:: ════════════════════════════════════════════════════════════════════════════
:: STEP 1 — CHECK GIT
:: ════════════════════════════════════════════════════════════════════════════
cls
echo.
echo %BOLD%%CYAN%  ╔══════════════════════════════════════════════╗%RESET%
echo %BOLD%%CYAN%  ║   STEP 1 of 5 — Checking Git                ║%RESET%
echo %BOLD%%CYAN%  ╚══════════════════════════════════════════════╝%RESET%
echo.
echo %WHITE%  [~] Looking for Git on this machine...%RESET%
timeout /t 1 /nobreak > nul

where git >nul 2>&1
if %errorlevel% == 0 (
    echo %GREEN%  [√] Git detected!%RESET%
    echo %DIM%      Will use sparse-checkout — downloads only CPC_Files, not the full repo.%RESET%
    echo.
    timeout /t 2 /nobreak > nul
    goto git_method
)

echo %YELLOW%  [!] Git not found on this machine.%RESET%
echo %DIM%      Switching to PowerShell fallback — will download full repo .zip%RESET%
echo %DIM%      and extract only CPC_Files from it.%RESET%
echo.
timeout /t 2 /nobreak > nul
goto ps_method

:: ════════════════════════════════════════════════════════════════════════════
:git_method
:: STEP 2 — PREPARE FOLDER
:: ════════════════════════════════════════════════════════════════════════════
cls
echo.
echo %BOLD%%CYAN%  ╔══════════════════════════════════════════════╗%RESET%
echo %BOLD%%CYAN%  ║   STEP 2 of 5 — Preparing Folder            ║%RESET%
echo %BOLD%%CYAN%  ╚══════════════════════════════════════════════╝%RESET%
echo.

if exist "%DEST%" (
    echo %YELLOW%  [!] C:\CPC_Files already exists on this machine.%RESET%
    echo %WHITE%  [~] Removing old installation...%RESET%
    timeout /t 2 /nobreak > nul
    rmdir /s /q "%DEST%"
    echo %GREEN%  [√] Old folder removed.%RESET%
    echo.
    timeout /t 1 /nobreak > nul
)

echo %WHITE%  [~] Creating C:\CPC_Files...%RESET%
timeout /t 1 /nobreak > nul
mkdir "%DEST%"
cd /d "%DEST%"
echo %GREEN%  [√] Folder created at C:\CPC_Files%RESET%
echo.
timeout /t 1 /nobreak > nul

:: ════════════════════════════════════════════════════════════════════════════
:: STEP 3 — DOWNLOAD
:: ════════════════════════════════════════════════════════════════════════════
cls
echo.
echo %BOLD%%CYAN%  ╔══════════════════════════════════════════════╗%RESET%
echo %BOLD%%CYAN%  ║   STEP 3 of 5 — Downloading Files           ║%RESET%
echo %BOLD%%CYAN%  ╚══════════════════════════════════════════════╝%RESET%
echo.
echo %WHITE%  [~] Initializing local git repo...%RESET%
timeout /t 1 /nobreak > nul
git init -q
echo %GREEN%  [√] Git repo initialized%RESET%

echo %WHITE%  [~] Connecting to GitHub remote...%RESET%
timeout /t 1 /nobreak > nul
git remote add origin %REPO_URL%.git
echo %GREEN%  [√] Remote origin set%RESET%

echo %WHITE%  [~] Configuring sparse-checkout for CPC_Files only...%RESET%
timeout /t 1 /nobreak > nul
git config core.sparseCheckout true
echo %FOLDER%/* > .git\info\sparse-checkout
echo %GREEN%  [√] Sparse-checkout configured%RESET%

echo.
echo %CYAN%  [~] Pulling CPC_Files from GitHub...%RESET%
echo %DIM%      This may take a moment depending on your connection.%RESET%
echo.
git pull origin %BRANCH% -q
echo.

if %errorlevel% neq 0 (
    echo %RED%  [X] Download failed! Check your internet connection.%RESET%
    timeout /t 3 /nobreak > nul
    pause
    exit /b 1
)
echo %GREEN%  [√] Download complete!%RESET%
echo.
timeout /t 1 /nobreak > nul

:: ════════════════════════════════════════════════════════════════════════════
:: STEP 4 — ORGANIZE
:: ════════════════════════════════════════════════════════════════════════════
cls
echo.
echo %BOLD%%CYAN%  ╔══════════════════════════════════════════════╗%RESET%
echo %BOLD%%CYAN%  ║   STEP 4 of 5 — Organizing Files            ║%RESET%
echo %BOLD%%CYAN%  ╚══════════════════════════════════════════════╝%RESET%
echo.

if exist "%DEST%\%FOLDER%" (
    echo %WHITE%  [~] Moving files up to C:\CPC_Files root...%RESET%
    timeout /t 1 /nobreak > nul
    xcopy /e /i /y "%DEST%\%FOLDER%\*" "%DEST%\" >nul
    rmdir /s /q "%DEST%\%FOLDER%"
    echo %GREEN%  [√] Files organized — all content is now directly in C:\CPC_Files\%RESET%
) else (
    echo %YELLOW%  [!] Folder structure already flat — no reorganization needed.%RESET%
)

echo.
echo %WHITE%  [~] Removing git metadata (.git folder)...%RESET%
timeout /t 1 /nobreak > nul
rmdir /s /q "%DEST%\.git"
echo %GREEN%  [√] Cleanup done — .git folder removed%RESET%
echo.
timeout /t 2 /nobreak > nul
goto add_path

:: ════════════════════════════════════════════════════════════════════════════
:ps_method
:: STEP 2+3 — POWERSHELL DOWNLOAD
:: ════════════════════════════════════════════════════════════════════════════
cls
echo.
echo %BOLD%%CYAN%  ╔══════════════════════════════════════════════╗%RESET%
echo %BOLD%%CYAN%  ║   STEP 2-3 of 5 — Downloading Archive       ║%RESET%
echo %BOLD%%CYAN%  ╚══════════════════════════════════════════════╝%RESET%
echo.
echo %CYAN%  [~] Downloading full repo archive from GitHub...%RESET%
echo %DIM%      This may take a moment depending on your connection.%RESET%
echo.
timeout /t 1 /nobreak > nul

powershell -Command ^
  "$dest='C:\CPC_Files';$zip='C:\CPC_Files_temp.zip';$repo='tdipto008/Competitive-Programming-Companion';$folder='CPC_Files';" ^
  "Invoke-WebRequest -Uri ('https://github.com/'+$repo+'/archive/refs/heads/main.zip') -OutFile $zip;" ^
  "Write-Host '  [~] Extracting archive...';" ^
  "Expand-Archive -Path $zip -DestinationPath 'C:\CPC_Files_extracted' -Force;" ^
  "Write-Host '  [~] Locating CPC_Files inside archive...';" ^
  "$src=Get-ChildItem 'C:\CPC_Files_extracted' -Directory | Select-Object -First 1;" ^
  "$srcFolder=Join-Path $src.FullName $folder;" ^
  "Write-Host '  [~] Copying CPC_Files to C:\CPC_Files...';" ^
  "if(Test-Path $dest){Remove-Item $dest -Recurse -Force};" ^
  "Copy-Item -Path $srcFolder -Destination $dest -Recurse;" ^
  "Write-Host '  [~] Cleaning up temporary files...';" ^
  "Remove-Item $zip -Force;Remove-Item 'C:\CPC_Files_extracted' -Recurse -Force;" ^
  "Write-Host '  [√] Done'"

if %errorlevel% neq 0 (
    echo.
    echo %RED%  [X] Download failed! Check your internet connection.%RESET%
    timeout /t 3 /nobreak > nul
    pause
    exit /b 1
)

echo.
echo %GREEN%  [√] Files downloaded and organized into C:\CPC_Files%RESET%
echo.
timeout /t 2 /nobreak > nul

:: ════════════════════════════════════════════════════════════════════════════
:add_path
:: STEP 5 — PATH
:: ════════════════════════════════════════════════════════════════════════════
cls
echo.
echo %BOLD%%CYAN%  ╔══════════════════════════════════════════════╗%RESET%
echo %BOLD%%CYAN%  ║   STEP 5 of 5 — Registering to PATH         ║%RESET%
echo %BOLD%%CYAN%  ╚══════════════════════════════════════════════╝%RESET%
echo.
echo %WHITE%  [~] Checking if C:\CPC_Files is already in PATH...%RESET%
timeout /t 1 /nobreak > nul

echo %PATH% | find /i "C:\CPC_Files" >nul 2>&1
if %errorlevel% == 0 (
    echo %YELLOW%  [!] C:\CPC_Files is already in PATH — skipping this step.%RESET%
    echo.
    timeout /t 1 /nobreak > nul
    goto finish
)

echo %WHITE%  [~] Attempting to add to SYSTEM PATH (requires Admin)...%RESET%
timeout /t 1 /nobreak > nul

for /f "tokens=2*" %%A in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path 2^>nul') do set "SYSPATH=%%B"
setx /M PATH "!SYSPATH!;C:\CPC_Files" >nul 2>&1

if %errorlevel% == 0 (
    echo %GREEN%  [√] Added to SYSTEM PATH successfully.%RESET%
    echo %DIM%      All users on this machine can now run 'CPC' from any terminal.%RESET%
    echo.
    timeout /t 1 /nobreak > nul
    goto finish
)

echo %YELLOW%  [!] System PATH update failed (Admin rights required).%RESET%
echo %WHITE%  [~] Falling back to USER PATH...%RESET%
timeout /t 1 /nobreak > nul

for /f "tokens=2*" %%A in ('reg query "HKCU\Environment" /v Path 2^>nul') do set "USERPATH=%%B"
if not defined USERPATH (
    setx PATH "C:\CPC_Files" >nul 2>&1
) else (
    setx PATH "!USERPATH!;C:\CPC_Files" >nul 2>&1
)

if %errorlevel% == 0 (
    echo %GREEN%  [√] Added to USER PATH successfully.%RESET%
    echo %DIM%      Only this user account can run 'CPC'. Run as Admin for system-wide access.%RESET%
) else (
    echo %RED%  [X] Could not update PATH automatically.%RESET%
    echo %YELLOW%  [!] Please add C:\CPC_Files to PATH manually:%RESET%
    echo %WHITE%      Settings → System → Advanced → Environment Variables%RESET%
)
echo.
timeout /t 1 /nobreak > nul

:: ════════════════════════════════════════════════════════════════════════════
:finish
:: DONE SCREEN
:: ════════════════════════════════════════════════════════════════════════════
cls
echo.
echo %BOLD%%GREEN%  ╔══════════════════════════════════════════════╗%RESET%
echo %BOLD%%GREEN%  ║            Installation Complete!            ║%RESET%
echo %BOLD%%GREEN%  ╚══════════════════════════════════════════════╝%RESET%
echo.
echo %BOLD%%CYAN%  ╔══════════════════════════════════════════════╗%RESET%
echo %BOLD%%CYAN%  ║  Developer Info                              ║%RESET%
echo %BOLD%%CYAN%  ╠══════════════════════════════════════════════╣%RESET%
echo %BOLD%%CYAN%  ║  Name      : Devjyoti Tikader Dipto          ║%RESET%
echo %BOLD%%CYAN%  ║  github    : tdipto008                      ║%RESET%
echo %BOLD%%CYAN%  ║  CF Handle : dipto_008                       ║%RESET%
echo %BOLD%%CYAN%  ║  Email     : tdipto008@gmail.com             ║%RESET%
echo %BOLD%%CYAN%  ╠══════════════════════════════════════════════╣%RESET%
echo %BOLD%%CYAN%  ║  What was installed                          ║%RESET%
echo %BOLD%%CYAN%  ╠══════════════════════════════════════════════╣%RESET%
echo %BOLD%%WHITE%  ║  Location  : C:\CPC_Files                    ║%RESET%
echo %BOLD%%WHITE%  ║  PATH      : C:\CPC_Files registered         ║%RESET%
echo %BOLD%%WHITE%  ║  CPC.bat   : accessible from any folder      ║%RESET%
echo %BOLD%%CYAN%  ╠══════════════════════════════════════════════╣%RESET%
echo %BOLD%%CYAN%  ║  Commands you can now run anywhere           ║%RESET%
echo %BOLD%%CYAN%  ╠══════════════════════════════════════════════╣%RESET%
echo %BOLD%%WHITE%  ║    CPC -parse                ← parse problem ║%RESET%
echo %BOLD%%WHITE%  ║    CPC file.cpp              ← run tests     ║%RESET%
echo %BOLD%%WHITE%  ║    CPC -d file.cpp           ← debug mode    ║%RESET%
echo %BOLD%%WHITE%  ║    CPC -checker.cpp file.cpp ← custom check  ║%RESET%
echo %BOLD%%CYAN%  ╠══════════════════════════════════════════════╣%RESET%
echo %BOLD%%YELLOW%  ║  Restart VS Code or terminal for PATH to     ║%RESET%
echo %BOLD%%YELLOW%  ║  take effect before using CPC!               ║%RESET%
echo %BOLD%%CYAN%  ╚══════════════════════════════════════════════╝%RESET%
echo.
pause