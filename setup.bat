@echo off
echo ========================================
echo   IPTV Casper - Windows IPTV Player
echo ========================================
echo.

echo Checking Flutter installation...
where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Flutter is not installed!
    echo.
    echo Please install Flutter from:
    echo https://flutter.dev/docs/get-started/install/windows
    echo.
    pause
    exit /b 1
)

echo [OK] Flutter is installed
echo.

echo Checking Flutter version...
flutter --version
echo.

echo Installing dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo [ERROR] Failed to install dependencies!
    pause
    exit /b 1
)

echo [OK] Dependencies installed successfully
echo.

echo ========================================
echo What would you like to do?
echo ========================================
echo 1. Run in debug mode
echo 2. Build for release
echo 3. Exit
echo.
set /p choice="Enter your choice (1-3): "

if "%choice%"=="1" (
    echo.
    echo Starting IPTV Casper in debug mode...
    echo.
    flutter run -d windows
) else if "%choice%"=="2" (
    echo.
    echo Building IPTV Casper for release...
    echo.
    flutter build windows --release
    if %errorlevel% equ 0 (
        echo.
        echo [OK] Build completed successfully!
        echo Executable location: build\windows\runner\Release\iptv_casper.exe
        echo.
        set /p openFolder="Would you like to open the build folder? (y/n): "
        if /i "%openFolder%"=="y" (
            start "" "build\windows\runner\Release"
        )
    ) else (
        echo [ERROR] Build failed!
    )
) else if "%choice%"=="3" (
    echo Exiting...
    exit /b 0
) else (
    echo Invalid choice!
    exit /b 1
)

echo.
echo Done!
pause
