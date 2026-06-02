variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "cluster_name" { type = string }
variable "dns_prefix" { type = string }
variable "vnet_subnet_id" { type = string }
variable "log_analytics_workspace_id" { type = string }
variable "acr_id" { type = string }
variable "tags" { type = map(string) default = {} }
