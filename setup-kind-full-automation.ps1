# ============================================================
#        AUTOMATED KIND KUBERNETES CLUSTER SETUP
#        Windows PowerShell
# ============================================================

Clear-Host

$ErrorActionPreference = "Continue"

# ------------------------------------------------------------
# CONFIGURATION
# ------------------------------------------------------------

$NodeImage = "kindest/node:v1.34.0"


# ============================================================
# HEADER
# ============================================================

Write-Host ""
Write-Host "============================================================"
Write-Host "       KIND KUBERNETES AUTOMATED SETUP"
Write-Host "============================================================"
Write-Host ""


# ============================================================
# FUNCTION: REFRESH PATH
# ============================================================

function Refresh-Path {

    $env:Path = [System.Environment]::GetEnvironmentVariable(
        "Path",
        "Machine"
    ) + ";" +
    [System.Environment]::GetEnvironmentVariable(
        "Path",
        "User"
    )
}


# ============================================================
# FUNCTION: CHECK WINGET
# ============================================================

function Test-Winget {

    if (!(Get-Command winget -ErrorAction SilentlyContinue)) {

        Write-Host ""
        Write-Host "ERROR: WinGet is not available." -ForegroundColor Red
        Write-Host ""
        Write-Host "WinGet is normally included with modern Windows through"
        Write-Host "the App Installer package."
        Write-Host ""
        Write-Host "Please install/update App Installer from Microsoft Store"
        Write-Host "and run this script again."
        Write-Host ""

        exit 1
    }
}


# ============================================================
# FUNCTION: INSTALL PACKAGE
# ============================================================

function Install-PackageIfMissing {

    param (
        [string]$CommandName,
        [string]$PackageId,
        [string]$DisplayName
    )

    if (Get-Command $CommandName -ErrorAction SilentlyContinue) {

        Write-Host "$DisplayName : FOUND" -ForegroundColor Green
        return
    }

    Write-Host "$DisplayName : NOT FOUND" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Installing $DisplayName..."

    winget install `
        --id $PackageId `
        --exact `
        --source winget `
        --accept-source-agreements `
        --accept-package-agreements

    if ($LASTEXITCODE -ne 0) {

        Write-Host ""
        Write-Host "ERROR: Failed to install $DisplayName." `
            -ForegroundColor Red

        exit 1
    }

    Refresh-Path

    if (!(Get-Command $CommandName -ErrorAction SilentlyContinue)) {

        Write-Host ""
        Write-Host "ERROR: $DisplayName was installed but the command"
        Write-Host "is not available in the current PowerShell session."
        Write-Host ""
        Write-Host "Please close PowerShell, open a new PowerShell window,"
        Write-Host "and run this script again."

        exit 1
    }

    Write-Host "$DisplayName installed successfully." `
        -ForegroundColor Green
}


# ============================================================
# STEP 1 - CHECK WINGET
# ============================================================

Write-Host "[1/7] Checking WinGet..."

Test-Winget

Write-Host "WinGet: OK" -ForegroundColor Green


# ============================================================
# STEP 2 - DOCKER DESKTOP
# ============================================================

Write-Host ""
Write-Host "[2/7] Checking Docker Desktop..."

$DockerCommand = Get-Command docker `
    -ErrorAction SilentlyContinue

if (!$DockerCommand) {

    Write-Host "Docker: NOT FOUND" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Installing Docker Desktop..."

    winget install `
        --id Docker.DockerDesktop `
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

    Refresh-Path
}

Write-Host "Docker Desktop: FOUND" -ForegroundColor Green


# ============================================================
# START DOCKER DESKTOP
# ============================================================

Write-Host ""
Write-Host "Checking Docker Engine..."

docker info > $null 2>&1

if ($LASTEXITCODE -ne 0) {

    Write-Host "Docker Engine is not running." -ForegroundColor Yellow
    Write-Host "Starting Docker Desktop..."

    $DockerDesktopPaths = @(
        "$Env:ProgramFiles\Docker\Docker\Docker Desktop.exe",
        "$Env:LOCALAPPDATA\Programs\DockerDesktop\Docker Desktop.exe"
    )

    $DockerStarted = $false

    foreach ($DockerPath in $DockerDesktopPaths) {

        if (Test-Path $DockerPath) {

            Start-Process $DockerPath
            $DockerStarted = $true
            break
        }
    }

    if (!$DockerStarted) {

        Write-Host ""
        Write-Host "ERROR: Docker Desktop executable was not found."
        Write-Host "Please start Docker Desktop manually."
        exit 1
    }

    Write-Host ""
    Write-Host "Waiting for Docker Engine..."

    $DockerReady = $false

    for ($i = 1; $i -le 60; $i++) {

        docker info > $null 2>&1

        if ($LASTEXITCODE -eq 0) {

            $DockerReady = $true
            break
        }

        Write-Host -NoNewline "."
        Start-Sleep -Seconds 2
    }

    Write-Host ""

    if (!$DockerReady) {

        Write-Host ""
        Write-Host "ERROR: Docker Engine did not become ready." `
            -ForegroundColor Red

        Write-Host "Please check Docker Desktop and run the script again."
        exit 1
    }
}

Write-Host "Docker Engine: READY" -ForegroundColor Green


# ============================================================
# STEP 3 - KUBECTL
# ============================================================

Write-Host ""
Write-Host "[3/7] Checking kubectl..."

Install-PackageIfMissing `
    -CommandName "kubectl" `
    -PackageId "Kubernetes.kubectl" `
    -DisplayName "kubectl"

kubectl version --client


# ============================================================
# STEP 4 - KIND
# ============================================================

Write-Host ""
Write-Host "[4/7] Checking Kind CLI..."

Install-PackageIfMissing `
    -CommandName "kind" `
    -PackageId "Kubernetes.kind" `
    -DisplayName "Kind CLI"

kind version


# ============================================================
# STEP 5 - GET USER INPUT
# ============================================================

Write-Host ""
Write-Host "[5/7] Cluster Configuration"

Write-Host ""
Write-Host "------------------------------------------------------------"

$ClusterName = Read-Host "Enter Cluster Name"

$WorkerInput = Read-Host "Enter Worker Node Count"

Write-Host "------------------------------------------------------------"


# ============================================================
# VALIDATE CLUSTER NAME
# ============================================================

if ([string]::IsNullOrWhiteSpace($ClusterName)) {

    Write-Host ""
    Write-Host "ERROR: Cluster name cannot be empty." `
        -ForegroundColor Red

    exit 1
}

$ClusterName = $ClusterName.Trim().ToLower()


# Kind/Kubernetes cluster names should be simple
if ($ClusterName -notmatch '^[a-z0-9][a-z0-9.-]*$') {

    Write-Host ""
    Write-Host "ERROR: Invalid cluster name." -ForegroundColor Red
    Write-Host ""
    Write-Host "Use only:"
    Write-Host "  lowercase letters"
    Write-Host "  numbers"
    Write-Host "  -"
    Write-Host "  ."

    exit 1
}


# ============================================================
# VALIDATE WORKER COUNT
# ============================================================

if ($WorkerInput -notmatch '^\d+$') {

    Write-Host ""
    Write-Host "ERROR: Worker count must be a number." `
        -ForegroundColor Red

    exit 1
}

$WorkerCount = [int]$WorkerInput

if ($WorkerCount -lt 1) {

    Write-Host ""
    Write-Host "ERROR: Worker count must be at least 1." `
        -ForegroundColor Red

    exit 1
}


# ============================================================
# FINAL CONFIGURATION
# ============================================================

$TotalNodes = $WorkerCount + 1

Write-Host ""
Write-Host "============================================================"
Write-Host "              CLUSTER CONFIGURATION"
Write-Host "============================================================"
Write-Host ""
Write-Host "Cluster Name : $ClusterName"
Write-Host "Control Plane: 1"
Write-Host "Worker Nodes : $WorkerCount"
Write-Host "Total Nodes  : $TotalNodes"
Write-Host "Node Image   : $NodeImage"
Write-Host ""


# ============================================================
# CONFIRM
# ============================================================

$Confirm = Read-Host "Create this cluster? (Y/N)"

if ($Confirm -notmatch '^[Yy]$') {

    Write-Host ""
    Write-Host "Cluster creation cancelled."
    exit 0
}


# ============================================================
# CHECK EXISTING CLUSTER
# ============================================================

Write-Host ""
Write-Host "Checking existing Kind clusters..."

$ExistingClusters = kind get clusters 2>$null

if ($ExistingClusters -contains $ClusterName) {

    Write-Host ""
    Write-Host "ERROR: Cluster '$ClusterName' already exists." `
        -ForegroundColor Red

    Write-Host ""
    Write-Host "Existing clusters:"
    kind get clusters

    exit 1
}


# ============================================================
# STEP 6 - GENERATE KIND YAML
# ============================================================

Write-Host ""
Write-Host "[6/7] Generating Kind configuration..."

$KindConfigFile = "$ClusterName.yaml"


$YamlContent = @"
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4

name: $ClusterName

nodes:
  - role: control-plane
    image: $NodeImage
"@


# ------------------------------------------------------------
# ADD WORKERS
# ------------------------------------------------------------

for ($i = 1; $i -le $WorkerCount; $i++) {

    $YamlContent += @"

  - role: worker
    image: $NodeImage
"@
}


# ------------------------------------------------------------
# SAVE YAML
# ------------------------------------------------------------

$YamlContent | Set-Content `
    -Path $KindConfigFile `
    -Encoding UTF8


Write-Host ""
Write-Host "Generated configuration: $KindConfigFile" `
    -ForegroundColor Green


# ============================================================
# DISPLAY YAML
# ============================================================

Write-Host ""
Write-Host "------------------------------------------------------------"
Write-Host "Generated Kind YAML"
Write-Host "------------------------------------------------------------"

Get-Content $KindConfigFile

Write-Host "------------------------------------------------------------"


# ============================================================
# CREATE CLUSTER
# ============================================================

Write-Host ""
Write-Host "Creating Kind cluster..."
Write-Host ""

kind create cluster --config $KindConfigFile

if ($LASTEXITCODE -ne 0) {

    Write-Host ""
    Write-Host "ERROR: Kind cluster creation failed." `
        -ForegroundColor Red

    exit 1
}


# ============================================================
# SWITCH KUBECTL CONTEXT
# ============================================================

Write-Host ""
Write-Host "Switching kubectl context..."

kubectl config use-context "kind-$ClusterName"

if ($LASTEXITCODE -ne 0) {

    Write-Host ""
    Write-Host "ERROR: Failed to switch kubectl context." `
        -ForegroundColor Red

    exit 1
}


# ============================================================
# STEP 7 - VERIFY
# ============================================================

Write-Host ""
Write-Host "[7/7] Verifying cluster..."

Write-Host ""
Write-Host "Current Context:"
kubectl config current-context

Write-Host ""
Write-Host "Kubernetes Nodes:"
kubectl get nodes -o wide


# ============================================================
# NODE COUNT VALIDATION
# ============================================================

$ActualNodes = @(
    kubectl get nodes --no-headers 2>$null
).Count

Write-Host ""

if ($ActualNodes -eq $TotalNodes) {

    Write-Host "Node Count Validation: PASSED" `
        -ForegroundColor Green

    Write-Host "Expected Nodes : $TotalNodes"
    Write-Host "Actual Nodes   : $ActualNodes"

}
else {

    Write-Host "Node Count Validation: FAILED" `
        -ForegroundColor Red

    Write-Host "Expected Nodes : $TotalNodes"
    Write-Host "Actual Nodes   : $ActualNodes"
}


# ============================================================
# COMPLETE
# ============================================================

Write-Host ""
Write-Host "============================================================"
Write-Host "        KIND CLUSTER SETUP COMPLETED"
Write-Host "============================================================"
Write-Host ""
Write-Host "Cluster Name : $ClusterName"
Write-Host "Control Plane: 1"
Write-Host "Worker Nodes : $WorkerCount"
Write-Host "Total Nodes  : $TotalNodes"
Write-Host "Configuration: $KindConfigFile"
Write-Host ""

Write-Host "Kubernetes Nodes:"
kubectl get nodes

Write-Host ""
Write-Host "Cluster is READY! 🚀" -ForegroundColor Green
Write-Host ""