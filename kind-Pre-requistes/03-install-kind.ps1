# ============================================================
# 03-install-kind.ps1
#
# Kubernetes Kind CLI Installation
# ============================================================

Clear-Host

$ErrorActionPreference = "Continue"

Write-Host ""
Write-Host "============================================================"
Write-Host "                  KIND INSTALLATION"
Write-Host "============================================================"
Write-Host ""


# ============================================================
# CHECK WINGET
# ============================================================

Write-Host "[1/4] Checking WinGet..."

if (!(Get-Command winget.exe -ErrorAction SilentlyContinue)) {

    Write-Host ""
    Write-Host "ERROR: WinGet is not available." `
        -ForegroundColor Red

    Write-Host ""
    Write-Host "Please install/update App Installer from Microsoft Store."
    Write-Host ""

    exit 1
}

Write-Host "WinGet: READY" -ForegroundColor Green


# ============================================================
# CHECK KIND
# ============================================================

Write-Host ""
Write-Host "[2/4] Checking Kind CLI..."

if (Get-Command kind.exe -ErrorAction SilentlyContinue) {

    Write-Host "Kind CLI is already installed." `
        -ForegroundColor Green

}
else {

    Write-Host "Kind CLI: NOT FOUND" `
        -ForegroundColor Yellow

    Write-Host ""
    Write-Host "Installing Kind CLI..."
    Write-Host ""

    winget install `
        --id Kubernetes.kind `
        --exact `
        --source winget `
        --accept-source-agreements `
        --accept-package-agreements

    if ($LASTEXITCODE -ne 0) {

        Write-Host ""
        Write-Host "ERROR: Kind installation failed." `
            -ForegroundColor Red

        exit 1
    }

    Write-Host ""
    Write-Host "Kind installation completed." `
        -ForegroundColor Green
}


# ============================================================
# REFRESH PATH
# ============================================================

Write-Host ""
Write-Host "[3/4] Refreshing PATH..."

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
# VERIFY
# ============================================================

Write-Host ""
Write-Host "[4/4] Verifying Kind..."

if (!(Get-Command kind.exe -ErrorAction SilentlyContinue)) {

    Write-Host ""
    Write-Host "ERROR: Kind was installed but is not available"
    Write-Host "in the current PowerShell session."
    Write-Host ""
    Write-Host "Please close PowerShell, open a new PowerShell window,"
    Write-Host "and run this script again."

    exit 1
}

kind version

if ($LASTEXITCODE -ne 0) {

    Write-Host ""
    Write-Host "ERROR: Kind verification failed." `
        -ForegroundColor Red

    exit 1
}


# ============================================================
# COMPLETE
# ============================================================

Write-Host ""
Write-Host "============================================================"
Write-Host "             KIND INSTALLATION COMPLETED"
Write-Host "============================================================"
Write-Host ""

Write-Host "Kind CLI: READY" -ForegroundColor Green

Write-Host ""
Write-Host "Next step:"
Write-Host ""
Write-Host "    04-create-kind-cluster.ps1"
Write-Host ""

Write-Host "============================================================"
Write-Host ""