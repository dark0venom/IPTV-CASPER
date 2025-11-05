# IPTV Casper - Installer Builder Script
# This script creates a Windows installer using Inno Setup

Write-Host "================================" -ForegroundColor Cyan
Write-Host "IPTV Casper Installer Builder" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Check if Inno Setup is installed
$innoSetupPaths = @(
    "C:\Program Files (x86)\Inno Setup 6\ISCC.exe",
    "C:\Program Files\Inno Setup 6\ISCC.exe",
    "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
    "${env:ProgramFiles}\Inno Setup 6\ISCC.exe"
)

$isccPath = $null
foreach ($path in $innoSetupPaths) {
    if (Test-Path $path) {
        $isccPath = $path
        break
    }
}

if ($null -eq $isccPath) {
    Write-Host "[X] Inno Setup not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Inno Setup is required to build the installer." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please download and install Inno Setup from:" -ForegroundColor Cyan
    Write-Host "https://jrsoftware.org/isdl.php" -ForegroundColor White
    Write-Host ""
    Write-Host "Download: Inno Setup 6.x (stable version)" -ForegroundColor Yellow
    Write-Host ""
    $download = Read-Host "Open download page in browser? (Y/N)"
    if ($download -eq "Y" -or $download -eq "y") {
        Start-Process "https://jrsoftware.org/isdl.php"
    }
    Write-Host ""
    Write-Host "After installing Inno Setup, run this script again." -ForegroundColor Cyan
    exit 1
}

Write-Host "[OK] Inno Setup found: $isccPath" -ForegroundColor Green
Write-Host ""

# Check if production build exists
if (-not (Test-Path "production-release\iptv_casper.exe")) {
    Write-Host "[X] Production build not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please build the release version first:" -ForegroundColor Yellow
    Write-Host "  flutter build windows --release" -ForegroundColor White
    Write-Host ""
    $build = Read-Host "Run build now? (Y/N)"
    if ($build -eq "Y" -or $build -eq "y") {
        Write-Host ""
        Write-Host "Building release version..." -ForegroundColor Yellow
        flutter build windows --release
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "[X] Build failed!" -ForegroundColor Red
            exit 1
        }
        
        Write-Host "[OK] Release build complete" -ForegroundColor Green
        Write-Host ""
        Write-Host "Copying to production folder..." -ForegroundColor Yellow
        New-Item -ItemType Directory -Path "production-release" -Force | Out-Null
        Copy-Item -Path "build\windows\x64\runner\Release\*" -Destination "production-release\" -Recurse -Force
        Write-Host "[OK] Files copied" -ForegroundColor Green
        Write-Host ""
    } else {
        exit 1
    }
}

Write-Host "[OK] Production build found" -ForegroundColor Green

# Check if ICO icon exists
if (-not (Test-Path "assets\images\app_icon.ico")) {
    Write-Host "[!] ICO icon not found!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Converting PNG to ICO..." -ForegroundColor Yellow
    python convert_icon_to_ico.py
    
    if (-not (Test-Path "assets\images\app_icon.ico")) {
        Write-Host "[X] Icon conversion failed!" -ForegroundColor Red
        Write-Host "Continuing without custom icon..." -ForegroundColor Yellow
    } else {
        Write-Host "[OK] Icon converted" -ForegroundColor Green
    }
} else {
    Write-Host "[OK] ICO icon found" -ForegroundColor Green
}

Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host "Building Installer" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Create output directory
New-Item -ItemType Directory -Path "installer\output" -Force | Out-Null

# Build the installer
Write-Host "Compiling installer script..." -ForegroundColor Yellow
Write-Host ""

$scriptPath = Resolve-Path "installer\setup.iss"
& $isccPath $scriptPath

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "================================" -ForegroundColor Cyan
    Write-Host "[OK] Installer Built Successfully!" -ForegroundColor Green
    Write-Host "================================" -ForegroundColor Cyan
    Write-Host ""
    
    # Get installer file info
    $installerFile = Get-Item "installer\output\IPTV-Casper-Setup-v*.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
    
    if ($installerFile) {
        $installerSize = [math]::Round($installerFile.Length/1MB, 2)
        
        Write-Host "Installer Information:" -ForegroundColor Cyan
        Write-Host "  Name:     $($installerFile.Name)" -ForegroundColor White
        Write-Host "  Size:     $installerSize MB" -ForegroundColor White
        Write-Host "  Location: $($installerFile.FullName)" -ForegroundColor White
        Write-Host ""
        
        Write-Host "Features:" -ForegroundColor Cyan
        Write-Host "  [+] Professional installer wizard" -ForegroundColor White
        Write-Host "  [+] Start Menu shortcuts" -ForegroundColor White
        Write-Host "  [+] Desktop icon (optional)" -ForegroundColor White
        Write-Host "  [+] File associations (.m3u, .m3u8)" -ForegroundColor White
        Write-Host "  [+] Uninstaller included" -ForegroundColor White
        Write-Host "  [+] Windows 10/11 compatible" -ForegroundColor White
        Write-Host ""
        
        Write-Host "What to do next:" -ForegroundColor Cyan
        Write-Host "  1. Test the installer on your machine" -ForegroundColor Yellow
        Write-Host "  2. Test on a clean Windows VM" -ForegroundColor Yellow
        Write-Host "  3. (Optional) Sign the installer" -ForegroundColor Yellow
        Write-Host "  4. Distribute via GitHub Releases or website" -ForegroundColor Yellow
        Write-Host ""
        
        # Offer to run the installer
        $test = Read-Host "Test the installer now? (Y/N)"
        if ($test -eq "Y" -or $test -eq "y") {
            Write-Host ""
            Write-Host "Launching installer..." -ForegroundColor Yellow
            Start-Process $installerFile.FullName
        }
        
        Write-Host ""
        $openFolder = Read-Host "Open installer folder? (Y/N)"
        if ($openFolder -eq "Y" -or $openFolder -eq "y") {
            Invoke-Item "installer\output"
        }
    }
} else {
    Write-Host ""
    Write-Host "[X] Installer build failed!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Check the output above for errors." -ForegroundColor Yellow
    Write-Host "Common issues:" -ForegroundColor Cyan
    Write-Host "  * Missing files referenced in setup.iss" -ForegroundColor White
    Write-Host "  * Incorrect file paths" -ForegroundColor White
    Write-Host "  * Syntax errors in the script" -ForegroundColor White
    exit 1
}

Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host "Build Complete!" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""
