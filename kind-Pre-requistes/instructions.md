# KIND Kubernetes – Full Automation Instructions

## 1. Setup Folder

Create the following folder:

    C:\kind\kind-Pre-requistes

Copy all required PowerShell scripts into this folder.

The folder should contain:

    C:\kind\kind-Pre-requistes
    │
    ├── 01-install-docker-wsl.ps1
    ├── 02-install-kubectl.ps1
    ├── 03-install-kind.ps1
    ├── 04-create-kind-cluster.ps1
    └── instruction.md


# 2. Open PowerShell as Administrator

1. Open the Windows Start menu.
2. Search for:

       PowerShell

3. Right-click PowerShell.
4. Select:

       Run as administrator

5. Select **Yes** when Windows asks for permission.


# 3. Go to the Setup Folder

Run:

    cd C:\kind\kind-Pre-requistes

Verify the files:

    dir


# 4. Allow PowerShell Scripts

Run:

    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

This allows the scripts to run only in the current PowerShell
session.

No permanent execution-policy change is made.


# 5. Install Docker Desktop + WSL 2

Run:

    .\01-install-docker-wsl.ps1


## Docker Installation Flow

The script performs the following steps:

    01-install-docker-wsl.ps1
            │
            ▼
    Check Windows
            │
            ▼
    Check Admin
            │
            ▼
    Check BIOS Virtualization
            │
            ▼
    Check WSL
            │
            ├── WSL OK ──────────────────┐
            │                             │
            └── WSL Missing               │
                    │                     │
                    ▼                     │
            Install / Enable WSL 2        │
                    │                     │
                    ▼                     │
                 REBOOT                  │
                    │                     │
                    ▼                     │
             Run script again            │
                    │                     │
                    └──────────┬──────────┘
                               ▼
                     Install Docker Desktop
                               │
                               ▼
                      Start Docker Desktop
                               │
                               ▼
                     Wait for Docker Engine
                               │
                               ▼
                           READY ✅


# 6. Important – WSL Reboot

If the script installs or enables WSL 2, Windows may require a
restart.

When prompted, restart the computer.

After Windows starts:

1. Open PowerShell as Administrator again.
2. Go to:

       cd C:\kind\kind-Pre-requistes

3. Run:

       Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

4. Run the Docker script again:

       .\01-install-docker-wsl.ps1

The script will check the existing installation and continue.


# 7. Verify Docker

After the Docker script completes successfully, verify Docker:

    docker version

Then:

    docker info

Docker Engine must be running before continuing.


# 8. Install kubectl

Run:

    .\02-install-kubectl.ps1

The script installs kubectl if it is not already installed.


## Verify kubectl

Run:

    kubectl version --client


# 9. Install Kind

Run:

    .\03-install-kind.ps1

The script installs the Kind CLI if it is not already installed.


## Verify Kind

Run:

    kind version


# 10. Create Kind Kubernetes Cluster

Run:

    .\04-create-kind-cluster.ps1

The script will prompt for:

    Cluster Name
    Worker Node Count


## Example

Enter:

    Cluster Name: dfu

    Worker Node Count: 2


The script automatically creates:

    Control Plane: 1
    Worker Nodes : 2
    Total Nodes  : 3


# 11. Kind Cluster Configuration

The cluster configuration YAML is generated automatically by:

    04-create-kind-cluster.ps1

For example:

    dfu.yaml


The generated configuration will contain:

    kind: Cluster
    apiVersion: kind.x-k8s.io/v1alpha4

    name: dfu

    nodes:
      - role: control-plane
        image: kindest/node:v1.34.0

      - role: worker
        image: kindest/node:v1.34.0

      - role: worker
        image: kindest/node:v1.34.0


# 12. Verify Kind Cluster

Check the Kind cluster:

    kind get clusters


Example:

    dfu


Check the Kubernetes context:

    kubectl config current-context


Expected:

    kind-dfu


Check Kubernetes nodes:

    kubectl get nodes


Expected:

    NAME                    STATUS   ROLES
    dfu-control-plane       Ready    control-plane
    dfu-worker              Ready    <none>
    dfu-worker2             Ready    <none>


All nodes should show:

    Ready


# 13. Complete Installation Flow

The complete setup is:

    C:\kind\kind-Pre-requistes
            │
            ▼
    Run PowerShell as Administrator
            │
            ▼
    Set Execution Policy
            │
            ▼
    01-install-docker-wsl.ps1
            │
            ├── Windows
            ├── Admin
            ├── BIOS Virtualization
            ├── WSL 2
            ├── Docker Desktop
            └── Docker Engine
                    │
                    ▼
            Docker READY ✅
                    │
                    ▼
    02-install-kubectl.ps1
                    │
                    ▼
            kubectl READY ✅
                    │
                    ▼
    03-install-kind.ps1
                    │
                    ▼
              Kind READY ✅
                    │
                    ▼
    04-create-kind-cluster.ps1
                    │
                    ▼
            Ask Cluster Name
                    │
                    ▼
            Ask Worker Count
                    │
                    ▼
          Generate Kind YAML
                    │
                    ▼
            Create Cluster
                    │
                    ▼
          Verify Kubernetes Nodes
                    │
                    ▼
                READY 🚀


# 14. Quick Installation Commands

Open PowerShell as Administrator.

Run:

    cd C:\kind\kind-Pre-requistes

Then:

    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

Install Docker + WSL:

    .\01-install-docker-wsl.ps1

If Windows asks for a reboot, restart and run the Docker script again.

Then install kubectl:

    .\02-install-kubectl.ps1

Then install Kind:

    .\03-install-kind.ps1

Finally create the Kubernetes cluster:

    .\04-create-kind-cluster.ps1


# 15. Final Verification

Run:

    docker info

    kubectl version --client

    kind version

    kind get clusters

    kubectl config current-context

    kubectl get nodes


The setup is complete when:

- Docker Engine is running
- kubectl is available
- Kind is available
- The Kind cluster exists
- All Kubernetes nodes show `Ready`

# KIND Kubernetes Setup – READY 🚀