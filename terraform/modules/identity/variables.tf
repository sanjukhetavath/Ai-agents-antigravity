variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "identity_name" { type = string }
variable "aks_oidc_issuer_url" { type = string }
variable "service_account_namespace" { type = string default = "ai-agents" }
variable "service_account_name" { type = string default = "ai-agent-sa" }
variable "tags" { type = map(string) default = {} }
