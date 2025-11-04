# IPTV Casper - Setup Script
# Run this script to initialize and run the IPTV player

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  IPTV Casper - Windows IPTV Player" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Flutter is installed
Write-Host "Checking Flutter installation..." -ForegroundColor Yellow
$flutterInstalled = Get-Command flutter -ErrorAction SilentlyContinue

if (-not $flutterInstalled) {
    Write-Host "❌ Flutter is not installed!" -ForegroundColor Red
    Write-Host "Please install Flutter from: https://flutter.dev/docs/get-started/install/windows" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "✓ Flutter is installed" -ForegroundColor Green
Write-Host ""

# Check Flutter version
Write-Host "Checking Flutter version..." -ForegroundColor Yellow
flutter --version
Write-Host ""

# Run flutter doctor
Write-Host "Running Flutter doctor..." -ForegroundColor Yellow
flutter doctor
Write-Host ""

# Get dependencies
Write-Host "Installing dependencies..." -ForegroundColor Yellow
flutter pub get

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to install dependencies!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "✓ Dependencies installed successfully" -ForegroundColor Green
Write-Host ""

# Ask user what to do
Write-Host "What would you like to do?" -ForegroundColor Cyan
Write-Host "1. Run in debug mode" -ForegroundColor White
Write-Host "2. Build for release" -ForegroundColor White
Write-Host "3. Exit" -ForegroundColor White
Write-Host ""
$choice = Read-Host "Enter your choice (1-3)"

switch ($choice) {
    "1" {
        Write-Host ""
        Write-Host "Starting IPTV Casper in debug mode..." -ForegroundColor Green
        Write-Host ""
        flutter run -d windows
    }
    "2" {
        Write-Host ""
        Write-Host "Building IPTV Casper for release..." -ForegroundColor Green
        Write-Host ""
        flutter build windows --release
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "✓ Build completed successfully!" -ForegroundColor Green
            Write-Host "Executable location: build\windows\runner\Release\iptv_casper.exe" -ForegroundColor Yellow
            Write-Host ""
            
            $openFolder = Read-Host "Would you like to open the build folder? (y/n)"
            if ($openFolder -eq "y" -or $openFolder -eq "Y") {
                Start-Process "build\windows\runner\Release"
            }
        } else {
            Write-Host "❌ Build failed!" -ForegroundColor Red
        }
    }
    "3" {
        Write-Host "Exiting..." -ForegroundColor Yellow
        exit 0
    }
    default {
        Write-Host "Invalid choice!" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "Done!" -ForegroundColor Green
