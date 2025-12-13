@echo off
setlocal DisableDelayedExpansion
title Goldberg Auto-Patcher (v2.0)

:: --- CONFIGURATION ---
:: %~dp0 is the folder where this .bat file lives
set "TOOLS_DIR=%~dp0tools"
set "X86_DLL=%~dp0emu_x86\steam_api.dll"
set "X64_DLL=%~dp0emu_x64\steam_api64.dll"

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

:: 1. Search for 64-bit DLL first (Preferred)
for /f "delims=" %%F in ('dir /s /b "%TARGET_DIR%\steam_api64.dll" 2^>nul') do (
    set "FOUND_DLL=%%F"
    set "IS_64_BIT=1"
    goto :FileFound
)

:: 2. Search for 32-bit DLL if 64-bit not found
if not defined FOUND_DLL (
    for /f "delims=" %%F in ('dir /s /b "%TARGET_DIR%\steam_api.dll" 2^>nul') do (
        set "FOUND_DLL=%%F"
        set "IS_64_BIT=0"
        goto :FileFound
    )
)

:: 3. If neither is found
if not defined FOUND_DLL (
    echo [ERROR] Could not find steam_api.dll or steam_api64.dll ANYWHERE.
    echo.
    echo Please ensure you are dropping the main game folder.
    pause
    exit /b
)

:FileFound
:: Extract directory and filename
for %%I in ("%FOUND_DLL%") do (
    set "DLL_DIR=%%~dpI"
    set "DLL_NAME=%%~nxI"
)

:: Move into the actual directory
cd /d "%DLL_DIR%"

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

:: --- BACKUP ORIGINAL ---
if not exist "%DLL_NAME%.bak" (
    echo [INFO] Backing up original %DLL_NAME%...
    copy "%DLL_NAME%" "%DLL_NAME%.bak" >nul
) else (
    echo [INFO] Backup already exists. Using current DLL as source...
)

:: --- SAFETY: REMOVE READ-ONLY ATTRIBUTE ---
:: Fixes "Access Denied" if file came from ISO/Disc
attrib -r "%DLL_NAME%"

:: --- GENERATE INTERFACES ---
echo [INFO] Generating Interface Map (Anti-Crash)...
if not exist "%TOOLS_DIR%\generate_interfaces_file.exe" (
    echo [ERROR] Tool not found at: "%TOOLS_DIR%\generate_interfaces_file.exe"
    echo Check that your 'tools' folder is next to this script.
    pause
    exit /b
)

:: Run tool against the BACKUP to read the original interfaces
"%TOOLS_DIR%\generate_interfaces_file.exe" "%DLL_NAME%.bak"

if exist "steam_interfaces.txt" (
    echo [SUCCESS] steam_interfaces.txt created.
) else (
    echo [WARNING] Failed to generate interfaces. Game might crash.
)

:: --- APPLY GOLDBERG ---
echo [INFO] Applying Goldberg Emulator...
copy /Y "%NEW_DLL%" "%DLL_NAME%" >nul

:: --- APPID SETUP ---
if exist "steam_appid.txt" (
    echo [INFO] steam_appid.txt already exists. Skipping.
) else (
    :: Switch to Delayed Expansion ONLY here to handle user input safely
    setlocal EnableDelayedExpansion
    echo.
    echo --------------------------------------------------------
    echo ENTER STEAM APPID
    echo (Find this number in the store URL: store.steampowered.com/app/XXXXX)
    echo --------------------------------------------------------
    
    :AskID
    set /p "APPID=AppID: "
    
    :: Validation: Check if empty
    if "!APPID!"=="" (
        echo Error: AppID cannot be empty.
        goto :AskID
    )
    
    echo !APPID!> steam_appid.txt
    echo [SUCCESS] steam_appid.txt created with ID: !APPID!
    endlocal
)

echo.
echo ========================================================
echo             PATCH COMPLETE!
echo ========================================================
echo Location: "%DLL_DIR%"
echo.
pause