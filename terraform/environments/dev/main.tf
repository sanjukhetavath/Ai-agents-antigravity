module "rg" {
  source              = "../../modules/resource-group"
  resource_group_name = "${var.app_name}-${var.environment}-rg"
  location            = var.location
  tags                = { Environment = var.environment }
}

module "networking" {
  source              = "../../modules/networking"
  resource_group_name = module.rg.name
  location            = module.rg.location
}

module "monitoring" {
  source              = "../../modules/monitoring"
  resource_group_name = module.rg.name
  location            = module.rg.location
  workspace_name      = "${var.app_name}-${var.environment}-law"
}

module "acr" {
  source              = "../../modules/acr"
  resource_group_name = module.rg.name
  location            = module.rg.location
  # ACR name must be globally unique and alphanumeric only
  acr_name            = replace("${var.app_name}${var.environment}acr", "-", "")
}

module "aks" {
  source                     = "../../modules/aks"
  resource_group_name        = module.rg.name
  location                   = module.rg.location
  cluster_name               = "${var.app_name}-${var.environment}-aks"
  dns_prefix                 = "${var.app_name}-${var.environment}"
  vnet_subnet_id             = module.networking.subnet_id
  log_analytics_workspace_id = module.monitoring.id
  acr_id                     = module.acr.id
}

module "identity" {
  source              = "../../modules/identity"
  resource_group_name = module.rg.name
  location            = module.rg.location
  identity_name       = "${var.app_name}-${var.environment}-mi"
  aks_oidc_issuer_url = module.aks.oidc_issuer_url
}
