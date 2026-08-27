\# KIND Kubernetes – Deployment 



Pre-Perquisites



\- WSL 2

\- Docker Desktop

\- kubectl

\- Kind CLI

\- Kind Kubernetes cluster



\---



\# Step 1 – Create the C:\\kind Folder



Open File Explorer.



Go to:



&#x20;   C:\\



Create a new folder named:



&#x20;   kind



The final folder should be:



&#x20;   C:\\kind



\---



\# Step 2 – Copy the Setup Files



Copy the following files into:



&#x20;   C:\\kind



Required files:



&#x20;   setup-kind-full-automation.ps1

&#x20;   Kind-overview.yaml



Your folder should look like:



&#x20;   C:\\kind

&#x20;   │

&#x20;   ├── setup-kind-full-automation.ps1

&#x20;   └── Kind-overview.yaml



\---



\# Step 3 – Open PowerShell as Administrator



1\. Click the Windows Start button.

2\. Search for:



&#x20;      PowerShell



3\. Right-click \*\*Windows PowerShell\*\*.

4\. Select:



&#x20;      Run as administrator



5\. If Windows displays User Account Control (UAC), select:



&#x20;      Yes



You should now have an Administrator PowerShell window.



\---



\# Step 4 – Go to the C:\\kind Folder



Run:



&#x20;   cd C:\\kind



Verify the files:



&#x20;   dir



You should see:



&#x20;   setup-kind-full-automation.ps1

&#x20;   Kind-overview.yaml



\---



\# Step 5 – Allow PowerShell Scripts



Windows PowerShell may prevent scripts from running.



Run:



&#x20;   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser



When prompted:



&#x20;   Execution Policy Change



Enter:



&#x20;   Y



and press Enter.



This allows locally created scripts to run while downloaded scripts

must generally be signed.



\---



\# Step 6 – Run the Automation



Run:



&#x20;   .\\setup-kind-full-automation.ps1



The setup script will start the automated installation.



\---



\# Step 7 – Follow the On-Screen Prompts



The script may ask for values such as:



&#x20;   Cluster Name

&#x20;   Worker Node Count



For example:



&#x20;   Cluster Name : dfu

&#x20;   Control Plane: 1

&#x20;   Worker Nodes : 2

&#x20;   Total Nodes  : 3



The script will generate the Kind configuration automatically.



\---



\# Step 8 – Kind



The automation checks for the Kind CLI.



If Kind is missing, it will be installed.



The script verifies:



&#x20;   kind version



\---



\# Step 9 – Create the Kind Cluster



Once Docker, kubectl, and Kind are ready, the automation creates the

Kubernetes cluster.



Example:



&#x20;   Cluster Name : dfu

&#x20;   Control Plane: 1

&#x20;   Worker Nodes : 2

&#x20;   Total Nodes  : 3



\---



\# Step 13 – Verify the Cluster



After the cluster is created, run:



&#x20;   kubectl get nodes



Expected result:



&#x20;   NAME                              STATUS   ROLES

&#x20;   dfu-control-plane                 Ready    control-plane

&#x20;   dfu-worker                        Ready    <none>

&#x20;   dfu-worker2                       Ready    <none>



The exact node names depend on the cluster name.



\---



\# Step 14 – Verify Kubernetes Context



Run:



&#x20;   kubectl config current-context



Expected:



&#x20;   kind-dfu



Replace `dfu` with the cluster name you selected.



\---



\# Step 15 – Verify Kind



Run:



&#x20;   kind get clusters



Expected:



&#x20;   dfu



\---



\# Complete Setup Flow



&#x20;   C:\\kind

&#x20;       │

&#x20;       ├── setup-kind-full-automation.ps1

&#x20;       └── Kind-overview.yaml

&#x20;                │

&#x20;                ▼

&#x20;       Run PowerShell as Administrator

&#x20;                │

&#x20;                ▼

&#x20;       Set Execution Policy

&#x20;                │

&#x20;                ▼

&#x20;       Run setup script

&#x20;                │

&#x20;                ▼

&#x20;       Check Windows

&#x20;                │

&#x20;                ▼

&#x20;       Check Administrator

&#x20;                │

&#x20;                ▼

&#x20;       

&#x20;                │

&#x20;                ▼

&#x20;       Ask Cluster Name

&#x20;                │

&#x20;                ▼

&#x20;       Ask Worker Count

&#x20;                │

&#x20;                ▼

&#x20;       Generate Kind YAML

&#x20;                │

&#x20;                ▼

&#x20;       Create Kind Cluster

&#x20;                │

&#x20;                ▼

&#x20;       Verify Kubernetes Nodes

&#x20;                │

&#x20;                ▼

&#x20;            READY

                 setup-kind.ps1
                       │
                       ▼
              Check Docker Desktop
                       │
             ┌─────────┴─────────┐
             │                   │
          Found              Not Found
             │                   │
             │             Install Docker
             │                   │
             └─────────┬─────────┘
                       ▼
                  Check kubectl
                       │
             ┌─────────┴─────────┐
             │                   │
          Found              Not Found
             │                   │
             │              Install kubectl
             │                   │
             └─────────┬─────────┘
                       ▼
                    Check Kind
                       │
             ┌─────────┴─────────┐
             │                   │
          Found              Not Found
             │                   │
             │                Install Kind
             │                   │
             └─────────┬─────────┘
                       ▼
              Prompt Cluster Name
                       │
                       ▼
              Prompt Worker Count
                       │
                       ▼
              Generate Kind YAML
                       │
                       ▼
                Create Cluster
                       │
                       ▼
              Switch kubectl context
                       │
                       ▼
                 Verify Nodes
                       │
                       ▼
                    DONE ✅