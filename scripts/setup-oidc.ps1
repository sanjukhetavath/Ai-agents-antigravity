param (
    [Parameter(Mandatory=$true)]
    [string]$GitHubOrg,
    
    [Parameter(Mandatory=$true)]
    [string]$GitHubRepo,
    
    [string]$AppName = "github-actions-aks-deployer"
)

# Get current subscription details
$Subscription = az account show | ConvertFrom-Json
$SubscriptionId = $Subscription.id
$TenantId = $Subscription.tenantId

Write-Host "Creating Azure AD Application: $AppName..."
$AppId = az ad app create --display-name $AppName --query appId -o tsv

Write-Host "Creating Service Principal for Application..."
$SpId = az ad sp create --id $AppId --query id -o tsv

Write-Host "Waiting a few seconds for propagation..."
Start-Sleep -Seconds 15

Write-Host "Assigning Contributor role on subscription..."
az role assignment create `
    --assignee $AppId `
    --role "Contributor" `
    --scope "/subscriptions/$SubscriptionId" | Out-Null

Write-Host "Configuring Federated Credential for GitHub branch: main..."
$FedCredJson = @"
{
    "name": "github-actions-main",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:$($GitHubOrg)/$($GitHubRepo):ref:refs/heads/main",
    "description": "GitHub Actions main branch",
    "audiences": ["api://AzureADTokenExchange"]
}
"@

$TempFile = New-TemporaryFile
$FedCredJson | Out-File $TempFile -Encoding UTF8
az ad app federated-credential create --id $AppId --parameters $TempFile.FullName | Out-Null
Remove-Item $TempFile

Write-Host "`n--- GitHub Actions Variables / Secrets Setup ---"
Write-Host "Please set the following VARIABLES in your GitHub repository ($GitHubOrg/$GitHubRepo):"
Write-Host "AZURE_CLIENT_ID       : $AppId"
Write-Host "AZURE_TENANT_ID       : $TenantId"
Write-Host "AZURE_SUBSCRIPTION_ID : $SubscriptionId"
Write-Host "------------------------------------------------"
Write-Host "Note: ACR_LOGIN_SERVER variable will be known after Terraform run."
Write-Host "Don't forget to set your OPENAI_API_KEY as a SECRET!"
