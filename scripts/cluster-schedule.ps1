param (
    [Parameter(Mandatory=$true)]
    [ValidateSet("start", "stop", "status")]
    [string]$Action,

    [string]$ResourceGroup = "aks-dev-rg",
    [string]$ClusterName = "ai-agents-aks"
)

switch ($Action) {
    "stop" {
        Write-Host "Stopping AKS Cluster: $ClusterName in $ResourceGroup..."
        az aks stop --name $ClusterName --resource-group $ResourceGroup
        Write-Host "Cluster stopped successfully. (You are now saving compute costs)"
    }
    "start" {
        Write-Host "Starting AKS Cluster: $ClusterName in $ResourceGroup..."
        az aks start --name $ClusterName --resource-group $ResourceGroup
        Write-Host "Cluster started successfully."
    }
    "status" {
        $Status = az aks show --name $ClusterName --resource-group $ResourceGroup --query "powerState.code" -o tsv
        Write-Host "Cluster Power State: $Status"
    }
}
