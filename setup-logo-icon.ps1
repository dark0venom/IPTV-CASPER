# Logo and Icon Setup Script for IPTV Casper
# This script helps you set up custom logos and icons

Write-Host "================================" -ForegroundColor Cyan
Write-Host "IPTV Casper - Logo & Icon Setup" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Check if assets/images directory exists
$assetsDir = "assets\images"
if (-not (Test-Path $assetsDir)) {
    Write-Host "Creating assets/images directory..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $assetsDir -Force | Out-Null
    Write-Host "✓ Directory created" -ForegroundColor Green
}

Write-Host ""
Write-Host "Setup Options:" -ForegroundColor Cyan
Write-Host "1. Create simple programmatic icon (using Python)"
Write-Host "2. Use online icon generator (opens browser)"
Write-Host "3. Manual setup instructions"
Write-Host "4. Generate launcher icons (requires icon file)"
Write-Host "5. Exit"
Write-Host ""

$choice = Read-Host "Select an option (1-5)"

switch ($choice) {
    "1" {
        Write-Host ""
        Write-Host "Creating programmatic icon..." -ForegroundColor Yellow
        
        # Check if Python is installed
        $python = Get-Command python -ErrorAction SilentlyContinue
        if ($python) {
            Write-Host "Python found. Installing required package..." -ForegroundColor Green
            python -m pip install --quiet pillow
            
            Write-Host "Generating icon..." -ForegroundColor Yellow
            python create_icon.py
            
            if (Test-Path "app_icon.png") {
                Move-Item -Path "app_icon.png" -Destination "$assetsDir\app_icon.png" -Force
                Write-Host ""
                Write-Host "✓ Icon created and moved to $assetsDir" -ForegroundColor Green
                Write-Host ""
                Write-Host "Next step: Run option 4 to generate launcher icons" -ForegroundColor Cyan
            }
        } else {
            Write-Host "✗ Python not found. Please install Python first." -ForegroundColor Red
            Write-Host "Download from: https://www.python.org/downloads/" -ForegroundColor Yellow
        }
    }
    
    "2" {
        Write-Host ""
        Write-Host "Opening online icon generators..." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Recommended sites:" -ForegroundColor Cyan
        Write-Host "1. https://icon.kitchen - Best for app icons"
        Write-Host "2. https://appicon.co - Complete icon generator"
        Write-Host "3. https://icoconvert.com - ICO converter for Windows"
        Write-Host ""
        
        $site = Read-Host "Which site? (1-3)"
        switch ($site) {
            "1" { Start-Process "https://icon.kitchen" }
            "2" { Start-Process "https://appicon.co" }
            "3" { Start-Process "https://icoconvert.com" }
        }
        
        Write-Host ""
        Write-Host "After generating your icon:" -ForegroundColor Cyan
        Write-Host "1. Download the icon"
        Write-Host "2. Save as 'app_icon.png' in $assetsDir"
        Write-Host "3. Run this script again and choose option 4"
    }
    
    "3" {
        Write-Host ""
        Write-Host "=== Manual Setup Instructions ===" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Step 1: Create or obtain your icon" -ForegroundColor Yellow
        Write-Host "  - Size: 1024x1024 pixels minimum"
        Write-Host "  - Format: PNG with transparent background"
        Write-Host "  - Design: Simple, recognizable at small sizes"
        Write-Host ""
        Write-Host "Step 2: Place icon file" -ForegroundColor Yellow
        Write-Host "  - Save as: $assetsDir\app_icon.png"
        Write-Host ""
        Write-Host "Step 3: Update pubspec.yaml" -ForegroundColor Yellow
        Write-Host "  - Uncomment the 'image_path' lines"
        Write-Host "  - Ensure it points to: assets/images/app_icon.png"
        Write-Host ""
        Write-Host "Step 4: Generate launcher icons" -ForegroundColor Yellow
        Write-Host "  - Run: flutter pub get"
        Write-Host "  - Run: flutter pub run flutter_launcher_icons"
        Write-Host ""
        Write-Host "Step 5: Rebuild app" -ForegroundColor Yellow
        Write-Host "  - Run: flutter run -d windows"
        Write-Host ""
        Write-Host "For detailed guide, see: LOGO_ICON_IMPLEMENTATION.md" -ForegroundColor Cyan
    }
    
    "4" {
        Write-Host ""
        Write-Host "Generating launcher icons..." -ForegroundColor Yellow
        
        # Check if icon file exists
        if (Test-Path "$assetsDir\app_icon.png") {
            Write-Host "✓ Icon file found" -ForegroundColor Green
            
            # Update pubspec.yaml to uncomment image_path
            Write-Host "Updating pubspec.yaml..." -ForegroundColor Yellow
            $pubspec = Get-Content "pubspec.yaml" -Raw
            $pubspec = $pubspec -replace '# image_path: "assets/images/app_icon.png"', 'image_path: "assets/images/app_icon.png"'
            Set-Content "pubspec.yaml" -Value $pubspec
            
            Write-Host "Running flutter pub get..." -ForegroundColor Yellow
            flutter pub get
            
            Write-Host "Generating icons for all platforms..." -ForegroundColor Yellow
            flutter pub run flutter_launcher_icons
            
            Write-Host ""
            Write-Host "✓ Launcher icons generated!" -ForegroundColor Green
            Write-Host ""
            Write-Host "Icons created for:" -ForegroundColor Cyan
            Write-Host "  ✓ Windows"
            Write-Host "  ✓ Android"
            Write-Host "  ✓ iOS"
            Write-Host "  ✓ macOS"
            Write-Host "  ✓ Linux"
            Write-Host "  ✓ Web"
            Write-Host ""
            Write-Host "Next: Rebuild your app to see the new icon" -ForegroundColor Cyan
            Write-Host "Run: flutter run -d windows" -ForegroundColor Yellow
        } else {
            Write-Host "✗ Icon file not found at $assetsDir\app_icon.png" -ForegroundColor Red
            Write-Host ""
            Write-Host "Please:" -ForegroundColor Yellow
            Write-Host "1. Create or obtain an icon file (1024x1024 PNG)"
            Write-Host "2. Save it as: $assetsDir\app_icon.png"
            Write-Host "3. Run this script again"
        }
    }
    
    "5" {
        Write-Host "Exiting..." -ForegroundColor Yellow
        exit
    }
    
    default {
        Write-Host "Invalid option" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host "Setup script completed!" -ForegroundColor Green
Write-Host ""
Write-Host "For more help, see:" -ForegroundColor Cyan
Write-Host "  - LOGO_ICON_IMPLEMENTATION.md (detailed guide)"
Write-Host "  - lib/widgets/app_logo.dart (programmatic logo widgets)"
Write-Host ""
Read-Host "Press Enter to exit"
