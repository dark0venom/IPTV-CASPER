# IPTV Casper - Quick Deployment Script
# Creates production package ready for distribution

Write-Host "================================" -ForegroundColor Cyan
Write-Host "IPTV Casper Production Package" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Check if production files exist
if (-not (Test-Path "build\windows\x64\runner\Release\iptv_casper.exe")) {
    Write-Host "ERROR: Release build not found!" -ForegroundColor Red
    Write-Host "Please run: flutter build windows --release" -ForegroundColor Yellow
    exit 1
}

Write-Host "✓ Release build found" -ForegroundColor Green

# Create production directory
Write-Host "Creating production package..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path "production-release" -Force | Out-Null

# Copy release files
Write-Host "Copying release files..." -ForegroundColor Yellow
Copy-Item -Path "build\windows\x64\runner\Release\*" -Destination "production-release\" -Recurse -Force

# Check if README exists, if not create it
if (-not (Test-Path "production-release\README.txt")) {
    Write-Host "Creating README.txt..." -ForegroundColor Yellow
    # README content would be created here
}

Write-Host "✓ Files copied" -ForegroundColor Green

# Get version from pubspec.yaml
$version = "1.0.0"
if (Test-Path "pubspec.yaml") {
    $pubspec = Get-Content "pubspec.yaml" -Raw
    if ($pubspec -match "version:\s*([0-9.]+)") {
        $version = $matches[1]
    }
}

# Create ZIP package
$zipName = "IPTV-Casper-Windows-x64-v$version.zip"
Write-Host "Creating distribution package: $zipName" -ForegroundColor Yellow
Compress-Archive -Path "production-release\*" -DestinationPath $zipName -Force

Write-Host "✓ Package created" -ForegroundColor Green
Write-Host ""

# Display package information
$zipFile = Get-Item $zipName
$zipSizeMB = [math]::Round($zipFile.Length/1MB, 2)

Write-Host "================================" -ForegroundColor Cyan
Write-Host "Package Information" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host "Version: $version" -ForegroundColor White
Write-Host "Package: $zipName" -ForegroundColor White
Write-Host "Size: $zipSizeMB MB" -ForegroundColor White
Write-Host "Location: $($zipFile.FullName)" -ForegroundColor White
Write-Host ""

# Calculate folder size
$folderSize = (Get-ChildItem "production-release" -Recurse | Measure-Object -Property Length -Sum).Sum
$folderSizeMB = [math]::Round($folderSize/1MB, 2)
Write-Host "Uncompressed: $folderSizeMB MB" -ForegroundColor Gray
Write-Host ""

Write-Host "================================" -ForegroundColor Cyan
Write-Host "Deployment Options" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. GitHub Release" -ForegroundColor Yellow
Write-Host "   - Upload $zipName to GitHub Releases" -ForegroundColor Gray
Write-Host "   - Add changelog and release notes" -ForegroundColor Gray
Write-Host "   - Create tag: v$version" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Direct Distribution" -ForegroundColor Yellow
Write-Host "   - Share the ZIP file directly" -ForegroundColor Gray
Write-Host "   - Users extract and run iptv_casper.exe" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Website Hosting" -ForegroundColor Yellow
Write-Host "   - Upload to your website" -ForegroundColor Gray
Write-Host "   - Provide download link" -ForegroundColor Gray
Write-Host ""
Write-Host "4. Create Installer" -ForegroundColor Yellow
Write-Host "   - Use Inno Setup (https://jrsoftware.org/isinfo.php)" -ForegroundColor Gray
Write-Host "   - Professional installation experience" -ForegroundColor Gray
Write-Host ""

Write-Host "================================" -ForegroundColor Cyan
Write-Host "Next Steps" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host "1. Test on a clean Windows machine" -ForegroundColor White
Write-Host "2. (Optional) Sign the executable for better trust" -ForegroundColor White
Write-Host "3. Choose your distribution method" -ForegroundColor White
Write-Host "4. Upload and share!" -ForegroundColor White
Write-Host ""

# Ask if user wants to open the production folder
$open = Read-Host "Open production folder? (Y/N)"
if ($open -eq "Y" -or $open -eq "y") {
    Invoke-Item "production-release"
}

Write-Host ""
Write-Host "✓ Production package ready!" -ForegroundColor Green
Write-Host "See PRODUCTION_DEPLOYMENT.md for detailed deployment guide" -ForegroundColor Cyan
Write-Host ""
