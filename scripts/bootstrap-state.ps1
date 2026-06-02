param (
    [string]$ResourceGroup = "tfstate-rg",
    [string]$Location = "australiaeast",
    [string]$StorageAccountPrefix = "tfstate"
)

# Generate a random string for the storage account name to ensure uniqueness
$Suffix = -join ((48..57) + (97..122) | Get-Random -Count 5 | % {[char]$_})
$StorageAccountName = "$StorageAccountPrefix$Suffix"
$ContainerName = "tfstate"

Write-Host "Creating Resource Group: $ResourceGroup in $Location..."
az group create --name $ResourceGroup --location $Location | Out-Null

Write-Host "Creating Storage Account: $StorageAccountName..."
az storage account create `
    --name $StorageAccountName `
    --resource-group $ResourceGroup `
    --location $Location `
    --sku Standard_LRS `
    --min-tls-version TLS1_2 `
    --allow-blob-public-access false | Out-Null

Write-Host "Creating Storage Container: $ContainerName..."
az storage container create `
    --name $ContainerName `
    --account-name $StorageAccountName `
    --auth-mode login | Out-Null

Write-Host "Enabling Blob Versioning on Storage Account..."
az storage account blob-service-properties update `
    --account-name $StorageAccountName `
    --resource-group $ResourceGroup `
    --enable-versioning true | Out-Null

Write-Host "`n--- Terraform Backend Configuration ---"
Write-Host "resource_group_name  = `"$ResourceGroup`""
Write-Host "storage_account_name = `"$StorageAccountName`""
Write-Host "container_name       = `"$ContainerName`""
Write-Host "key                  = `"dev/terraform.tfstate`""
Write-Host "---------------------------------------"
Write-Host "Please update terraform/environments/dev/backend.hcl with these values.`n"
