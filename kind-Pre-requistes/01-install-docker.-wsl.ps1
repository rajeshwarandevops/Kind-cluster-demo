# ============================================================
# 01-install-docker.ps1
#
# Docker Desktop + WSL 2 Prerequisite Installation
#
# Automatically:
#   1. Checks Windows version
#   2. Checks Administrator privileges
#   3. Checks hardware virtualization
#   4. Checks WSL 2
#   5. Installs / enables WSL 2 if required
#   6. Installs Docker Desktop
#   7. Starts and verifies Docker Engine
# ============================================================

Clear-Host

$ErrorActionPreference = "Continue"

# ============================================================
# CONFIGURATION
# ============================================================

$DockerPackage = "Docker.DockerDesktop"


# ============================================================
# HEADER
# ============================================================

Write-Host ""
Write-Host "============================================================"
Write-Host "       DOCKER DESKTOP + WSL 2 INSTALLATION"
Write-Host "============================================================"
Write-Host ""


# ============================================================
# STEP 1 - CHECK WINDOWS VERSION
# ============================================================

Write-Host "[1/7] Checking Windows version..."

$OS = Get-CimInstance Win32_OperatingSystem

$WindowsCaption = $OS.Caption
$BuildNumber = [int]$OS.BuildNumber

Write-Host ""
Write-Host "Windows Version : $WindowsCaption"
Write-Host "Build Number    : $BuildNumber"

if ($WindowsCaption -match "Windows 10|Windows 11") {

    Write-Host ""
    Write-Host "Windows version: SUPPORTED" `
        -ForegroundColor Green

}
else {

    Write-Host ""
    Write-Host "ERROR: Unsupported Windows version." `
        -ForegroundColor Red

    exit 1
}


# ============================================================
# STEP 2 - CHECK ADMINISTRATOR
# ============================================================

Write-Host ""
Write-Host "[2/7] Checking Administrator privileges..."

$CurrentUser = [Security.Principal.WindowsIdentity]::GetCurrent()

$Principal = New-Object `
    Security.Principal.WindowsPrincipal($CurrentUser)

$IsAdmin = $Principal.IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)

if ($IsAdmin) {

    Write-Host ""
    Write-Host "Administrator: YES" `
        -ForegroundColor Green

}
else {

    Write-Host ""
    Write-Host "ERROR: Administrator privileges are required." `
        -ForegroundColor Red

    Write-Host ""
    Write-Host "Please right-click PowerShell and select:"
    Write-Host "Run as Administrator"

    exit 1
}


# ============================================================
# STEP 3 - CHECK HARDWARE VIRTUALIZATION
# ============================================================

Write-Host ""
Write-Host "[3/7] Checking hardware virtualization..."

$CPU = Get-CimInstance Win32_Processor

$VirtualizationEnabled =
    $CPU.VirtualizationFirmwareEnabled

if ($VirtualizationEnabled -eq $true) {

    Write-Host ""
    Write-Host "Hardware Virtualization: ENABLED" `
        -ForegroundColor Green

}
else {

    Write-Host ""
    Write-Host "Hardware Virtualization: NOT CONFIRMED" `
        -ForegroundColor Yellow

    Write-Host ""
    Write-Host "Continuing with WSL 2 verification..."
}


# ============================================================
# STEP 4 - CHECK WSL
# ============================================================

Write-Host ""
Write-Host "[4/7] Checking WSL 2..."

$WSLInstalled = $false

if (Get-Command wsl.exe -ErrorAction SilentlyContinue) {

    Write-Host ""
    Write-Host "WSL command: FOUND" `
        -ForegroundColor Green

    # --------------------------------------------------------
    # Check WSL version information
    # --------------------------------------------------------

    $WSLVersionOutput = wsl.exe --version 2>&1

    if ($LASTEXITCODE -eq 0) {

        $WSLInstalled = $true

        Write-Host ""
        Write-Host "WSL 2: AVAILABLE" `
            -ForegroundColor Green

        Write-Host ""
        Write-Host "WSL Version Information:"
        Write-Host $WSLVersionOutput

    }
    else {

        Write-Host ""
        Write-Host "WSL is installed but WSL 2 could not be confirmed." `
            -ForegroundColor Yellow
    }

}
else {

    Write-Host ""
    Write-Host "WSL: NOT INSTALLED" `
        -ForegroundColor Yellow
}


# ============================================================
# STEP 5 - INSTALL / ENABLE WSL 2
# ============================================================

Write-Host ""
Write-Host "[5/7] Installing / configuring WSL 2..."

if (!$WSLInstalled) {

    Write-Host ""
    Write-Host "Installing WSL 2..."
    Write-Host ""

    wsl.exe --install --no-distribution

    if ($LASTEXITCODE -ne 0) {

        Write-Host ""
        Write-Host "WARNING: WSL installation command returned an error." `
            -ForegroundColor Yellow

        Write-Host ""
        Write-Host "Attempting to enable required Windows features..."
    }

    # --------------------------------------------------------
    # Enable Virtual Machine Platform
    # --------------------------------------------------------

    Write-Host ""
    Write-Host "Enabling Virtual Machine Platform..."

    dism.exe /online /enable-feature `
        /featurename:VirtualMachinePlatform `
        /all `
        /norestart

    # --------------------------------------------------------
    # Enable Windows Subsystem for Linux
    # --------------------------------------------------------

    Write-Host ""
    Write-Host "Enabling Windows Subsystem for Linux..."

    dism.exe /online /enable-feature `
        /featurename:Microsoft-Windows-Subsystem-Linux `
        /all `
        /norestart

    # --------------------------------------------------------
    # Set WSL 2 as default
    # --------------------------------------------------------

    Write-Host ""
    Write-Host "Setting WSL 2 as default..."

    wsl.exe --set-default-version 2

}
else {

    Write-Host ""
    Write-Host "WSL 2 is already available." `
        -ForegroundColor Green
}


# ============================================================
# VERIFY WSL
# ============================================================

Write-Host ""
Write-Host "Verifying WSL..."

wsl.exe --status

Write-Host ""
Write-Host "WSL configuration check completed."


# ============================================================
# STEP 6 - INSTALL DOCKER DESKTOP
# ============================================================

Write-Host ""
Write-Host "[6/7] Checking Docker Desktop..."

# ------------------------------------------------------------
# Check Docker command
# ------------------------------------------------------------

$DockerInstalled = $false

if (Get-Command docker.exe -ErrorAction SilentlyContinue) {

    $DockerInstalled = $true

    Write-Host ""
    Write-Host "Docker CLI: FOUND" `
        -ForegroundColor Green
}

# ------------------------------------------------------------
# Check Docker Desktop installation path
# ------------------------------------------------------------

$DockerDesktopPath = "$Env:ProgramFiles\Docker\Docker\Docker Desktop.exe"

if (Test-Path $DockerDesktopPath) {

    $DockerInstalled = $true

    Write-Host ""
    Write-Host "Docker Desktop: INSTALLED" `
        -ForegroundColor Green
}


# ------------------------------------------------------------
# Install Docker Desktop if missing
# ------------------------------------------------------------

if (!$DockerInstalled) {

    Write-Host ""
    Write-Host "Docker Desktop: NOT FOUND" `
        -ForegroundColor Yellow

    Write-Host ""
    Write-Host "Installing Docker Desktop using WinGet..."
    Write-Host ""

    if (!(Get-Command winget.exe -ErrorAction SilentlyContinue)) {

        Write-Host ""
        Write-Host "ERROR: WinGet is not available." `
            -ForegroundColor Red

        Write-Host ""
        Write-Host "Please install Microsoft App Installer."
        exit 1
    }

    winget install `
        --id $DockerPackage `
        --exact `
        --source winget `
        --accept-source-agreements `
        --accept-package-agreements

    if ($LASTEXITCODE -ne 0) {

        Write-Host ""
        Write-Host "ERROR: Docker Desktop installation failed." `
            -ForegroundColor Red

        exit 1
    }

    Write-Host ""
    Write-Host "Docker Desktop installation completed." `
        -ForegroundColor Green
}
else {

    Write-Host ""
    Write-Host "Docker Desktop already installed." `
        -ForegroundColor Green
}


# ============================================================
# REFRESH PATH
# ============================================================

Write-Host ""
Write-Host "Refreshing PATH..."

$env:Path =
    [System.Environment]::GetEnvironmentVariable(
        "Path",
        "Machine"
    ) +
    ";" +
    [System.Environment]::GetEnvironmentVariable(
        "Path",
        "User"
    )

Write-Host "PATH refreshed." -ForegroundColor Green


# ============================================================
# STEP 7 - START DOCKER DESKTOP
# ============================================================

Write-Host ""
Write-Host "[7/7] Starting Docker Desktop..."

$DockerDesktopPath =
    "$Env:ProgramFiles\Docker\Docker\Docker Desktop.exe"

if (Test-Path $DockerDesktopPath) {

    Start-Process `
        -FilePath $DockerDesktopPath `
        -ErrorAction SilentlyContinue

    Write-Host ""
    Write-Host "Docker Desktop start command sent." `
        -ForegroundColor Green

}
else {

    Write-Host ""
    Write-Host "WARNING: Docker Desktop executable not found." `
        -ForegroundColor Yellow
}


# ============================================================
# WAIT FOR DOCKER ENGINE
# ============================================================

Write-Host ""
Write-Host "Waiting for Docker Engine..."
Write-Host ""

$DockerReady = $false

for ($i = 1; $i -le 30; $i++) {

    Start-Sleep -Seconds 5

    Write-Host "Checking Docker Engine... ($i/30)"

    $DockerTest = docker info 2>&1

    if ($LASTEXITCODE -eq 0) {

        $DockerReady = $true

        break
    }
}


# ============================================================
# VERIFY DOCKER
# ============================================================

Write-Host ""

if ($DockerReady) {

    Write-Host "============================================================"
    Write-Host "              DOCKER ENGINE: READY"
    Write-Host "============================================================"
    Write-Host ""

    Write-Host "Docker Version:"
    docker version

    Write-Host ""

    Write-Host "Docker Info:"
    docker info

}
else {

    Write-Host "============================================================"
    Write-Host "          DOCKER ENGINE: NOT READY"
    Write-Host "============================================================"
    Write-Host ""

    Write-Host "Docker Desktop may still be starting."
    Write-Host ""
    Write-Host "Please wait a few seconds and run:"
    Write-Host ""
    Write-Host "    docker info"
    Write-Host ""

    Write-Host "If Docker does not respond, restart Docker Desktop."

    exit 1
}


# ============================================================
# FINAL VALIDATION
# ============================================================

Write-Host ""
Write-Host "============================================================"
Write-Host "        DOCKER DESKTOP SETUP COMPLETED"
Write-Host "============================================================"
Write-Host ""

Write-Host "Windows        : READY" -ForegroundColor Green
Write-Host "WSL 2          : READY" -ForegroundColor Green
Write-Host "Docker Desktop : READY" -ForegroundColor Green
Write-Host "Docker Engine  : READY" -ForegroundColor Green

Write-Host ""

Write-Host "Next step:"
Write-Host ""
Write-Host "    .\02-install-kubectl.ps1"
Write-Host ""

Write-Host "============================================================"
Write-Host ""