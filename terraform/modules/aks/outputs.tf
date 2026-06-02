output "id" { value = azurerm_kubernetes_cluster.aks.id }
output "oidc_issuer_url" { value = azurerm_kubernetes_cluster.aks.oidc_issuer_url }
output "kube_config_raw" {
  value     = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}
