@echo off
setlocal DisableDelayedExpansion
title Goldberg Auto-Patcher (v2.2 - Network Ready)

:: --- CONFIGURATION ---
set "TOOLS_DIR=%~dp0tools"
set "X86_DLL=%~dp0emu_x86\steam_api.dll"
set "X64_DLL=%~dp0emu_x64\steam_api64.dll"

:: --- PRE-FLIGHT CHECK ---
if not exist "%TOOLS_DIR%\generate_interfaces_file.exe" (
    echo [ERROR] Critical file missing: "%TOOLS_DIR%\generate_interfaces_file.exe"
    echo.
    echo Please ensure the 'tools', 'emu_x86', and 'emu_x64' folders 
    echo are in the same directory as this script.
    pause
    exit /b
)

:: --- INPUT CHECK ---
set "TARGET_DIR=%~1"
if "%TARGET_DIR%"=="" (
    echo.
    echo [ERROR] No game folder detected.
    echo.
    echo DRAG AND DROP A GAME FOLDER ONTO THIS SCRIPT TO PATCH IT.
    echo.
    pause
    exit /b
)

echo.
echo ========================================================
echo        GOLDBERG EMULATOR AUTO-PATCHER
echo ========================================================
echo Root Target: "%TARGET_DIR%"
echo Scanning for Steam DLLs...
echo.

:: --- RECURSIVE SEARCH ---
set "FOUND_DLL="
set "IS_64_BIT=0"

:: 1. Search for 64-bit DLL first
for /f "delims=" %%F in ('dir /s /b "%TARGET_DIR%\steam_api64.dll" 2^>nul') do (
    set "FOUND_DLL=%%F"
    set "IS_64_BIT=1"
    goto :FileFound
)

:: 2. Search for 32-bit DLL
if not defined FOUND_DLL (
    for /f "delims=" %%F in ('dir /s /b "%TARGET_DIR%\steam_api.dll" 2^>nul') do (
        set "FOUND_DLL=%%F"
        set "IS_64_BIT=0"
        goto :FileFound
    )
)

:: 3. Not found
if not defined FOUND_DLL (
    echo [ERROR] Could not find steam_api.dll or steam_api64.dll.
    pause
    exit /b
)

:FileFound
for %%I in ("%FOUND_DLL%") do (
    set "DLL_DIR=%%~dpI"
    set "DLL_NAME=%%~nxI"
)

:: Enter Directory safely
pushd "%DLL_DIR%"

echo [INFO] Found target at:
echo        "%DLL_DIR%"
echo.

if "%IS_64_BIT%"=="1" (
    set "NEW_DLL=%X64_DLL%"
    echo [INFO] Architecture: 64-bit
) else (
    set "NEW_DLL=%X86_DLL%"
    echo [INFO] Architecture: 32-bit
)

:: --- BACKUP ---
if not exist "%DLL_NAME%.bak" (
    echo [INFO] Backing up original %DLL_NAME%...
    copy "%DLL_NAME%" "%DLL_NAME%.bak" >nul
)

:: --- SAFETY ---
attrib -r "%DLL_NAME%"

:: --- GENERATE INTERFACES ---
echo [INFO] Generating Interface Map...
"%TOOLS_DIR%\generate_interfaces_file.exe" "%DLL_NAME%.bak"

:: --- APPLY GOLDBERG ---
echo [INFO] Applying Goldberg Emulator...
copy /Y "%NEW_DLL%" "%DLL_NAME%" >nul

:: --- APPID SETUP ---
if not exist "steam_appid.txt" (
    setlocal EnableDelayedExpansion
    echo.
    echo --------------------------------------------------------
    echo ENTER STEAM APPID
    echo (Find this number in the store URL: store.steampowered.com/app/XXXXX)
    echo --------------------------------------------------------
    :AskID
    set /p "APPID=AppID: "
    if "!APPID!"=="" goto :AskID
    echo !APPID!> steam_appid.txt
    endlocal
)

:: --- GLOBAL NETWORK CONFIG PREP ---
:: This ensures the folder exists so the user can edit their IP settings immediately
if not exist "%APPDATA%\Goldberg SteamEmu Saves\settings" (
    echo.
    echo [INFO] Creating Global Network Config folder...
    mkdir "%APPDATA%\Goldberg SteamEmu Saves\settings"
)

:: Cleanup
popd

echo.
echo ========================================================
echo             PATCH COMPLETE!
echo ========================================================
echo.
echo 1. Game patched successfully.
echo 2. Global settings folder is ready at:
echo    %%AppData%%\Goldberg SteamEmu Saves\settings
echo.
pause