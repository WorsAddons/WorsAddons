@echo off
setlocal EnableDelayedExpansion

:: Check for administrative privileges
:: If not run as admin, prompt to run as admin
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo This script requires administrator privileges.
    echo Please allow the script to run as administrator.
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: Set temporary directory for download
set "TEMP_DIR=%TEMP%\WorsAddonsDownload"
set "ZIP_FILE=%TEMP_DIR%\main.zip"
set "CONFIG_FILE=%~dp0WorsAddonsInstallconfig.txt"
set "URL=https://github.com/WorsAddons/WorsAddons/archive/refs/heads/main.zip"

:: Create the temporary directory if it doesn't exist
if not exist "%TEMP_DIR%" (
    mkdir "%TEMP_DIR%"
)

:: Check if there's an existing path in config.txt and read it if valid
if exist "%CONFIG_FILE%" (
    set /p DEST_PATH=<"%CONFIG_FILE%"
    if not defined DEST_PATH (
        echo Config file is empty or invalid. Please enter a new path.
        del "%CONFIG_FILE%"
    ) else (
        echo Using saved path: !DEST_PATH!
    )
)

:: Prompt user for destination path if not read from config
if not defined DEST_PATH (
    echo Example Path: C:\Program Files\Ascension Launcher\resources\ascension_ptr\Interface\AddOns
    set /p DEST_PATH="Enter the destination path: "
    :: Save the path to config.txt without extra spaces or newlines
    powershell -Command "Set-Content -Path '!CONFIG_FILE!' -Value $env:DEST_PATH -NoNewline"
    echo Path saved to WorsAddonsInstallconfig.txt
)

:: Download the zip file
echo Downloading repository...
powershell -command "Invoke-WebRequest -Uri '!URL!' -OutFile '!ZIP_FILE!'"

:: Check if download was successful
if not exist "!ZIP_FILE!" (
    echo Failed to download the file. Exiting.
    exit /b
)

:: Unzip the file to temporary folder
echo Unzipping...
powershell -command "Expand-Archive -Path '!ZIP_FILE!' -DestinationPath '!TEMP_DIR!'"

:: Locate the unzipped folder
set "UNZIPPED_DIR=!TEMP_DIR!\WorsAddons-main"

:: Copy all folders inside the unzipped folder to destination, replacing existing files
echo Copying folders...

for /D %%G in ("!UNZIPPED_DIR!\*") do (
    echo Copying folder %%~nxG...
    xcopy "%%~fG" "!DEST_PATH!\%%~nxG\" /E /Y
)

:: Clean up temporary files
echo Cleaning up...
rd /s /q "!TEMP_DIR!"

echo Done!
pause
