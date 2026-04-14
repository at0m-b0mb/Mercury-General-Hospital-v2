# ============================================================
# Mercury General Hospital CTF - Windows PowerShell Setup
# Run with: powershell -ExecutionPolicy Bypass -File setup.ps1
# Or right-click setup.ps1 → "Run with PowerShell"
# ============================================================

Write-Host ""
Write-Host " =====================================================" -ForegroundColor Cyan
Write-Host "  Mercury General Hospital - CTF Machine 2 Setup" -ForegroundColor Cyan
Write-Host " =====================================================" -ForegroundColor Cyan
Write-Host ""

# Check for Node.js
try {
    $nodeVersion = node --version 2>&1
    Write-Host "[OK] Node.js found: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Node.js is not installed." -ForegroundColor Red
    Write-Host "        Download from: https://nodejs.org/" -ForegroundColor Yellow
    Read-Host "Press ENTER to exit"
    exit 1
}

Write-Host ""

# Install npm dependencies
Write-Host "[INFO] Installing npm dependencies..." -ForegroundColor Yellow
npm install
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] npm install failed." -ForegroundColor Red
    Read-Host "Press ENTER to exit"
    exit 1
}
Write-Host "[OK] Dependencies installed." -ForegroundColor Green
Write-Host ""

# Choose port
$portInput = Read-Host "Enter port to listen on (press ENTER for default 80)"
if ([string]::IsNullOrEmpty($portInput)) {
    $portInput = "80"
}

Write-Host ""
Write-Host "[INFO] Starting server on port $portInput..." -ForegroundColor Yellow
Write-Host "[INFO] Open your browser to: http://localhost:$portInput" -ForegroundColor Cyan
Write-Host "[INFO] Press Ctrl+C to stop the server." -ForegroundColor Yellow
Write-Host ""

$env:PORT = $portInput
node server.js
