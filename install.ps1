# ==============================================================================
# Mercury General Hospital CTF - Machine 2
# Universal Windows Installer
#
# Run this once to clone the repo, install Node.js dependencies, and start
# the CTF server — all in a single step.
#
# ONE-LINE INSTALL (run this in PowerShell):
#   irm https://raw.githubusercontent.com/at0m-b0mb/Mercury-General-Hospital-v2/main/install.ps1 | iex
#
# Or download and run manually:
#   powershell -ExecutionPolicy Bypass -File install.ps1
# ==============================================================================

$REPO_URL    = "https://github.com/at0m-b0mb/Mercury-General-Hospital-v2.git"
$REPO_BRANCH = "main"
# Use $HOME for cross-platform compatibility (works on Windows, macOS, Linux with pwsh)
$HOME_DIR    = if ($env:USERPROFILE) { $env:USERPROFILE } elseif ($env:HOME) { $env:HOME } else { "~" }
$INSTALL_DIR = Join-Path $HOME_DIR "ctf\machine-2-hospital"
$NODE_URL    = "https://nodejs.org/en/download/"
$GIT_URL     = "https://git-scm.com/download/win"

# --------------------------------------------------------------------------
# Helper functions
# --------------------------------------------------------------------------
function Write-Banner {
    Write-Host ""
    Write-Host " ==============================================================" -ForegroundColor Cyan
    Write-Host "   Mercury General Hospital — CTF Machine 2  |  Installer" -ForegroundColor Cyan
    Write-Host " ==============================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Step([string]$msg) {
    Write-Host "[>>] $msg" -ForegroundColor Yellow
}

function Write-OK([string]$msg) {
    Write-Host "[OK] $msg" -ForegroundColor Green
}

function Write-Err([string]$msg) {
    Write-Host "[ERROR] $msg" -ForegroundColor Red
}

function Write-Info([string]$msg) {
    Write-Host "[INFO] $msg" -ForegroundColor Cyan
}

# --------------------------------------------------------------------------
# 0. Ensure scripts can run in this process (fixes npm.ps1 execution policy block)
# --------------------------------------------------------------------------
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

# --------------------------------------------------------------------------
# 1. Banner
# --------------------------------------------------------------------------
Write-Banner

# --------------------------------------------------------------------------
# 2. Check prerequisites: Node.js
# --------------------------------------------------------------------------
Write-Step "Checking for Node.js..."

$nodeOk = $false
try {
    $nodeVer = & node --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-OK "Node.js found: $nodeVer"
        $nodeOk = $true
    }
} catch {}

if (-not $nodeOk) {
    Write-Err "Node.js is not installed or not in PATH."
    Write-Host ""
    Write-Host "  Please install Node.js (v16 LTS or later) from:" -ForegroundColor Yellow
    Write-Host "  $NODE_URL" -ForegroundColor White
    Write-Host ""
    Write-Host "  After installing Node.js, re-run this script." -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press ENTER to exit"
    exit 1
}

# Refresh PATH from the Windows registry so freshly-installed tools (npm, git, etc.)
# are visible even when this PowerShell session was opened before the install.
$machinePath = [System.Environment]::GetEnvironmentVariable('PATH', [System.EnvironmentVariableTarget]::Machine)
$userPath    = [System.Environment]::GetEnvironmentVariable('PATH', [System.EnvironmentVariableTarget]::User)
$env:PATH    = "$machinePath;$userPath"

# --------------------------------------------------------------------------
# 3. Check prerequisites: npm (bundled with Node.js, but verify)
# --------------------------------------------------------------------------
$npmOk  = $false
$npmVer = $null

# First try: npm.cmd explicitly — avoids PowerShell resolving npm → npm.ps1 which
# is blocked by restrictive execution policies (the most common Windows failure mode).
try {
    $npmVer = & npm.cmd --version 2>&1
    if ($LASTEXITCODE -eq 0) { $npmOk = $true }
} catch {}

# Second try: bare npm (works if execution policy was already permissive)
if (-not $npmOk) {
    try {
        $npmVer = & npm --version 2>&1
        if ($LASTEXITCODE -eq 0) { $npmOk = $true }
    } catch {}
}

# Third try: find npm.cmd next to the node.exe we already located.
# Covers nvm-for-windows and other setups where the node folder isn't fully in PATH.
if (-not $npmOk) {
    $nodeExe = (Get-Command node -ErrorAction SilentlyContinue).Source
    if ($nodeExe) {
        $npmPath = Join-Path (Split-Path $nodeExe) 'npm.cmd'
        if (Test-Path $npmPath) {
            try {
                $npmVer = & $npmPath --version 2>&1
                if ($LASTEXITCODE -eq 0) {
                    $npmOk  = $true
                    $nodeDir = Split-Path $nodeExe
                    if ($env:PATH -notlike "*$nodeDir*") {
                        $env:PATH = "$nodeDir;$env:PATH"
                    }
                }
            } catch {}
        }
    }
}

if ($npmOk) {
    Write-OK "npm found: v$npmVer"
} else {
    Write-Err "npm is not available. Reinstall Node.js from $NODE_URL"
    Read-Host "Press ENTER to exit"
    exit 1
}

# --------------------------------------------------------------------------
# 4. Get the source code
#    Case A: Already running from inside the cloned repo → stay in place
#    Case B: git is available → clone to $INSTALL_DIR
#    Case C: No git → download zip from GitHub
# --------------------------------------------------------------------------
Write-Host ""
Write-Step "Locating source files..."

# Detect if we're already inside the repo (server.js exists next to this script)
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $scriptDir) { $scriptDir = Get-Location }

if (Test-Path (Join-Path $scriptDir "server.js")) {
    Write-OK "Source files detected in current directory."
    $PROJECT_DIR = $scriptDir
}
else {
    # Try git clone
    $gitOk = $false
    try {
        $gitVer = & git --version 2>&1
        if ($LASTEXITCODE -eq 0) { $gitOk = $true }
    } catch {}

    if ($gitOk) {
        if (Test-Path $INSTALL_DIR) {
            Write-Info "Directory already exists: $INSTALL_DIR"
            Write-Step "Updating existing clone with git pull..."
            Set-Location $INSTALL_DIR
            & git pull origin $REPO_BRANCH
        }
        else {
            Write-Step "Cloning repository to $INSTALL_DIR ..."
            & git clone --branch $REPO_BRANCH $REPO_URL $INSTALL_DIR
            if ($LASTEXITCODE -ne 0) {
                Write-Err "git clone failed. Check your internet connection."
                Read-Host "Press ENTER to exit"
                exit 1
            }
            Write-OK "Repository cloned."
        }
        $PROJECT_DIR = $INSTALL_DIR
    }
    else {
        # Fallback: download ZIP from GitHub
        Write-Info "git not found — downloading ZIP archive instead."
        Write-Info "  (Install Git from $GIT_URL for faster future updates)"

        $zipUrl  = "https://github.com/at0m-b0mb/Mercury-General-Hospital-v2/archive/refs/heads/$REPO_BRANCH.zip"
        $zipPath = "$env:TEMP\machine2-ctf.zip"
        $unzipTo = "$env:TEMP\machine2-ctf-extract"

        Write-Step "Downloading ZIP from GitHub..."
        try {
            Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -UseBasicParsing
        } catch {
            Write-Err "Download failed: $_"
            Write-Host "  Please check your internet connection or install Git." -ForegroundColor Yellow
            Read-Host "Press ENTER to exit"
            exit 1
        }

        if (Test-Path $unzipTo) { Remove-Item $unzipTo -Recurse -Force }
        Write-Step "Extracting ZIP..."
        Expand-Archive -LiteralPath $zipPath -DestinationPath $unzipTo -Force

        # GitHub zips extract to a subfolder named <repo>-<branch>
        $extracted = Get-ChildItem $unzipTo -Directory | Select-Object -First 1
        if (-not $extracted) {
            Write-Err "Could not find extracted folder inside ZIP."
            Read-Host "Press ENTER to exit"
            exit 1
        }

        if (Test-Path $INSTALL_DIR) { Remove-Item $INSTALL_DIR -Recurse -Force }
        Move-Item $extracted.FullName $INSTALL_DIR
        Write-OK "Files extracted to $INSTALL_DIR"
        $PROJECT_DIR = $INSTALL_DIR
    }

    Set-Location $PROJECT_DIR
}

# --------------------------------------------------------------------------
# 5. Install npm dependencies
# --------------------------------------------------------------------------
Write-Host ""
Write-Step "Installing Node.js dependencies (npm install)..."
Set-Location $PROJECT_DIR
& npm.cmd install
if ($LASTEXITCODE -ne 0) {
    Write-Err "npm install failed. Check your internet connection and try again."
    Read-Host "Press ENTER to exit"
    exit 1
}
Write-OK "Dependencies installed."

# --------------------------------------------------------------------------
# 6. Copy .env.example → .env (if not already present)
# --------------------------------------------------------------------------
$envFile     = Join-Path $PROJECT_DIR ".env"
$envExample  = Join-Path $PROJECT_DIR ".env.example"
if (-not (Test-Path $envFile) -and (Test-Path $envExample)) {
    Copy-Item $envExample $envFile
    Write-OK ".env created from .env.example"
}

# --------------------------------------------------------------------------
# 7. Choose port
# --------------------------------------------------------------------------
Write-Host ""
$portInput = Read-Host "Enter port to run the server on (press ENTER for default 3000)"
if ([string]::IsNullOrWhiteSpace($portInput)) { $portInput = "3000" }

# Warn if the chosen port is below 1024 (may require elevated privileges)
if ([int]$portInput -lt 1024) {
    Write-Host ""
    Write-Host "  [WARN] Port $portInput is below 1024 and may require admin/root privileges." -ForegroundColor Yellow
    Write-Host "         If the server fails to start, re-run with a port >= 1024 (e.g. 3000 or 8080)." -ForegroundColor Yellow
    Write-Host "         On Windows: run PowerShell as Administrator." -ForegroundColor Yellow
    Write-Host ""
}

# --------------------------------------------------------------------------
# 8. Summary
# --------------------------------------------------------------------------
Write-Host ""
Write-Host " ==============================================================" -ForegroundColor Cyan
Write-Host "  Setup complete!" -ForegroundColor Green
Write-Host " ==============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Info "Project folder : $PROJECT_DIR"
Write-Info "Server port    : $portInput"
Write-Info "URL            : http://localhost:$portInput"
Write-Host ""
Write-Host "  The server will start now." -ForegroundColor Yellow
Write-Host "  Open your browser to: http://localhost:$portInput" -ForegroundColor Cyan
Write-Host "  Press Ctrl+C to stop the server at any time." -ForegroundColor Yellow
Write-Host ""

# --------------------------------------------------------------------------
# 9. Start the server
# --------------------------------------------------------------------------
$env:PORT = $portInput
Set-Location $PROJECT_DIR
node server.js
