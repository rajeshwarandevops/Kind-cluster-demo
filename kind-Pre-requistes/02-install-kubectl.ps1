# ============================================================
# 02-install-kubectl.ps1
#
# Kubernetes kubectl Installation
# ============================================================

Clear-Host

$ErrorActionPreference = "Continue"

Write-Host ""
Write-Host "============================================================"
Write-Host "                 KUBECTL INSTALLATION"
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
# CHECK KUBECTL
# ============================================================

Write-Host ""
Write-Host "[2/4] Checking kubectl..."

if (Get-Command kubectl.exe -ErrorAction SilentlyContinue) {

    Write-Host "kubectl is already installed." `
        -ForegroundColor Green

}
else {

    Write-Host "kubectl: NOT FOUND" `
        -ForegroundColor Yellow

    Write-Host ""
    Write-Host "Installing kubectl..."
    Write-Host ""

    winget install `
        --id Kubernetes.kubectl `
        --exact `
        --source winget `
        --accept-source-agreements `
        --accept-package-agreements

    if ($LASTEXITCODE -ne 0) {

        Write-Host ""
        Write-Host "ERROR: kubectl installation failed." `
            -ForegroundColor Red

        exit 1
    }

    Write-Host ""
    Write-Host "kubectl installation completed." `
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
Write-Host "[4/4] Verifying kubectl..."

if (!(Get-Command kubectl.exe -ErrorAction SilentlyContinue)) {

    Write-Host ""
    Write-Host "ERROR: kubectl was installed but is not available"
    Write-Host "in the current PowerShell session."
    Write-Host ""
    Write-Host "Please close PowerShell, open a new PowerShell window,"
    Write-Host "and run this script again."

    exit 1
}

kubectl version --client

if ($LASTEXITCODE -ne 0) {

    Write-Host ""
    Write-Host "ERROR: kubectl verification failed." `
        -ForegroundColor Red

    exit 1
}


# ============================================================
# COMPLETE
# ============================================================

Write-Host ""
Write-Host "============================================================"
Write-Host "           KUBECTL INSTALLATION COMPLETED"
Write-Host "============================================================"
Write-Host ""

Write-Host "kubectl: READY" -ForegroundColor Green

Write-Host ""
Write-Host "Next step:"
Write-Host ""
Write-Host "    03-install-kind.ps1"
Write-Host ""

Write-Host "============================================================"
Write-Host ""