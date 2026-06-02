# AI Agents on AKS (Azure Kubernetes Service)

This repository contains an end-to-end GitOps deployment of a Python-based AI Agent on Azure Kubernetes Service (AKS). It uses Terraform for infrastructure provisioning, GitHub Actions for CI/CD, and Flux v2 for GitOps continuous delivery. The infrastructure is specifically optimized for a personal Azure subscription to be as cost-effective as possible (estimated ~$37-53/mo with automated stop/start).

## Repository Structure

- `terraform/`: Infrastructure-as-Code modules to provision the Azure resources.
  - `environments/dev/`: Root module defining the Dev environment.
  - `modules/`: Reusable Terraform modules for AKS, ACR, Networking, Identity, and Monitoring.
- `src/ai-agent/`: The Python FastAPI AI Agent application built with LangChain. Contains tools for Web Search, Math, and DateTime.
- `k8s/`: Kubernetes manifests structured using Kustomize (Base + Overlays).
- `gitops/`: Flux v2 synchronization configurations.
- `scripts/`: PowerShell helper scripts for manual bootstrapping (Terraform State & OIDC).
- `.github/workflows/`: CI/CD pipelines (Terraform Plan/Apply, Docker Build/Push, Cluster Schedule).

## Prerequisites

- Azure CLI (`az`)
- Terraform CLI (`terraform`)
- Flux CLI (`flux`)
- `kubectl`
- An OpenAI API Key (`platform.openai.com`)

## Setup Instructions

### 1. Azure Authentication
Log into your Azure personal subscription:
```powershell
az login
```

### 2. Bootstrap Terraform State
Terraform needs an Azure Storage Account to store its remote state. Run the bootstrap script to create this:
```powershell
.\scripts\bootstrap-state.ps1 -Location australiaeast
```
*Note: Update `terraform/environments/dev/backend.hcl` with the output from this script.*

### 3. Configure GitHub Actions (Passwordless OIDC)
Set up Azure AD to allow GitHub Actions to deploy resources without storing passwords:
```powershell
.\scripts\setup-oidc.ps1 -GitHubOrg sanjukhetavath -GitHubRepo Ai-agents-antigravity
```
*Note: Add the output `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, and `AZURE_SUBSCRIPTION_ID` as Variables in your GitHub Repository Settings.*

### 4. Configure Application Secrets
In your GitHub Repository Settings, add a Secret named `OPENAI_API_KEY` containing your API key.

### 5. Deploy
1. Push your code to the `main` branch.
2. The `Terraform CI/CD` GitHub Action will automatically run and provision the Azure resources (VNet, ACR, AKS, Log Analytics).
3. Once Terraform finishes, the `Build & Push to ACR` action will build the Docker image and push it.
4. Finally, bootstrap Flux on your new cluster:
```bash
az aks get-credentials --resource-group ai-agents-dev-rg --name ai-agents-dev-aks
flux bootstrap github \
  --owner=sanjukhetavath \
  --repository=Ai-agents-antigravity \
  --branch=main \
  --path=gitops/clusters/dev \
  --personal
```

## Cost Optimization

This project includes a `.github/workflows/cluster-schedule.yml` cron job that automatically stops the AKS cluster at night and starts it in the morning to save on compute costs (saving ~70%). You can also manually trigger this action from the GitHub Actions tab.