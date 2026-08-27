# ============================================================
# 04-create-kind-cluster.ps1
#
# Dynamic Kind Cluster Creation
#
# User provides:
#   - Cluster Name
#   - Worker Node Count
#
# Automatically:
#   - Checks Docker
#   - Checks kubectl
#   - Checks Kind
#   - Generates Kind YAML
#   - Creates cluster
#   - Switches kubectl context
#   - Verifies nodes
# ============================================================

Clear-Host

# CHANGED: Continue so Docker warnings do not stop the script
$ErrorActionPreference = "Continue"

# ============================================================
# CONFIGURATION
# ============================================================

$NodeImage = "kindest/node:v1.34.0"


# ============================================================
# HEADER
# ============================================================

Write-Host ""
Write-Host "============================================================"
Write-Host "          KIND KUBERNETES CLUSTER CREATION"
Write-Host "============================================================"
Write-Host ""


# ============================================================
# STEP 1 - CHECK DOCKER
# ============================================================

Write-Host "[1/7] Checking Docker..."

if (!(Get-Command docker.exe -ErrorAction SilentlyContinue)) {

    Write-Host ""
    Write-Host "ERROR: Docker is not installed." -ForegroundColor Red
    Write-Host ""
    Write-Host "Please run:"
    Write-Host "    .\01-install-docker.ps1"
    exit 1
}

# CHANGED: Capture Docker output instead of redirecting to $null
$DockerInfo = docker info 2>&1

if ($LASTEXITCODE -ne 0) {

    Write-Host ""
    Write-Host "ERROR: Docker Desktop / Docker Engine is not running." `
        -ForegroundColor Red

    Write-Host ""
    Write-Host "Please start Docker Desktop and try again."
    Write-Host ""

    exit 1
}

Write-Host "Docker Engine: READY" -ForegroundColor Green


# ============================================================
# STEP 2 - CHECK KUBECTL
# ============================================================

Write-Host ""
Write-Host "[2/7] Checking kubectl..."

if (!(Get-Command kubectl.exe -ErrorAction SilentlyContinue)) {

    Write-Host ""
    Write-Host "ERROR: kubectl is not installed." -ForegroundColor Red
    Write-Host ""
    Write-Host "Please run:"
    Write-Host "    .\02-install-kubectl.ps1"
    exit 1
}

Write-Host "kubectl: READY" -ForegroundColor Green


# ============================================================
# STEP 3 - CHECK KIND
# ============================================================

Write-Host ""
Write-Host "[3/7] Checking Kind..."

if (!(Get-Command kind.exe -ErrorAction SilentlyContinue)) {

    Write-Host ""
    Write-Host "ERROR: Kind CLI is not installed." `
        -ForegroundColor Red

    Write-Host ""
    Write-Host "Please run:"
    Write-Host "    .\03-install-kind.ps1"
    exit 1
}

Write-Host "Kind CLI: READY" -ForegroundColor Green


# ============================================================
# STEP 4 - GET CLUSTER NAME
# ============================================================

Write-Host ""
Write-Host "[4/7] Cluster Configuration"
Write-Host ""
Write-Host "------------------------------------------------------------"

do {

    $ClusterName = Read-Host "Enter Cluster Name"

    if ([string]::IsNullOrWhiteSpace($ClusterName)) {

        Write-Host ""
        Write-Host "ERROR: Cluster name cannot be empty." `
            -ForegroundColor Red
        Write-Host ""

    }

} while ([string]::IsNullOrWhiteSpace($ClusterName))


$ClusterName = $ClusterName.Trim().ToLower()


# ============================================================
# VALIDATE CLUSTER NAME
# ============================================================

if ($ClusterName -notmatch '^[a-z0-9][a-z0-9.-]*$') {

    Write-Host ""
    Write-Host "ERROR: Invalid cluster name." -ForegroundColor Red
    Write-Host ""
    Write-Host "Use only lowercase letters, numbers, '-' or '.'."
    exit 1
}


# ============================================================
# STEP 5 - GET WORKER COUNT
# ============================================================

do {

    Write-Host ""

    $WorkerInput = Read-Host "Enter Worker Node Count"

    if ($WorkerInput -notmatch '^\d+$') {

        Write-Host ""
        Write-Host "ERROR: Worker count must be a number." `
            -ForegroundColor Red

        $ValidWorkerCount = $false
        continue
    }

    $WorkerCount = [int]$WorkerInput

    if ($WorkerCount -lt 1) {

        Write-Host ""
        Write-Host "ERROR: Worker count must be at least 1." `
            -ForegroundColor Red

        $ValidWorkerCount = $false
    }
    else {

        $ValidWorkerCount = $true
    }

} while (!$ValidWorkerCount)


# ============================================================
# CALCULATE TOTAL NODES
# ============================================================

$ControlPlaneCount = 1
$TotalNodes = $ControlPlaneCount + $WorkerCount


# ============================================================
# DISPLAY FINAL CONFIGURATION
# ============================================================

Write-Host ""
Write-Host "============================================================"
Write-Host "              CLUSTER CONFIGURATION"
Write-Host "============================================================"
Write-Host ""
Write-Host "Cluster Name : $ClusterName"
Write-Host "Control Plane: $ControlPlaneCount"
Write-Host "Worker Nodes : $WorkerCount"
Write-Host "Total Nodes  : $TotalNodes"
Write-Host "Node Image   : $NodeImage"
Write-Host ""
Write-Host "============================================================"
Write-Host ""


# ============================================================
# CONFIRM
# ============================================================

$Confirmation = Read-Host "Create this cluster? (Y/N)"

if ($Confirmation -notmatch '^[Yy]$') {

    Write-Host ""
    Write-Host "Cluster creation cancelled." -ForegroundColor Yellow
    exit 0
}


# ============================================================
# CHECK EXISTING CLUSTER
# ============================================================

Write-Host ""
Write-Host "[5/7] Checking existing Kind clusters..."

$ExistingClusters = @(kind get clusters 2>$null)

if ($ExistingClusters -contains $ClusterName) {

    Write-Host ""
    Write-Host "ERROR: Cluster '$ClusterName' already exists." `
        -ForegroundColor Red

    Write-Host ""
    Write-Host "Existing Kind clusters:"
    kind get clusters

    Write-Host ""
    Write-Host "Choose another cluster name."
    exit 1
}

Write-Host "Cluster name is available." -ForegroundColor Green


# ============================================================
# STEP 6 - GENERATE KIND YAML
# ============================================================

Write-Host ""
Write-Host "[6/7] Generating Kind configuration..."

$KindConfigFile = Join-Path `
    (Get-Location) `
    "$ClusterName.yaml"


# ------------------------------------------------------------
# START YAML
# ------------------------------------------------------------

$YamlContent = @"
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4

name: $ClusterName

nodes:
  - role: control-plane
    image: $NodeImage
"@


# ------------------------------------------------------------
# ADD WORKER NODES DYNAMICALLY
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
Write-Host "Configuration generated:" `
    -ForegroundColor Green

Write-Host $KindConfigFile


# ============================================================
# SHOW GENERATED YAML
# ============================================================

Write-Host ""
Write-Host "------------------------------------------------------------"
Write-Host "Generated Kind YAML"
Write-Host "------------------------------------------------------------"

Get-Content $KindConfigFile

Write-Host "------------------------------------------------------------"


# ============================================================
# CREATE KIND CLUSTER
# ============================================================

Write-Host ""
Write-Host "Creating Kind cluster..."
Write-Host ""

kind create cluster `
    --config $KindConfigFile

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
# STEP 7 - VERIFY CLUSTER
# ============================================================

Write-Host ""
Write-Host "[7/7] Verifying Kubernetes cluster..."

Write-Host ""
Write-Host "Current Context:"
kubectl config current-context

Write-Host ""
Write-Host "Kubernetes Nodes:"
kubectl get nodes -o wide


# ============================================================
# COUNT NODES
# ============================================================

$NodeLines = @(kubectl get nodes --no-headers)

$ActualNodes = $NodeLines.Count


# ============================================================
# VALIDATE NODE COUNT
# ============================================================

Write-Host ""

if ($ActualNodes -eq $TotalNodes) {

    Write-Host "============================================================"
    Write-Host "             NODE COUNT VALIDATION PASSED"
    Write-Host "============================================================"
    Write-Host ""

    Write-Host "Expected Nodes : $TotalNodes"
    Write-Host "Actual Nodes   : $ActualNodes"

}
else {

    Write-Host "============================================================"
    Write-Host "             NODE COUNT VALIDATION FAILED"
    Write-Host "============================================================"
    Write-Host ""

    Write-Host "Expected Nodes : $TotalNodes"
    Write-Host "Actual Nodes   : $ActualNodes" `
        -ForegroundColor Red
}


# ============================================================
# FINAL SUMMARY
# ============================================================

Write-Host ""
Write-Host "============================================================"
Write-Host "          KIND CLUSTER SETUP COMPLETED"
Write-Host "============================================================"
Write-Host ""

Write-Host "Cluster Name : $ClusterName"
Write-Host "Control Plane: $ControlPlaneCount"
Write-Host "Worker Nodes : $WorkerCount"
Write-Host "Total Nodes  : $TotalNodes"
Write-Host "Configuration: $KindConfigFile"

Write-Host ""

Write-Host "Kubectl Context:"
kubectl config current-context

Write-Host ""

Write-Host "Kubernetes Nodes:"
kubectl get nodes

Write-Host ""
Write-Host "Cluster is READY! 🚀" -ForegroundColor Green
Write-Host ""