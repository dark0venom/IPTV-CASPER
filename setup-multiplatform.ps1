# IPTV Casper - Multi-Platform Setup Script
# This script helps you build and run the app on any platform

Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  🌍 IPTV Casper - Cross-Platform IPTV Player" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Check Flutter
Write-Host "Checking Flutter installation..." -ForegroundColor Yellow
$flutterInstalled = Get-Command flutter -ErrorAction SilentlyContinue

if (-not $flutterInstalled) {
    Write-Host "❌ Flutter is not installed!" -ForegroundColor Red
    Write-Host "Please install from: https://flutter.dev/docs/get-started/install" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "✓ Flutter is installed" -ForegroundColor Green
Write-Host ""

# Check available devices
Write-Host "Checking available devices..." -ForegroundColor Yellow
flutter devices
Write-Host ""

# Install dependencies
Write-Host "Installing dependencies..." -ForegroundColor Yellow
flutter pub get

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to install dependencies!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "✓ Dependencies installed" -ForegroundColor Green
Write-Host ""

# Platform selection menu
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Select Platform:" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Desktop Platforms:" -ForegroundColor Yellow
Write-Host "  1. Windows (Debug)" -ForegroundColor White
Write-Host "  2. Windows (Release)" -ForegroundColor White
Write-Host "  3. macOS (Debug)" -ForegroundColor White
Write-Host "  4. macOS (Release)" -ForegroundColor White
Write-Host "  5. Linux (Debug)" -ForegroundColor White
Write-Host "  6. Linux (Release)" -ForegroundColor White
Write-Host ""
Write-Host "Mobile Platforms:" -ForegroundColor Yellow
Write-Host "  7. Android (Debug)" -ForegroundColor White
Write-Host "  8. Android (Release APK)" -ForegroundColor White
Write-Host "  9. Android (Release Bundle)" -ForegroundColor White
Write-Host " 10. iOS (Debug)" -ForegroundColor White
Write-Host " 11. iOS (Release)" -ForegroundColor White
Write-Host ""
Write-Host "Web Platform:" -ForegroundColor Yellow
Write-Host " 12. Web (Chrome)" -ForegroundColor White
Write-Host " 13. Web (Release Build)" -ForegroundColor White
Write-Host ""
Write-Host "Other:" -ForegroundColor Yellow
Write-Host " 14. Enable all desktop platforms" -ForegroundColor White
Write-Host " 15. Run flutter doctor" -ForegroundColor White
Write-Host " 16. Exit" -ForegroundColor White
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

$choice = Read-Host "Enter your choice (1-16)"

switch ($choice) {
    "1" {
        Write-Host ""
        Write-Host "🪟 Running on Windows (Debug)..." -ForegroundColor Green
        flutter run -d windows
    }
    "2" {
        Write-Host ""
        Write-Host "🪟 Building for Windows (Release)..." -ForegroundColor Green
        flutter build windows --release
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ Build successful!" -ForegroundColor Green
            Write-Host "Location: build\windows\runner\Release\iptv_casper.exe" -ForegroundColor Yellow
            $open = Read-Host "Open folder? (y/n)"
            if ($open -eq "y") { start "build\windows\runner\Release" }
        }
    }
    "3" {
        Write-Host ""
        Write-Host "🍎 Running on macOS (Debug)..." -ForegroundColor Green
        flutter run -d macos
    }
    "4" {
        Write-Host ""
        Write-Host "🍎 Building for macOS (Release)..." -ForegroundColor Green
        flutter build macos --release
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ Build successful!" -ForegroundColor Green
            Write-Host "Location: build/macos/Build/Products/Release/" -ForegroundColor Yellow
        }
    }
    "5" {
        Write-Host ""
        Write-Host "🐧 Running on Linux (Debug)..." -ForegroundColor Green
        flutter run -d linux
    }
    "6" {
        Write-Host ""
        Write-Host "🐧 Building for Linux (Release)..." -ForegroundColor Green
        flutter build linux --release
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ Build successful!" -ForegroundColor Green
            Write-Host "Location: build/linux/x64/release/bundle/" -ForegroundColor Yellow
        }
    }
    "7" {
        Write-Host ""
        Write-Host "📱 Running on Android (Debug)..." -ForegroundColor Green
        flutter run
    }
    "8" {
        Write-Host ""
        Write-Host "📱 Building Android APK (Release)..." -ForegroundColor Green
        flutter build apk --release
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ Build successful!" -ForegroundColor Green
            Write-Host "Location: build/app/outputs/flutter-apk/app-release.apk" -ForegroundColor Yellow
        }
    }
    "9" {
        Write-Host ""
        Write-Host "📱 Building Android App Bundle (Release)..." -ForegroundColor Green
        flutter build appbundle --release
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ Build successful!" -ForegroundColor Green
            Write-Host "Location: build/app/outputs/bundle/release/app-release.aab" -ForegroundColor Yellow
        }
    }
    "10" {
        Write-Host ""
        Write-Host "📱 Running on iOS (Debug)..." -ForegroundColor Green
        flutter run
    }
    "11" {
        Write-Host ""
        Write-Host "📱 Building for iOS (Release)..." -ForegroundColor Green
        Write-Host "Note: iOS builds require Xcode and code signing" -ForegroundColor Yellow
        flutter build ios --release
    }
    "12" {
        Write-Host ""
        Write-Host "🌐 Running on Web (Chrome)..." -ForegroundColor Green
        flutter run -d chrome
    }
    "13" {
        Write-Host ""
        Write-Host "🌐 Building for Web (Release)..." -ForegroundColor Green
        flutter build web --release
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ Build successful!" -ForegroundColor Green
            Write-Host "Location: build/web/" -ForegroundColor Yellow
            Write-Host "Deploy this folder to any web hosting service" -ForegroundColor Cyan
        }
    }
    "14" {
        Write-Host ""
        Write-Host "🔧 Enabling all desktop platforms..." -ForegroundColor Green
        flutter config --enable-windows-desktop
        flutter config --enable-macos-desktop
        flutter config --enable-linux-desktop
        flutter config --enable-web
        Write-Host "✓ All platforms enabled!" -ForegroundColor Green
        Write-Host ""
        flutter config
    }
    "15" {
        Write-Host ""
        Write-Host "🔍 Running Flutter Doctor..." -ForegroundColor Green
        flutter doctor -v
    }
    "16" {
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
Write-Host ""
Read-Host "Press Enter to exit"
